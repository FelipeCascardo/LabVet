# Produção local do LabVet

Esta estrutura publica o frontend React compilado por Nginx em
`http://127.0.0.1:8081`. O Nginx encaminha `/api` para a API Delphi local em
`127.0.0.1:9010`; PostgreSQL continua no container `labvet-postgres` e não é
publicado pelo proxy.

```text
Navegador ou Cloudflare Tunnel -> Nginx (Docker, 127.0.0.1:8081) -> API Delphi (Windows, 9010) -> PostgreSQL (Docker)
```

## Preparação

1. Copie `deploy/producao/.env.producao.example` para
   `.env.producao.local` na raiz.
2. Informe as mesmas credenciais locais de PostgreSQL e um segredo JWT próprio.
3. Compile `backend/LabVet.dproj` para gerar `backend/LabVet.exe`.
4. Garanta que Docker Desktop esteja em execução e que as portas `9010` e
   `8081` estejam livres.

## Execução

Execute `deploy\producao\iniciar-producao-local.bat`. Ele inicia o banco já
configurado, a API e o container `labvet-frontend-producao` e abre a interface
após o healthcheck responder.

O iniciador aguarda o banco ficar saudável, inicia a API sem janela adicional
e compila/inicia o frontend. Se a API desse mesmo executável já estiver na
porta 9010, ela é reutilizada; outro executável nessa porta gera erro.
Containers existentes são gerenciados pelo Docker Compose. Ao final, o script
valida `/api/v1/health` pelo proxy e abre `https://app.labvet.app/`, compatível
com os cookies seguros. Use `--no-browser` para executar sem abrir o navegador.
Docker Desktop deve estar em execução; o Tunnel deve estar ativo para acesso
pelo domínio público. A reutilização da API não recarrega suas configurações.

O Itriax continua em `127.0.0.1:8080`; o LabVet usa `127.0.0.1:8081`.

## Cloudflare Tunnel

O Tunnel deve encaminhar `app.labvet.app` para `http://127.0.0.1:8081`.
Mantenha o bind em loopback e não abra essa porta no roteador ou no Firewall.
Antes de publicar o hostname, altere `LABVET_COOKIE_SECURE` para `true` no
`.env.producao.local` e reinicie a API. Com esse valor, os cookies de sessão só
são aceitos em HTTPS; a validação de login em `http://127.0.0.1:8081` deixa de
ser aplicável, mas o acesso por `https://app.labvet.app` permanece protegido.
