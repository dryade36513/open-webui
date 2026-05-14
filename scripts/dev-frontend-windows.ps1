#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $RepoRoot

if (-not (Test-Path (Join-Path $RepoRoot 'package.json'))) {
    Write-Error "package.json not found under: $RepoRoot"
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Error 'npm not found on PATH. Install Node.js and retry.'
}

Write-Host ''
Write-Host '=== Open WebUI frontend (Vite) ===' -ForegroundColor Cyan
Write-Host "Directory: $(Get-Location)"
Write-Host 'Command:   npm run dev'
Write-Host ''

npm run dev

Write-Host ''
Write-Host '[Frontend exited]' -ForegroundColor Yellow
if ($Host.Name -eq 'ConsoleHost') {
    Read-Host 'Press Enter to close'
}
