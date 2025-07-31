from pydantic import BaseModel

class Coordinates(BaseModel):
    lat: float
    lon: float


class ViewportBox(BaseModel):
    west: float  # Минимальная долгота
    south: float  # Минимальная широта
    east: float  # Максимальная долгота
    north: float  # Максимальная широта
