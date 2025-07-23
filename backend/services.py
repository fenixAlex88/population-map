import numpy as np
from .models import Coordinates
from shapely.geometry import Polygon, Point
from rasterio.windows import Window
from rasterio.transform import rowcol, xy
import rasterio
from pyproj import Transformer
from fastapi import HTTPException
from .logger import logger


class PopulationService:
    TIF_PATH = r"backend/data/GHS_POP_E2030_GLOBE_R2023A_54009_100_V1_0.tif"
    PIXEL_AREA_KM2 = 0.01

    def __init__(self):
        try:
            logger.info(f"Opening GeoTIFF file: {self.TIF_PATH}")
            self.src = rasterio.open(self.TIF_PATH)
            self.crs_target = self.src.crs
            self.transformer = Transformer.from_crs(
                "EPSG:4326", self.crs_target, always_xy=True)
            self.transformer_back = Transformer.from_crs(
                self.crs_target, "EPSG:4326", always_xy=True)
            self.dataset_transform = self.src.transform
            self.dataset_height = self.src.height
            self.dataset_width = self.src.width
            self.nodata = self.src.nodata
            bounds = self.src.bounds
            logger.info(
                f"GeoTIFF bounds: left={bounds.left}, bottom={bounds.bottom}, right={bounds.right}, top={bounds.top}")
            logger.info("GeoTIFF successfully opened")
        except Exception as e:
            logger.error(f"Failed to initialize GeoTIFF: {e}")
            raise

    def get_population_data(self, coords: Coordinates):
        try:
            logger.info(
                f"Processing coordinates: lat={coords.lat}, lon={coords.lon}")
            x, y = self.transformer.transform(coords.lon, coords.lat)
            row, col = rowcol(self.dataset_transform, x, y)
            logger.debug(
                f"Transformed coordinates: x={x}, y={y}, row={row}, col={col}")

            if not (0 <= row < self.dataset_height and 0 <= col < self.dataset_width):
                logger.warning(
                    f"Coordinates outside dataset bounds: row={row}, col={col}")
                raise HTTPException(
                    status_code=400, detail="Coordinates outside dataset bounds")

            window = Window(col, row, 1, 1)
            value = self.src.read(1, window=window)[0, 0]
            logger.debug(f"Pixel value: {value}")

            if value == self.nodata or value is None:
                logger.warning("No population data for this point")
                raise HTTPException(
                    status_code=404, detail="No population data for this point")

            top_left_x, top_left_y = xy(self.dataset_transform, row, col)
            bottom_right_x, bottom_right_y = xy(
                self.dataset_transform, row + 1, col + 1)

            top_left_lon, top_left_lat = self.transformer_back.transform(
                top_left_x, top_left_y)
            bottom_right_lon, bottom_right_lat = self.transformer_back.transform(
                bottom_right_x, bottom_right_y)

            density = value / self.PIXEL_AREA_KM2
            logger.info(f"Population density: {density:.0f} people/km2")

            response = {
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
            logger.info(f"Returning response: {response}")
            return response

        except ValueError as e:
            logger.error(f"Invalid coordinate format: {e}")
            raise HTTPException(
                status_code=400, detail="Invalid coordinate format")
        except Exception as e:
            logger.error(f"Processing error: {e}", exc_info=True)
            raise HTTPException(
                status_code=500, detail=f"Server error: {str(e)}")

    def get_polygon_population(self, coordinates: list[list[float]]):
        try:
            logger.info(f"Processing polygon with coordinates: {coordinates}")
            if len(coordinates) < 3:
                raise HTTPException(
                    status_code=400, detail="Polygon must have at least 3 points")

            transformed_coords = [self.transformer.transform(
                lon, lat) for lat, lon in coordinates]
            polygon_proj = Polygon(transformed_coords)
            minx, miny, maxx, maxy = polygon_proj.bounds

            min_row, min_col = rowcol(self.dataset_transform, minx, miny)
            max_row, max_col = rowcol(self.dataset_transform, maxx, maxy)

            # Swap if necessary
            min_row, max_row = sorted([min_row, max_row])
            min_col, max_col = sorted([min_col, max_col])

            # Clamp to dataset bounds
            min_row = max(0, min_row)
            max_row = min(self.dataset_height, max_row)
            min_col = max(0, min_col)
            max_col = min(self.dataset_width, max_col)

            window = Window(min_col, min_row, max_col -
                            min_col, max_row - min_row)
            data = self.src.read(1, window=window)

            pixel_coords = [rowcol(self.dataset_transform, x, y)
                            for x, y in transformed_coords]
            pixel_polygon = Polygon([(col - min_col, row - min_row)
                                    for row, col in pixel_coords])

            mask = np.zeros_like(data, dtype=bool)
            for r in range(data.shape[0]):
                for c in range(data.shape[1]):
                    if pixel_polygon.contains(Point(c + 0.5, r + 0.5)):
                        mask[r, c] = True

            covered_pixels = np.count_nonzero(mask)
            if covered_pixels == 0:
                raise HTTPException(
                    status_code=400, detail="Polygon covers no valid pixels in dataset")

            valid = (data != self.nodata) & (data is not None) & mask
            population = data[valid].sum()
            logger.info(
                f"Total population in polygon: {population:.1f} (pixels matched: {covered_pixels})")

            return {"total_population": float(population)}
        except HTTPException as e:
            logger.error(f"HTTP error in polygon processing: {e.detail}")
            raise
        except Exception as e:
            logger.error(f"Error processing polygon: {e}", exc_info=True)
            raise HTTPException(
                status_code=500, detail=f"Server error: {str(e)}")

    def __del__(self):
        if hasattr(self, 'src'):
            self.src.close()
            logger.info("GeoTIFF closed")
