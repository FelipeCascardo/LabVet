@echo off
setlocal

start "LabVet - Backend" cmd.exe /k call "%~dp0Iniciar Backend.bat"
timeout /t 2 /nobreak >nul
call "%~dp0Iniciar Frontend.bat"

endlocal
