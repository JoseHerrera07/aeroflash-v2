from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from prometheus_fastapi_instrumentator import Instrumentator
import os
import psycopg2
from psycopg2.extras import RealDictCursor
import time
import random
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("aeroflash")

app = FastAPI()

Instrumentator().instrument(app).expose(app)

# Recibir reservas
class Booking(BaseModel):
    flight_id: int
    passenger: str

def get_db_connection():
    try:
        conn = psycopg2.connect(
            host=os.getenv("DB_HOST", "db"),
            database=os.getenv("DB_NAME", "flightbookingdb"),
            user=os.getenv("DB_USER", "flightadmin"),
            password=os.getenv("DB_PASSWORD", "password"),
            cursor_factory=RealDictCursor
        )
        return conn
    except Exception as e:
        logger.error(f"Error conectando a DB: {e}")
        return None

# Inicio mi DB
def init_db():
    conn = get_db_connection()
    if conn:
        try:
            cur = conn.cursor()
            # Tabla de Vuelos
            cur.execute("""
                CREATE TABLE IF NOT EXISTS flights (
                    id SERIAL PRIMARY KEY,
                    origin VARCHAR(50),
                    destination VARCHAR(50),
                    price DECIMAL,
                    time VARCHAR(20)
                );
            """)
            # Tabla de Reservas
            cur.execute("""
                CREATE TABLE IF NOT EXISTS bookings (
                    id SERIAL PRIMARY KEY,
                    flight_id INTEGER,
                    passenger VARCHAR(100)
                );
            """)
            
            # Datos para hacer la prueba
            cur.execute("SELECT count(*) FROM flights")
            if cur.fetchone()['count'] == 0:
                flights = [
                    ('Lima', 'Miami', 450.00, '08:00 AM'),
                    ('Bogota', 'Madrid', 600.00, '02:00 PM'),
                    ('Mexico DF', 'New York', 350.00, '06:00 PM'),
                    ('Santiago', 'Buenos Aires', 200.00, '10:00 AM')
                ]
                for f in flights:
                    cur.execute("INSERT INTO flights (origin, destination, price, time) VALUES (%s, %s, %s, %s)", f)
                logger.info("Datos semilla insertados")
            
            conn.commit()
            cur.close()
            conn.close()
        except Exception as e:
            logger.error(f"Error inicializando DB: {e}")


init_db()

@app.get("/")
def read_root():
    return {"message": "Sistema AeroFlash v1.0 - Operativo"}

@app.get("/health")
def health_check():
    conn = get_db_connection()
    if conn:
        conn.close()
        return {"status": "healthy", "database": "connected"}
    return {"status": "unhealthy", "database": "disconnected"}

@app.get("/flights")
def get_flights():
    # para simulacion de latenciaa
    time.sleep(random.uniform(0.1, 0.5))
    
    # para la simulacion de errores
    if random.randint(1, 100) > 95:
        logger.error("Error simulado 500 en /flights")
        raise HTTPException(status_code=500, detail="Error de conexion simulado")

    conn = get_db_connection()
    if not conn:
        raise HTTPException(status_code=500, detail="Fallo DB")
    
    cur = conn.cursor()
    cur.execute("SELECT * FROM flights")
    flights = cur.fetchall()
    cur.close()
    conn.close()
    
    logger.info("Vuelos consultados exitosamente")
    return flights

@app.post("/book")
def create_booking(booking: Booking):
   
    time.sleep(random.uniform(0.2, 0.6))

    conn = get_db_connection()
    if not conn:
        raise HTTPException(status_code=500, detail="Fallo DB")
    
    try:
        cur = conn.cursor()
        cur.execute("INSERT INTO bookings (flight_id, passenger) VALUES (%s, %s)", (booking.flight_id, booking.passenger))
        conn.commit()
        cur.close()
        conn.close()
        logger.info(f"Nueva reserva creada para {booking.passenger}")
        return {"status": "confirmed", "message": "Vuelo reservado correctamente"}
    except Exception as e:
        logger.error(f"Error creando reserva: {e}")
        raise HTTPException(status_code=500, detail="Error guardando reserva")
