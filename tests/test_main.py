"""
Automated Unit Tests for CNAD Activity 01 FastAPI Application
"""

import sys
import os
import pytest
from fastapi.testclient import TestClient

# Ensure app package is importable
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.main import app

client = TestClient(app)


def test_dashboard_endpoint():
    """Verify root HTML dashboard renders successfully."""
    response = client.get("/")
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]
    assert "CNAD" in response.text
    assert "Pod / Container Hostname" in response.text


def test_healthz_endpoint():
    """Verify Kubernetes liveness and readiness probe endpoint."""
    response = client.get("/healthz")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["http_code"] == 200
    assert "timestamp" in data
    assert "uptime" in data


def test_api_info_endpoint():
    """Verify application and runtime metadata endpoint."""
    response = client.get("/api/info")
    assert response.status_code == 200
    data = response.json()
    assert "app" in data
    assert "container" in data
    assert "system" in data
    assert "metrics" in data
    assert data["app"]["status"] == "online"


def test_api_metrics_endpoint():
    """Verify metrics endpoint for monitoring."""
    response = client.get("/api/metrics")
    assert response.status_code == 200
    data = response.json()
    assert "uptime_seconds" in data
    assert "total_requests" in data
    assert data["total_requests"] >= 1


def test_api_echo_endpoint():
    """Verify echo test endpoint."""
    test_msg = "CloudNativeTesting"
    response = client.get(f"/api/echo?msg={test_msg}")
    assert response.status_code == 200
    data = response.json()
    assert data["message"] == test_msg
    assert "served_by_pod" in data


def test_custom_headers_middleware():
    """Verify custom tracing headers injected by middleware."""
    response = client.get("/healthz")
    assert "x-handled-by" in response.headers
    assert "x-app-version" in response.headers
