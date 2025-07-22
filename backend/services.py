from fastapi import HTTPException
from pyproj import Transformer
import rasterio
from rasterio.transform import rowcol, xy
from rasterio.windows import Window
from .models import Coordinates

class PopulationService:
    TIF_PATH = "backend/data/GHS_POP_E2025_GLOBE_R2023A_54009_100_V1_0.tif"
    PIXEL_AREA_KM2 = 0.01

    def __init__(self):
        # Initialize rasterio dataset and transformer
        self.src = rasterio.open(self.TIF_PATH)
        self.crs_target = self.src.crs
        self.transformer = Transformer.from_crs("EPSG:4326", self.crs_target, always_xy=True)
        self.transformer_back = Transformer.from_crs(self.crs_target, "EPSG:4326", always_xy=True)
        self.dataset_transform = self.src.transform
        self.dataset_height = self.src.height
        self.dataset_width = self.src.width
        self.nodata = self.src.nodata

    def get_population_data(self, coords: Coordinates):
        try:
            # Project coordinates to GeoTIFF CRS
            x, y = self.transformer.transform(coords.lon, coords.lat)
            row, col = rowcol(self.dataset_transform, x, y)

            # Check if coordinates are within dataset bounds
            if not (0 <= row < self.dataset_height and 0 <= col < self.dataset_width):
                raise HTTPException(status_code=400, detail="Coordinates outside dataset bounds")

            # Read pixel value
            window = Window(col, row, 1, 1)
            value = self.src.read(1, window=window)[0, 0]

            if value == self.nodata or value is None:
                raise HTTPException(status_code=404, detail="No population data for this point")

            # Calculate pixel corner coordinates
            top_left_x, top_left_y = xy(self.dataset_transform, row, col)
            bottom_right_x, bottom_right_y = xy(self.dataset_transform, row + 1, col + 1)

            # Transform corners back to geographic coordinates
            top_left_lon, top_left_lat = self.transformer_back.transform(top_left_x, top_left_y)
            bottom_right_lon, bottom_right_lat = self.transformer_back.transform(bottom_right_x, bottom_right_y)

            # Calculate density
            density = value / self.PIXEL_AREA_KM2

            # Prepare response
            return {
                "coordinates": {
                    "input": {"lat": coords.lat, "lon": coords.lon},
                    "pixel_corners": {
                        "top_left": {"lat": top_left_lat, "lon": top_left_lon},
                        "bottom_right": {"lat": bottom_right_lat, "lon": bottom_right_lon}
                    }
                },
                "population_per_hectare": value,
                "density_per_km2": round(density)
            }

        except ValueError as e:
            raise HTTPException(status_code=400, detail="Invalid coordinate format")
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")

    def __del__(self):
        # Ensure the dataset is closed when the service is destroyed
        if hasattr(self, 'src'):
            self.src.close()