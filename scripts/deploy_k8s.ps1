# ==============================================================================
# Script: deploy_k8s.ps1
# Purpose: Deploy application to Kubernetes cluster and expose via Service
# ==============================================================================

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [Step 1/4] Applying Kubernetes Deployment and Service Manifests" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$K8S_DIR = Join-Path $SCRIPT_DIR "..\k8s"

kubectl apply -f (Join-Path $K8S_DIR "deployment.yaml")
kubectl apply -f (Join-Path $K8S_DIR "service.yaml")

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " [Step 2/4] Waiting for Pod Rollout to Complete..." -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

kubectl rollout status deployment/cnad-web-deployment --timeout=90s

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " [Step 3/4] Inspecting Deployed Kubernetes Resources" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

Write-Host "`n--- Deployments ---" -ForegroundColor Yellow
kubectl get deployments -l app=cnad-web-app

Write-Host "`n--- Replicas & Pods (Wide Output) ---" -ForegroundColor Yellow
kubectl get pods -l app=cnad-web-app -o wide

Write-Host "`n--- Exposed Service Details ---" -ForegroundColor Yellow
kubectl get svc cnad-web-service

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " [Step 4/4] Verifying Service Connectivity" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

Write-Host "`nService is exposed on NodePort: 30080" -ForegroundColor Green
Write-Host "Testing http://localhost:30080/api/info ..." -ForegroundColor Yellow

try {
    $info = Invoke-RestMethod -Uri "http://localhost:30080/api/info" -Method Get
    Write-Host "✓ Successfully connected to Kubernetes Pod!" -ForegroundColor Green
    Write-Host "Pod Name:    $($info.container.hostname)" -ForegroundColor Cyan
    Write-Host "Pod IP:      $($info.container.ip_address)" -ForegroundColor Cyan
    Write-Host "Environment: $($info.app.environment)" -ForegroundColor Cyan
    Write-Host "Status:      $($info.app.status)" -ForegroundColor Cyan
    Write-Host "`nOpen Web Dashboard: http://localhost:30080" -ForegroundColor Green
} catch {
    Write-Warning "Direct NodePort test on localhost:30080 failed or cluster requires port-forwarding."
    Write-Host "If using Minikube, execute: minikube service cnad-web-service" -ForegroundColor Yellow
    Write-Host "Or forward port with:       kubectl port-forward svc/cnad-web-service 5000:80" -ForegroundColor Yellow
}
