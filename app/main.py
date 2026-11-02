"""
CNAD Activity 01: Cloud-Native Python Application
Author: Student / CNAD Team
Purpose: Demonstration of Docker Containerization and Kubernetes Deployment
"""

import os
import socket
import platform
import time
from datetime import datetime
from typing import Dict, Any

from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

# Application Initialization
APP_NAME = os.getenv("APP_NAME", "CNAD Cloud-Native Portal")
APP_VERSION = os.getenv("APP_VERSION", "v1.0.0")
APP_ENV = os.getenv("APP_ENV", "development")
PORT = int(os.getenv("PORT", 5000))
HOST = os.getenv("HOST", "0.0.0.0")

# Downward API / Kubernetes Pod Information
POD_NAME = os.getenv("POD_NAME", socket.gethostname())
POD_NAMESPACE = os.getenv("POD_NAMESPACE", "default")
NODE_NAME = os.getenv("NODE_NAME", "local-node")

START_TIME = datetime.utcnow()
request_counter = 0

app = FastAPI(
    title=APP_NAME,
    version=APP_VERSION,
    description="Cloud-Native Application for Containerization and Kubernetes Deployment Activity",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Setup paths for templates and static assets
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
TEMPLATES_DIR = os.path.join(BASE_DIR, "templates")
STATIC_DIR = os.path.join(BASE_DIR, "static")

templates = Jinja2Templates(directory=TEMPLATES_DIR)
if os.path.exists(STATIC_DIR):
    app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")


def get_ip_address() -> str:
    """Resolve current host IP address safely."""
    pod_ip = os.getenv("POD_IP")
    if pod_ip:
        return pod_ip
    try:
        return socket.gethostbyname(socket.gethostname())
    except Exception:
        return "127.0.0.1"


def get_uptime() -> str:
    """Return formatted uptime string."""
    delta = datetime.utcnow() - START_TIME
    hours, remainder = divmod(int(delta.total_seconds()), 3600)
    minutes, seconds = divmod(remainder, 60)
    return f"{hours}h {minutes}m {seconds}s"


@app.middleware("http")
async def track_requests(request: Request, call_next):
    """Middleware to count requests and add tracing headers."""
    global request_counter
    request_counter += 1
    response = await call_next(request)
    response.headers["X-Handled-By"] = POD_NAME
    response.headers["X-App-Version"] = APP_VERSION
    return response


@app.get("/", response_class=HTMLResponse, summary="Main Web Dashboard")
async def dashboard(request: Request):
    """Render interactive HTML dashboard showing container & Kubernetes runtime stats."""
    system_info = {
        "app_name": APP_NAME,
        "app_version": APP_VERSION,
        "environment": APP_ENV,
        "hostname": POD_NAME,
        "pod_namespace": POD_NAMESPACE,
        "node_name": NODE_NAME,
        "ip_address": get_ip_address(),
        "platform": f"{platform.system()} {platform.release()} ({platform.machine()})",
        "python_version": platform.python_version(),
        "uptime": get_uptime(),
        "start_time": START_TIME.strftime("%Y-%m-%d %H:%M:%S UTC"),
        "request_count": request_counter,
    }
    return templates.TemplateResponse("index.html", {"request": request, "info": system_info})


@app.get("/healthz", summary="Liveness & Readiness Probe Endpoint")
async def health_check() -> Dict[str, Any]:
    """
    Kubernetes Health Check Endpoint.
    Used for livenessProbe and readinessProbe to ensure the pod is responsive.
    """
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "uptime": get_uptime(),
        "pod_name": POD_NAME,
        "version": APP_VERSION,
        "http_code": 200
    }


@app.get("/api/info", summary="Application & Container Metadata API")
async def get_info() -> Dict[str, Any]:
    """Return comprehensive runtime metadata as JSON."""
    return {
        "app": {
            "name": APP_NAME,
            "version": APP_VERSION,
            "environment": APP_ENV,
            "status": "online"
        },
        "container": {
            "hostname": POD_NAME,
            "ip_address": get_ip_address(),
            "namespace": POD_NAMESPACE,
            "node_name": NODE_NAME
        },
        "system": {
            "os": platform.system(),
            "os_release": platform.release(),
            "architecture": platform.machine(),
            "python_version": platform.python_version()
        },
        "metrics": {
            "uptime": get_uptime(),
            "start_time": START_TIME.isoformat() + "Z",
            "request_count": request_counter
        }
    }


@app.get("/api/metrics", summary="Application Metrics")
async def get_metrics() -> Dict[str, Any]:
    """Return lightweight metrics for monitoring."""
    return {
        "uptime_seconds": (datetime.utcnow() - START_TIME).total_seconds(),
        "total_requests": request_counter,
        "pod_name": POD_NAME,
        "environment": APP_ENV
    }


@app.get("/api/echo", summary="Echo Test for Pod Load Balancing")
async def echo_message(msg: str = "Hello from CNAD") -> Dict[str, Any]:
    """Echo endpoint to verify round-robin routing across Kubernetes replicas."""
    return {
        "message": msg,
        "served_by_pod": POD_NAME,
        "client_timestamp": datetime.utcnow().isoformat() + "Z"
    }


if __name__ == "__main__":
    import uvicorn
    print(f"Starting {APP_NAME} on {HOST}:{PORT} (Environment: {APP_ENV})...")
    uvicorn.run("main:app", host=HOST, port=PORT, reload=False)
