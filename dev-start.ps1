#Requires -Version 5.1
<#
.SYNOPSIS
  Open two windows: FastAPI backend (:8080) + Vite frontend (:5173).

.DESCRIPTION
  Uses PowerShell so --forwarded-allow-ips '*' is passed literally to uvicorn
  (no CMD wildcard expansion).

  Prerequisite:
    backend:  pip install -r requirements.txt  (optional .venv or venv)
    repo root: npm install
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = $PSScriptRoot
$psExe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'

$backendScript = Join-Path $RepoRoot 'scripts\dev-backend-windows.ps1'
$frontendScript = Join-Path $RepoRoot 'scripts\dev-frontend-windows.ps1'

foreach ($p in @($backendScript, $frontendScript)) {
    if (-not (Test-Path -LiteralPath $p)) {
        Write-Error "Missing script: $p"
    }
}

$commonArgs = @(
    '-NoProfile',
    '-ExecutionPolicy', 'Bypass',
    '-NoExit',
    '-File'
)

Write-Host 'Starting backend window...' -ForegroundColor Green
Start-Process -FilePath $psExe -ArgumentList ($commonArgs + $backendScript) -WorkingDirectory (Join-Path $RepoRoot 'backend')

Start-Sleep -Seconds 2

Write-Host 'Starting frontend window...' -ForegroundColor Green
Start-Process -FilePath $psExe -ArgumentList ($commonArgs + $frontendScript) -WorkingDirectory $RepoRoot

Write-Host ''
Write-Host 'Done. Open: http://localhost:5173' -ForegroundColor Cyan
Write-Host 'Close each window to stop that server.'
