@echo off
REM Double-click this file to open TWO terminals:
REM   1) Backend  FastAPI + uvicorn  http://localhost:8080
REM   2) Frontend Vite dev server    http://localhost:5173 (default)
REM
REM Prerequisite (once):
REM   - Node.js 22 (or current LTS): in repo root  ->  npm install
REM   - Python 3.11+: in folder "backend"        ->  pip install -r requirements.txt
REM   - Optional venv: backend\.venv or backend\venv (auto-activated if present)

setlocal EnableExtensions
set "ROOT=%~dp0"

if not exist "%ROOT%backend\requirements.txt" (
  echo [ERROR] backend\requirements.txt not found.
  echo Place dev-start.bat in the Open WebUI repository root.
  pause
  exit /b 1
)

if not exist "%ROOT%package.json" (
  echo [ERROR] package.json not found.
  pause
  exit /b 1
)

echo Starting backend window...
start "Open WebUI - Backend :8080" cmd /k call "%ROOT%scripts\dev-backend-windows.bat"

REM Give the API a moment before the browser hammers it
timeout /t 2 /nobreak >nul

echo Starting frontend window...
start "Open WebUI - Frontend (Vite)" cmd /k call "%ROOT%scripts\dev-frontend-windows.bat"

echo.
echo Done. Use the browser: http://localhost:5173
echo Close the backend/frontend windows to stop servers.
timeout /t 4 >nul
exit /b 0
