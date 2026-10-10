@echo off
setlocal

set "LABVET_FRONTEND_DIR=%~dp0dashboard"

if not exist "%LABVET_FRONTEND_DIR%\server.js" (
  echo ERRO: nao foi encontrado o servidor do frontend em:
  echo %LABVET_FRONTEND_DIR%
  pause
  exit /b 1
)

where node >nul 2>nul
if errorlevel 1 (
  echo ERRO: Node.js nao foi encontrado.
  echo Instale o Node.js LTS e execute este arquivo novamente.
  pause
  exit /b 1
)

start "LabVet - Frontend" powershell.exe -NoExit -NoProfile -Command "Set-Location -LiteralPath '%LABVET_FRONTEND_DIR%'; node .\server.js"
timeout /t 1 /nobreak >nul
start "" "http://127.0.0.1:4173/"

endlocal
