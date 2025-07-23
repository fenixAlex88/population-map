# backend/logger.py
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("api.log"),
        logging.StreamHandler()
    ],
    encoding='utf-8'
)

logger = logging.getLogger("population-service")
