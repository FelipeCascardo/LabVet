# Backend LabVet

Backend Delphi/Horse organizado nas mesmas camadas do Itriax: controllers, services, repositories, models, providers e middlewares.

## Escopo inicial

- usuários ativos/inativos;
- login, refresh e logout por sessão;
- trilha de auditoria de ações administrativas e de autenticação;
- sem Espaço, perfis ou permissões nesta etapa.

As estruturas oficiais do produto são versionadas em `database/estrutura` e
devem ser aplicadas exclusivamente na base Labvet V1. Perfis e permissões
entrarão em uma evolução posterior, sem alteração do contrato de sessão.

## Inicialização

Após iniciar a API, crie exatamente o primeiro usuário por `POST /api/v1/setup/primeiro-usuario` com `nome`, `email` e `senha`. A rota deixa de aceitar novas criações assim que existir um usuário. Depois, use `POST /api/v1/auth/login`; as demais rotas de usuários exigem token de acesso.

## Cliente PostgreSQL local

O FireDAC usa o cliente nativo PostgreSQL em `backend/Lib`. Em Windows x64, essa pasta deve conter `libpq.dll` e as DLLs compatíveis da mesma distribuição. Ela não é versionada; para o ambiente local atual, as bibliotecas foram copiadas da distribuição já utilizada pelo Itriax.

A unit `LabVet.Providers.Connection` segue a composição do DataModule de conexão do Itriax: registra explicitamente os drivers e fábricas FireDAC necessários, incluindo `FireDAC.Stan.Async` e `FireDAC.DApt`. A única adaptação é que o caminho de `Lib` é resolvido a partir do executável do LabVet, sem caminhos fixos ou credenciais no fonte.

## Execução local

- `Iniciar Backend.bat`: inicia somente a API em `http://127.0.0.1:9010`.
- `Iniciar Frontend.bat`: inicia somente o Vite em `http://127.0.0.1:5173`.
- `Iniciar LabVet.bat`: encerra processos que estejam usando essas portas e inicia backend e frontend juntos.
