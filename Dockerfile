# ==============================================================================
# Dockerfile: Production-Ready Cloud-Native Python Microservice
# Activity: CNAD Activity 01 - Containerization & Kubernetes Deployment
# Base Image: Official Python 3.10 Slim Linux Image
# ==============================================================================

FROM python:3.10-slim

# Prevent Python from writing .pyc files to disk and enable unbuffered logging
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_ENV=production \
    PORT=5000 \
    HOST=0.0.0.0

# Set container working directory
WORKDIR /app

# Install security and operational best practices: Create an unprivileged user
# Running containers as non-root protects the host against container escape vulnerabilities
RUN groupadd -g 10001 appgroup && \
    useradd -u 10001 -g appgroup -s /bin/bash -m appuser

# Leverage Docker layer caching: Copy and install requirements separately
COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application source code into container
COPY app/ ./app/

# Set appropriate directory ownership for unprivileged user
RUN chown -R appuser:appgroup /app

# Switch to the non-root user
USER appuser

# Inform Docker that the container listens on port 5000 at runtime
EXPOSE 5000

# Container Healthcheck using native Python standard library (no curl dependency needed)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/healthz').read()" || exit 1

# Launch the FastAPI ASGI server with Uvicorn
CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "5000"]
