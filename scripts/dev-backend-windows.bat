@echo off
setlocal EnableExtensions
REM Open WebUI backend (FastAPI + uvicorn, port 8080, --reload)
REM Run from repo via: dev-start.bat

pushd "%~dp0..\backend" 2>nul
if not exist "requirements.txt" (
  echo [ERROR] backend folder not found or invalid. Expected: scripts\..\backend\requirements.txt
  popd 2>nul
  pause
  exit /b 1
)

if exist ".venv\Scripts\python.exe" (
  set "PYEXE=.venv\Scripts\python.exe"
) else if exist "venv\Scripts\python.exe" (
  set "PYEXE=venv\Scripts\python.exe"
) else (
  set "PYEXE=python"
  if exist ".venv\Scripts\activate.bat" call ".venv\Scripts\activate.bat"
  if exist "venv\Scripts\activate.bat" call "venv\Scripts\activate.bat"
)

set "CORS_ALLOW_ORIGIN=http://localhost:5173;http://localhost:8080"
if not defined PORT set "PORT=8080"

echo.
echo === Open WebUI backend ===
echo Directory: %CD%
echo Python:    %PYEXE%
echo URL:       http://localhost:%PORT%
echo CORS:      %CORS_ALLOW_ORIGIN%
echo.

"%PYEXE%" -c "import uvicorn" 2>nul
if errorlevel 1 (
  echo [ERROR] uvicorn is not installed for this Python.
  echo In this folder run:  python -m pip install -r requirements.txt
  echo Or create a venv:     python -m venv .venv
  echo                         .venv\Scripts\activate
  echo                         pip install -r requirements.txt
  popd 2>nul
  pause
  exit /b 1
)

REM Do not pass --forwarded-allow-ips * from CMD: even with quotes, some setups expand * to cwd file list.
REM For local dev, uvicorn defaults are enough; set reverse-proxy headers only in production if needed.
"%PYEXE%" -m uvicorn open_webui.main:app --port "%PORT%" --host 0.0.0.0 --reload
echo.
echo [Backend exited]
popd 2>nul
pause
