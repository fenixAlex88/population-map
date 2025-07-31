import json
from fastapi import FastAPI, Depends, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import psycopg2
from .models import Coordinates, ViewportBox
from .services import PopulationService
from .logger import logger

DB_CONFIG = {
    'dbname': 'osm_belarus',
    'user': 'postgres',
    'password': 'wewrq22ef2',
    'host': 'localhost',
    'port': '5432'
}

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


@app.post("/nodes/viewport")
async def get_nodes_in_viewport(
    box: ViewportBox,
):
    def make_envelope(box):
        # Проверка порядка координат
        west, east = sorted([box.west, box.east])
        south, north = sorted([box.south, box.north])
        return (west, south, east, north)

    envelope = make_envelope(box)

    try:
        with psycopg2.connect(**DB_CONFIG) as conn:
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT id, name, ST_X(geom::geometry), ST_Y(geom::geometry)
                    FROM nodes
                    WHERE ST_Within(
                        geom::geometry,
                        ST_MakeEnvelope(%s, %s, %s, %s, 4326)
                    )
                """, envelope)

                results = [
                    {
                        "id": row[0],
                        "name": row[1],
                        "longitude": row[2],
                        "latitude": row[3]
                    }
                    for row in cursor.fetchall()
                ]

        logger.info(f"Found {len(results)} nodes in viewport")
        return results

    except Exception as e:
        logger.error(f"Error querying viewport nodes: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")


@app.post("/links/viewport")
async def get_links_in_viewport(
    box: ViewportBox,
):
    def make_envelope(box):
        west, east = sorted([box.west, box.east])
        south, north = sorted([box.south, box.north])
        return (west, south, east, north)

    envelope = make_envelope(box)

    try:
        with psycopg2.connect(**DB_CONFIG) as conn:
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT l.id, l.name,
                           ST_AsGeoJSON(l.geom::geometry),
                           lt.color
                    FROM links l
                    JOIN link_types lt ON l.link_type_id = lt.id
                    WHERE ST_Intersects(
                        l.geom::geometry,
                        ST_MakeEnvelope(%s, %s, %s, %s, 4326)
                    )
                """, envelope)

                results = [
                    {
                        "id": row[0],
                        "name": row[1],
                        "geometry": json.loads(row[2]),
                        "color": row[3]
                    }
                    for row in cursor.fetchall()
                ]

        logger.info(f"Found {len(results)} links in viewport")
        return results

    except Exception as e:
        logger.error(f"Error querying viewport links: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")
