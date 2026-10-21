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

docker info >nul 2>&1
if errorlevel 1 (
  echo Docker indisponivel. Inicie o Docker Desktop e execute novamente.
  exit /b 1
)

echo Iniciando PostgreSQL local...
docker compose --env-file "%LABVET_ENV_FILE%" -f "%LABVET_ROOT%\docker-compose.yml" up -d --wait --wait-timeout 90 postgres
if errorlevel 1 exit /b 1

echo Iniciando API do LabVet...
powershell -NoProfile -Command "$ErrorActionPreference='Stop'; try { $listeners=@(Get-NetTCPConnection -LocalPort 9010 -State Listen -ErrorAction SilentlyContinue); if ($listeners.Count -gt 0) { foreach ($listener in $listeners) { $process=Get-Process -Id $listener.OwningProcess; if ($process.Path -ne $env:LABVET_API_EXE) { throw 'A porta 9010 pertence a outro executavel.' } }; Write-Host 'API existente reutilizada.' } else { $running=@(Get-Process -Name LabVet -ErrorAction SilentlyContinue); if ($running.Count -gt 0) { throw 'Existe um processo LabVet sem resposta na porta 9010. Verifique-o antes de tentar novamente.' }; Start-Process -FilePath $env:LABVET_API_EXE -WorkingDirectory (Join-Path $env:LABVET_ROOT 'backend') -WindowStyle Hidden } } catch { Write-Host $_.Exception.Message; exit 1 }"
if errorlevel 1 exit /b 1

echo Aguardando a API...
powershell -NoProfile -Command "$limite=(Get-Date).AddSeconds(20); do { try { if ((Invoke-WebRequest -UseBasicParsing http://127.0.0.1:9010/api/v1/health -TimeoutSec 2).StatusCode -eq 200) { exit 0 } } catch {} Start-Sleep -Milliseconds 500 } while ((Get-Date) -lt $limite); exit 1"
if errorlevel 1 (
  echo A API nao respondeu na porta 9010. Verifique o processo LabVet.exe.
  exit /b 1
)

echo Publicando frontend de producao em 127.0.0.1:8081...
docker compose --env-file "%LABVET_ENV_FILE%" -f "%LABVET_ROOT%\docker-compose.yml" --profile producao up --build -d --wait --wait-timeout 90 frontend-producao
if errorlevel 1 exit /b 1

echo Validando a API pelo frontend...
powershell -NoProfile -Command "$port=if ($env:LABVET_FRONTEND_PORT) { $env:LABVET_FRONTEND_PORT } else { '8081' }; $limite=(Get-Date).AddSeconds(30); do { try { $r=Invoke-WebRequest -UseBasicParsing ('http://127.0.0.1:'+$port+'/api/v1/health') -TimeoutSec 2; if ($r.StatusCode -eq 200 -and ($r.Content | ConvertFrom-Json).status -eq 'ok') { exit 0 } } catch {}; Start-Sleep -Milliseconds 500 } while ((Get-Date) -lt $limite); exit 1"
if errorlevel 1 (
  echo O frontend iniciou, mas nao conseguiu acessar a API. Verifique o proxy.
  exit /b 1
)

if /I not "%~1"=="--no-browser" start "" "https://app.labvet.app/"
echo API e frontend iniciados. Acesse https://app.labvet.app/
exit /b 0
