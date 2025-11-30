from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator
import os
import psycopg2
from psycopg2 import OperationalError

app = FastAPI()

# Instrumentar Prometheus (Métricas automáticas)
Instrumentator().instrument(app).expose(app)

def get_db_connection():
    try:
        conn = psycopg2.connect(
            host=os.getenv("DB_HOST", "db"),
            database=os.getenv("DB_NAME", "flightbookingdb"),
            user=os.getenv("DB_USER", "flightadmin"),
            password=os.getenv("DB_PASSWORD", "password")
        )
        return conn
    except OperationalError as e:
        return None

@app.get("/")
def read_root():
    return {"message": "AeroFlash Backend v2.0 - Online"}

@app.get("/health")
def health_check():
    conn = get_db_connection()
    if conn:
        conn.close()
        return {"status": "healthy", "database": "connected"}
    return {"status": "unhealthy", "database": "disconnected"}
