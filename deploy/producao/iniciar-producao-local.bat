@echo off
setlocal EnableExtensions

set "LABVET_ROOT=%~dp0\..\.."
for %%I in ("%LABVET_ROOT%") do set "LABVET_ROOT=%%~fI"
set "LABVET_ENV_FILE=%LABVET_ROOT%\.env.producao.local"
set "LABVET_API_EXE=%LABVET_ROOT%\backend\LabVet.exe"

if not exist "%LABVET_ENV_FILE%" (
  echo Arquivo .env.producao.local nao encontrado.
  echo Copie deploy\producao\.env.producao.example para a raiz e preencha os valores locais.
  exit /b 1
)

if not exist "%LABVET_API_EXE%" (
  echo Backend Win64 nao encontrado em %LABVET_API_EXE%.
  echo Compile backend\LabVet.dproj antes de iniciar a producao local.
  exit /b 1
)

for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%LABVET_ENV_FILE%") do (
  if not "%%A"=="" set "%%A=%%B"
)

netstat -ano | findstr /R /C:":9010 .*LISTENING" >nul
if not errorlevel 1 (
  echo A porta 9010 ja esta em uso. Encerre a API de desenvolvimento antes de iniciar a producao.
  exit /b 1
)

netstat -ano | findstr /R /C:":8081 .*LISTENING" >nul
if not errorlevel 1 (
  echo A porta 8081 ja esta em uso. Encerre o processo que a utiliza antes de iniciar a producao.
  exit /b 1
)

echo Iniciando PostgreSQL local...
docker compose --env-file "%LABVET_ENV_FILE%" -f "%LABVET_ROOT%\docker-compose.yml" up -d postgres
if errorlevel 1 exit /b 1

echo Iniciando API do LabVet...
start "LabVet API - Producao" /D "%LABVET_ROOT%\backend" "%LABVET_API_EXE%"

echo Aguardando a API...
powershell -NoProfile -Command "$limite=(Get-Date).AddSeconds(20); do { try { if ((Invoke-WebRequest -UseBasicParsing http://127.0.0.1:9010/api/v1/health -TimeoutSec 2).StatusCode -eq 200) { exit 0 } } catch {} Start-Sleep -Milliseconds 500 } while ((Get-Date) -lt $limite); exit 1"
if errorlevel 1 (
  echo A API nao respondeu. Verifique a janela 'LabVet API - Producao'.
  exit /b 1
)

echo Publicando frontend de producao em 127.0.0.1:8081...
docker compose --env-file "%LABVET_ENV_FILE%" -f "%LABVET_ROOT%\docker-compose.yml" --profile producao up --build -d frontend-producao
if errorlevel 1 exit /b 1

start "" "http://127.0.0.1:8081/"
echo Producao local iniciada em http://127.0.0.1:8081/
