export interface Coordinates {
  lat: number;
  lon: number;
}

export interface PopulationData {
  coordinates: {
    input: Coordinates;
    pixel_corners: {
      top_left: Coordinates;
      bottom_right: Coordinates;
    };
  };
  population_per_hectare: number;
  density_per_km2: number;
}