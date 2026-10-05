@echo off
setlocal
set "LABVET_DEMO_DIR=%~dp0"
start "LabVet - demonstracao offline" powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%LABVET_DEMO_DIR%servidor-local.ps1" -Port 4174
timeout /t 1 /nobreak > nul
start "" "http://127.0.0.1:4174/"
endlocal
