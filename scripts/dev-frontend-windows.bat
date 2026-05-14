@echo off
setlocal EnableExtensions
REM Open WebUI frontend (Vite dev server, default port 5173)
REM Run from repo via: dev-start.bat

cd /d "%~dp0.." || (
  echo [ERROR] Could not cd to repository root.
  pause
  exit /b 1
)

if not exist "package.json" (
  echo [ERROR] package.json not found. Run this script from the Open WebUI repo.
  pause
  exit /b 1
)

if not exist "node_modules\" (
  echo [WARN] node_modules not found. Run once: npm install
  echo.
)

where npm >nul 2>&1
if errorlevel 1 (
  echo [ERROR] npm not found on PATH. Install Node.js 22 LTS and retry.
  pause
  exit /b 1
)

echo.
echo === Open WebUI frontend (Vite) ===
echo Directory: %CD%
echo Command:   npm run dev
echo.

call npm run dev
echo.
echo [Frontend exited]
pause
