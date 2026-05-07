import os

from fastapi import FastAPI

app = FastAPI(title="microservice", version="0.1.0")


@app.get("/health")
def health() -> dict:
    return {
        "status": "ok",
        "env": os.getenv("APP_ENV", "unknown"),
        "log_level": os.getenv("LOG_LEVEL", "info"),
        "api_key_loaded": bool(os.getenv("API_KEY")),
    }


@app.get("/")
def root() -> dict:
    return {"service": "microservice", "version": "0.1.0"}
