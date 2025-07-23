from fastapi import FastAPI, Depends, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from .models import Coordinates
from .services import PopulationService
from .logger import logger

app = FastAPI()

# Настройка CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Middleware для логирования запросов
@app.middleware("http")
async def log_requests(request: Request, call_next):
    # Логируем метод и URL
    body = "No body"
    # Проверяем, есть ли тело запроса (для методов, таких как POST)
    if request.method in ["POST", "PUT", "PATCH"]:
        try:
            body = await request.json()
        except Exception as e:
            body = f"Failed to parse body: {str(e)}"
    logger.info(
        f"Incoming request: {request.method} {request.url} Body: {body}")

    response = await call_next(request)
    logger.info(f"Response status: {response.status_code}")
    return response

# Dependency для PopulationService


def get_population_service():
    return PopulationService()


@app.post("/population")
async def get_population(
    coords: Coordinates,
    request: Request,
    service: PopulationService = Depends(get_population_service)
):
    user_ip = request.client.host
    user_agent = request.headers.get("User-Agent")
    response = service.get_population_data(coords)
    logger.info(
        f"User IP: {user_ip}, User-Agent: {user_agent}, Response data: {response}")
    return response


@app.post("/population/polygon")
async def get_polygon_population(data: dict, service: PopulationService = Depends(get_population_service)):
    coordinates = data.get("coordinates", [])
    if not coordinates or len(coordinates) < 3:
        logger.error(
            "Invalid polygon coordinates: less than 3 points or empty")
        raise HTTPException(
            status_code=400, detail="Polygon must have at least 3 points")
    response = service.get_polygon_population(coordinates)
    logger.info(f"Polygon response data: {response}")
    return response
