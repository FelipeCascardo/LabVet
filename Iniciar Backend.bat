@echo off
setlocal

set "LABVET_BACKEND_EXE=%~dp0backend\LabVet.exe"

if not exist "%LABVET_BACKEND_EXE%" (
  echo ERRO: o executavel do backend nao foi encontrado.
  echo Compile o projeto backend\LabVet.dproj no Delphi e execute este arquivo novamente.
  pause
  exit /b 1
)

set "LABVET_ENV_FILE=%~dp0.env"
start "LabVet - Backend" cmd.exe /k ""%LABVET_BACKEND_EXE%""

endlocal
