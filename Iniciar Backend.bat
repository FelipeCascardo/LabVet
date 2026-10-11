@echo off
setlocal

set "LABVET_ROOT=%~dp0"
set "LABVET_BACKEND_DIR=%LABVET_ROOT%backend"
set "LABVET_BACKEND_EXE=%LABVET_BACKEND_DIR%\LabVet.exe"
set "LABVET_ENV_FILE=%LABVET_ROOT%.env"

if not exist "%LABVET_BACKEND_EXE%" (
  echo ERRO: o executavel do backend nao foi encontrado.
  echo Compile o projeto backend\LabVet.dproj no Delphi e execute este arquivo novamente.
  pause
  exit /b 1
)

pushd "%LABVET_BACKEND_DIR%"
echo Iniciando a API do LabVet em http://127.0.0.1:9010 ...
LabVet.exe
set "LABVET_EXIT_CODE=%ERRORLEVEL%"
popd

echo.
echo O backend foi encerrado com codigo %LABVET_EXIT_CODE%.
pause
exit /b %LABVET_EXIT_CODE%
