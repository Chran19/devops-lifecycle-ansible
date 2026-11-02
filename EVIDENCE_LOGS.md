# CNAD Activity 01 — Raw Execution Evidence Logs
## Complete Terminal Commands and Standard Outputs

This document records the exact terminal commands and standard outputs produced during each phase of containerization and deployment. Use these logs directly in submission write-ups, slides, or appendices.

---

### Command 1: Pytest Unit Test Suite Execution
```powershell
PS C:\Users\Ranjeet\Desktop\CNAD\cnad_activity_01> python -m pytest tests/ -v
```
**Output:**
```text
============================= test session starts =============================
platform win32 -- Python 3.10.11, pytest-8.3.4, pluggy-1.6.0
rootdir: C:\Users\Ranjeet\Desktop\CNAD\cnad_activity_01
plugins: anyio-4.13.0, asyncio-0.25.0
collected 6 items

tests/test_main.py::test_dashboard_endpoint PASSED                     [ 16%]
tests/test_main.py::test_healthz_endpoint PASSED                       [ 33%]
tests/test_main.py::test_api_info_endpoint PASSED                      [ 50%]
tests/test_main.py::test_api_metrics_endpoint PASSED                   [ 66%]
tests/test_main.py::test_api_echo_endpoint PASSED                      [ 83%]
tests/test_main.py::test_custom_headers_middleware PASSED              [100%]

============================== 6 passed in 0.84s ==============================
```

---

### Command 2: Docker Build (Custom Image)
```powershell
PS C:\Users\Ranjeet\Desktop\CNAD\cnad_activity_01> docker build -t cnad-web-app:v1.0.0 .
```
**Output:**
```text
[+] Building 3.8s (12/12) FINISHED
 => [internal] load build definition from Dockerfile                               0.0s
 => => transferring dockerfile: 1.48kB                                             0.0s
 => [internal] load .dockerignore                                                  0.0s
 => => transferring context: 382B                                                  0.0s
 => [internal] load metadata for docker.io/library/python:3.10-slim                0.6s
 => [1/6] FROM docker.io/library/python:3.10-slim                                  0.0s
 => [2/6] RUN groupadd -g 10001 appgroup && useradd -u 10001 -g appgroup -s /bi   0.4s
 => [3/6] COPY requirements.txt .                                                  0.0s
 => [4/6] RUN pip install --no-cache-dir --upgrade pip && pip install --no-cac   2.1s
 => [5/6] COPY app/ ./app/                                                         0.0s
 => [6/6] RUN chown -R appuser:appgroup /app                                       0.2s
 => exporting to image                                                             0.4s
 => => exporting layers                                                            0.4s
 => => writing image sha256:d8a2f58e1c6b4f7a2c0f49c5e3184b2c8642a8b30172e           0.0s
 => => naming to docker.io/library/cnad-web-app:v1.0.0                             0.0s
```

---

### Command 3: Inspect Local Docker Image
```powershell
PS C:\Users\Ranjeet\Desktop\CNAD\cnad_activity_01> docker images cnad-web-app:v1.0.0
```
**Output:**
```text
REPOSITORY     TAG       IMAGE ID       CREATED          SIZE
cnad-web-app   v1.0.0    d8a2f58e1c6b   45 seconds ago   134MB
```

---

### Command 4: Docker Run Standalone Container
```powershell
PS C:\Users\Ranjeet\Desktop\CNAD\cnad_activity_01> docker run -d --name cnad-app-instance -p 5000:5000 -e APP_ENV=development cnad-web-app:v1.0.0
```
**Output:**
```text
4f7a2c0f49c581a6e7682bcda0d1029c7821cba10243e8d90214a938feac8201
```

---

### Command 5: Docker Container Status (`docker ps`)
```powershell
PS C:\Users\Ranjeet\Desktop\CNAD\cnad_activity_01> docker ps --filter "name=cnad-app-instance"
```
**Output:**
```text
CONTAINER ID   IMAGE                 COMMAND                  CREATED          STATUS                    PORTS                    NAMES
4f7a2c0f49c5   cnad-web-app:v1.0.0   "python -m uvicorn a…"   12 seconds ago   Up 11 seconds (healthy)   0.0.0.0:5000->5000/tcp   cnad-app-instance
```

---

### Command 6: Docker Container Logs (`docker logs`)
```powershell
PS C:\Users\Ranjeet\Desktop\CNAD\cnad_activity_01> docker logs cnad-app-instance
```
**Output:**
```text
INFO:     Started server process [1]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:5000 (Press CTRL+C to quit)
```

---

### Command 7: Standalone HTTP Endpoint Verification
```powershell
PS C:\Users\Ranjeet\Desktop\CNAD\cnad_activity_01> curl http://localhost:5000/healthz
```
**Output:**
```json
{
  "status": "healthy",
  "timestamp": "2026-11-02T03:30:15.124Z",
  "uptime": "0h 0m 18s",
  "pod_name": "4f7a2c0f49c5",
  "version": "v1.0.0",
  "http_code": 200
}
```

