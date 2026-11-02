# ==============================================================================
# Script: test_endpoints.ps1
# Purpose: Test application endpoints and demonstrate Pod Load Balancing
# ==============================================================================

param (
    [string]$BaseUrl = "http://localhost:30080",
    [int]$Iterations = 6
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Testing Endpoints on $BaseUrl" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Health Probe Test
Write-Host "`n1. Testing Liveness / Readiness Probe (/healthz)..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$BaseUrl/healthz" -Method Get
    Write-Host "✓ Healthcheck response:" -ForegroundColor Green
    $health | Format-List
} catch {
    Write-Error "Failed to reach /healthz: $_"
}

# 2. Metadata Info Test
Write-Host "`n2. Testing Metadata Endpoint (/api/info)..." -ForegroundColor Yellow
try {
    $info = Invoke-RestMethod -Uri "$BaseUrl/api/info" -Method Get
    Write-Host "✓ Info metadata:" -ForegroundColor Green
    $info | ConvertTo-Json -Depth 3 | Write-Host
} catch {
    Write-Error "Failed to reach /api/info: $_"
}

# 3. Load Balancing Demonstration Across Replicas
Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " Demonstrating Kubernetes Round-Robin Load Balancing ($Iterations Requests)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$handledPods = @{}

for ($i = 1; $i -le $Iterations; $i++) {
    try {
        $resp = Invoke-RestMethod -Uri "$BaseUrl/api/echo?msg=Request-$i" -Method Get
        $pod = $resp.served_by_pod
        Write-Host "Request #$i -> Handled by Pod: $pod" -ForegroundColor Green
        if ($handledPods.ContainsKey($pod)) {
            $handledPods[$pod]++
        } else {
            $handledPods[$pod] = 1
        }
    } catch {
        Write-Warning "Request #$i failed: $_"
    }
    Start-Sleep -Milliseconds 200
}

Write-Host "`nSummary of Traffic Distribution Across Pods:" -ForegroundColor Cyan
$handledPods.GetEnumerator() | ForEach-Object {
    Write-Host " - Pod: $($_.Key) -> Handled $($_.Value) request(s)"
}
