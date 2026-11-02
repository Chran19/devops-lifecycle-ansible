# ==============================================================================
# Script: cleanup.ps1
# Purpose: Gracefully teardown Kubernetes deployments and local Docker containers
# ==============================================================================

Write-Host "Teardown: Cleaning up Kubernetes and Docker resources..." -ForegroundColor Yellow

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$K8S_DIR = Join-Path $SCRIPT_DIR "..\k8s"

# Delete Kubernetes objects
Write-Host "Deleting Kubernetes resources..." -ForegroundColor Cyan
kubectl delete -f (Join-Path $K8S_DIR "service.yaml") --ignore-not-found=true
kubectl delete -f (Join-Path $K8S_DIR "deployment.yaml") --ignore-not-found=true

# Stop Docker standalone container
Write-Host "Stopping standalone Docker container..." -ForegroundColor Cyan
docker stop cnad-app-instance 2>$null
docker rm cnad-app-instance 2>$null

Write-Host "✓ Cleanup completed successfully!" -ForegroundColor Green