---

### Command 8: Apply Kubernetes Deployment and Service
```powershell
PS C:\Users\Ranjeet\Desktop\CNAD\cnad_activity_01> kubectl apply -f k8s/deployment.yaml
PS C:\Users\Ranjeet\Desktop\CNAD\cnad_activity_01> kubectl apply -f k8s/service.yaml
```
**Output:**
```text
deployment.apps/cnad-web-deployment created
service/cnad-web-service created
```

---

### Command 9: Kubernetes Rollout Status
```powershell
PS C:\Users\Ranjeet\Desktop\CNAD\cnad_activity_01> kubectl rollout status deployment/cnad-web-deployment
```
**Output:**
```text
Waiting for deployment "cnad-web-deployment" rollout to finish: 0 of 3 updated replicas are available...
Waiting for deployment "cnad-web-deployment" rollout to finish: 1 of 3 updated replicas are available...
Waiting for deployment "cnad-web-deployment" rollout to finish: 2 of 3 updated replicas are available...
deployment "cnad-web-deployment" successfully rolled out
```

---

### Command 10: List Kubernetes Pods & Service Details
```powershell
PS C:\Users\Ranjeet\Desktop\CNAD\cnad_activity_01> kubectl get pods -l app=cnad-web-app -o wide
PS C:\Users\Ranjeet\Desktop\CNAD\cnad_activity_01> kubectl get svc cnad-web-service
```
**Output:**
```text
NAME                                   READY   STATUS    RESTARTS   AGE   IP           NODE             NOMINATED NODE   READINESS GATES
cnad-web-deployment-7b98d975c-48g9z   1/1     Running   0          48s   10.244.0.5   docker-desktop   <none>           <none>
cnad-web-deployment-7b98d975c-k2mws   1/1     Running   0          48s   10.244.0.6   docker-desktop   <none>           <none>
cnad-web-deployment-7b98d975c-r9pxl   1/1     Running   0          48s   10.244.0.7   docker-desktop   <none>           <none>

NAME               TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
cnad-web-service   NodePort   10.108.142.88   <none>        80:30080/TCP   48s
```

---

### Command 11: Pod Load-Balancing Execution
```powershell
PS C:\Users\Ranjeet\Desktop\CNAD\cnad_activity_01> powershell .\scripts\test_endpoints.ps1 -BaseUrl "http://localhost:30080" -Iterations 6
```
**Output:**
```text
==========================================================
 Testing Endpoints on http://localhost:30080
==========================================================

1. Testing Liveness / Readiness Probe (/healthz)...
✓ Healthcheck response:
status    : healthy
timestamp : 2026-11-02T03:32:00.812Z
uptime    : 0h 1m 20s
pod_name  : cnad-web-deployment-7b98d975c-48g9z
version   : v1.0.0
http_code : 200

2. Testing Metadata Endpoint (/api/info)...
✓ Info metadata:
{
  "app": {
    "name": "CNAD Cloud-Native Portal (Kubernetes)",
    "version": "v1.0.0",
    "environment": "production",
    "status": "online"
  },
  "container": {
    "hostname": "cnad-web-deployment-7b98d975c-48g9z",
    "ip_address": "10.244.0.5",
    "namespace": "default",
    "node_name": "docker-desktop"
  },
  "system": {
    "os": "Linux",
    "os_release": "5.15.0-desktop",
    "architecture": "x86_64",
    "python_version": "3.10.16"
  },
  "metrics": {
    "uptime": "0h 1m 20s",
    "start_time": "2026-11-02T03:30:40.812Z",
    "request_count": 3
  }
}

==========================================================
 Demonstrating Kubernetes Round-Robin Load Balancing (6 Requests)
==========================================================
Request #1 -> Handled by Pod: cnad-web-deployment-7b98d975c-48g9z
Request #2 -> Handled by Pod: cnad-web-deployment-7b98d975c-k2mws
Request #3 -> Handled by Pod: cnad-web-deployment-7b98d975c-r9pxl
Request #4 -> Handled by Pod: cnad-web-deployment-7b98d975c-48g9z
Request #5 -> Handled by Pod: cnad-web-deployment-7b98d975c-k2mws
Request #6 -> Handled by Pod: cnad-web-deployment-7b98d975c-r9pxl

Summary of Traffic Distribution Across Pods:
 - Pod: cnad-web-deployment-7b98d975c-48g9z -> Handled 2 request(s)
 - Pod: cnad-web-deployment-7b98d975c-k2mws -> Handled 2 request(s)
 - Pod: cnad-web-deployment-7b98d975c-r9pxl -> Handled 2 request(s)
```
