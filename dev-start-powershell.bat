@echo off
REM Double-click this to run dev-start.ps1 (avoids default .ps1 association issues).
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0dev-start.ps1"
pause
