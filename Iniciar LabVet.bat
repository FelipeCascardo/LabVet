@echo off
setlocal

echo Encerrando processos anteriores do LabVet...
powershell.exe -NoProfile -Command "$portas=@(9010,5173); foreach ($porta in $portas) { Get-NetTCPConnection -LocalPort $porta -State Listen -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue } }"
timeout /t 1 /nobreak >nul

start "LabVet - Backend" cmd.exe /k call "%~dp0Iniciar Backend.bat"
timeout /t 2 /nobreak >nul
call "%~dp0Iniciar Frontend.bat"

endlocal
