#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

# This script lives in repo/scripts/ → backend is repo/backend
$RepoRoot = Split-Path -Parent $PSScriptRoot
$BackendRoot = Join-Path $RepoRoot 'backend'

if (-not (Test-Path (Join-Path $BackendRoot 'requirements.txt'))) {
    Write-Error "backend not found: $BackendRoot"
}

Set-Location -LiteralPath $BackendRoot

$venvPython = Join-Path $BackendRoot '.venv\Scripts\python.exe'
$venvPython2 = Join-Path $BackendRoot 'venv\Scripts\python.exe'
if (Test-Path -LiteralPath $venvPython) {
    $PythonExe = $venvPython
} elseif (Test-Path -LiteralPath $venvPython2) {
    $PythonExe = $venvPython2
} else {
    $PythonExe = 'python'
    $venvActivate = Join-Path $BackendRoot '.venv\Scripts\Activate.ps1'
    if (Test-Path -LiteralPath $venvActivate) {
        . $venvActivate
    } else {
        $venvActivate2 = Join-Path $BackendRoot 'venv\Scripts\Activate.ps1'
        if (Test-Path -LiteralPath $venvActivate2) {
            . $venvActivate2
        }
    }
}

$env:CORS_ALLOW_ORIGIN = 'http://localhost:5173;http://localhost:8080'
if (-not $env:PORT) { $env:PORT = '8080' }
if (-not $env:FORWARDED_ALLOW_IPS) { $env:FORWARDED_ALLOW_IPS = '*' }

Write-Host ''
Write-Host '=== Open WebUI backend (PowerShell) ===' -ForegroundColor Cyan
Write-Host "Directory: $(Get-Location)"
Write-Host "Python:    $PythonExe"
Write-Host "URL:       http://localhost:$($env:PORT)"
Write-Host "CORS:      $($env:CORS_ALLOW_ORIGIN)"
Write-Host "Forwarded: $($env:FORWARDED_ALLOW_IPS)"
Write-Host ''

if ($PythonExe -eq 'python' -and -not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error 'python not found on PATH. Install Python 3.11+ and run: pip install -r requirements.txt'
}

# Pass '*' as a literal argv token (no CMD glob expansion).
$uvicornArgs = @(
    '-m', 'uvicorn',
    'open_webui.main:app',
    '--port', $env:PORT,
    '--host', '0.0.0.0',
    '--forwarded-allow-ips', $env:FORWARDED_ALLOW_IPS,
    '--reload'
)

& $PythonExe -c 'import uvicorn' 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error 'uvicorn is not installed. Run: pip install -r requirements.txt (inside backend or venv).'
}

& $PythonExe @uvicornArgs

Write-Host ''
Write-Host '[Backend exited]' -ForegroundColor Yellow
if ($Host.Name -eq 'ConsoleHost') {
    Read-Host 'Press Enter to close'
}
