# Backend LabVet

Backend Delphi/Horse organizado nas mesmas camadas do Itriax: controllers, services, repositories, models, providers e middlewares.

## Escopo inicial

- usuários ativos/inativos;
- login, refresh e logout por sessão;
- trilha de auditoria de ações administrativas e de autenticação;
- sem Espaço, perfis ou permissões nesta etapa.

A migração correspondente é [008-authentication-and-audit.sql](../database/migrations/008-authentication-and-audit.sql). Perfis e permissões entrarão em uma migração posterior, sem alteração do contrato de sessão.

## Inicialização

Após iniciar a API, crie exatamente o primeiro usuário por `POST /api/v1/setup/primeiro-usuario` com `nome`, `email` e `senha`. A rota deixa de aceitar novas criações assim que existir um usuário. Depois, use `POST /api/v1/auth/login`; as demais rotas de usuários exigem token de acesso.
