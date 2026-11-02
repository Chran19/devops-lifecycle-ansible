# ==============================================================================
# Script: build_and_run.ps1
# Purpose: Build custom Docker image and execute container locally
# ==============================================================================

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [Step 1/4] Building Custom Docker Image: cnad-web-app:v1.0.0" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$IMAGE_NAME = "cnad-web-app:v1.0.0"
$CONTAINER_NAME = "cnad-app-instance"

# Navigate to root directory containing Dockerfile
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location (Join-Path $SCRIPT_DIR "..")

# Build image
docker build -t $IMAGE_NAME .
if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker build failed! Please check your Dockerfile and Docker Desktop status."
    exit $LASTEXITCODE
}
Write-Host "`n✓ Image successfully built: $IMAGE_NAME" -ForegroundColor Green

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " [Step 2/4] Cleaning Up Previous Container (if any)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

docker stop $CONTAINER_NAME 2>$null
docker rm $CONTAINER_NAME 2>$null

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " [Step 3/4] Running Application Container" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

docker run -d `
    --name $CONTAINER_NAME `
    -p 5000:5000 `
    -e APP_ENV="development" `
    -e APP_NAME="CNAD Cloud-Native Portal (Docker Standalone)" `
    $IMAGE_NAME

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to start container!"
    exit $LASTEXITCODE
}

Write-Host "`n✓ Container started: $CONTAINER_NAME" -ForegroundColor Green

Write-Host "`nWaiting 3 seconds for container startup..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " [Step 4/4] Verifying Application Health and Container Status" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

docker ps --filter "name=$CONTAINER_NAME"

Write-Host "`nTesting http://localhost:5000/healthz ..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5000/healthz" -Method Get
    Write-Host "✓ Health Check Succeeded!" -ForegroundColor Green
    $response | Format-List
    Write-Host "`nAccess the Web Dashboard in your browser: http://localhost:5000" -ForegroundColor Cyan
    Write-Host "Interactive Swagger API Docs: http://localhost:5000/docs" -ForegroundColor Cyan
} catch {
    Write-Warning "Could not reach endpoint yet. Printing container logs:"
    docker logs $CONTAINER_NAME
}
