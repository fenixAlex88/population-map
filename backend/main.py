from fastapi import FastAPI, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from .models import Coordinates
from .services import PopulationService
import logging

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("api.log"),  # Логи в файл
        logging.StreamHandler()  # Логи в консоль
    ]
)
logger = logging.getLogger(__name__)

app = FastAPI()

# Настройка CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5174"],
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
    logger.info(f"Incoming request: {request.method} {request.url} Body: {body}")

    response = await call_next(request)
    logger.info(f"Response status: {response.status_code}")
    return response

# Dependency для PopulationService
def get_population_service():
    return PopulationService()

@app.post("/population")
async def get_population(coords: Coordinates, service: PopulationService = Depends(get_population_service)):
    response = service.get_population_data(coords)
    logger.info(f"Response data: {response}")
    return response