# LabVet — arquitetura vigente

## Visão geral

O repositório é organizado como um monorepo com backend Delphi/Horse,
PostgreSQL em Docker e frontend React/TypeScript/Vite.

```text
frontend (React) → API HTTP /api/v1 (Horse) → serviços → repositórios (FireDAC) → PostgreSQL
```

No ambiente local, o frontend é servido pelo Vite e a API Delphi Win64 é um
processo separado. O PostgreSQL executa no container `labvet-postgres`. A
publicação unificada, com proxy reverso, ainda não é uma decisão implementada
no LabVet.

## Componentes confirmados

| Área | Estado confirmado |
| --- | --- |
| Backend | Aplicação console Win64 Delphi, Horse, FireDAC e camadas de controllers, services, repositories, models, providers e middlewares. |
| API | Healthcheck, autenticação, sessões, usuários e fundação do módulo de catálogo de exames. |
| Banco | PostgreSQL 17 via `docker-compose.yml`; a base oficial é Labvet V1. |
| Frontend | React 19, TypeScript e Vite. |
| Contratos | As rotas de catálogo serão documentadas junto dos controllers; ainda não há OpenAPI versionado. |
| Testes | Validações de schema e de API ainda precisam ser consolidadas em suíte automatizada. |

## Autenticação e sessão

O backend possui o fluxo administrativo de primeiro usuário, login, refresh e
logout por sessão. As rotas de catálogo devem reutilizar os middlewares de
autenticação e manter auditoria das ações de inclusão, alteração e inativação.

## Persistência e evolução do esquema

`database/estrutura` é a fonte versionada das estruturas e evoluções da base
oficial. As entidades do módulo de exames são `examecategorias`, `exames`,
`analitos`, `animalgrupos`, `exameanalitos`, `modeloexames` e
`modeloexameanalitos`.

Antes de aplicar qualquer script, o destino deve ser confirmado com:

```sql
select current_database(), current_user;
```

A configuração `.env` declara a base oficial **Labvet V1**. A inicialização do
ambiente e a execução de migrations devem sempre confirmar essa base antes de
alterar o schema. Consulte [BASES_DE_DADOS.md](BASES_DE_DADOS.md).

## Regras de domínio com documentação existente

- [Especificação do backend de modelos de exames](spec-backend-modelosexames.md)
  descreve o agregado, regras e rotas previstas; ela precisa ser atualizada com
  as nomenclaturas `modeloexames` e `animalgrupos`.
- [Diagrama ER de exames](diagrama-er-exames.svg) e o diagrama de classes em
  `docs` são referência para as relações persistidas.
- O guia canônico de programação Delphi está em
  `C:\Projetos\Documentacoes\Padroes-Gerais\PADROES_PROGRAMACAO_DELPHI.md` e
  define as convenções das units e da camada de persistência.

## Camadas de domínio

Cada entidade de catálogo possui units próprias por camada. A dependência
permitida é:

```text
Controller → Service → Repository → PostgreSQL
```

Controllers traduzem HTTP e JSON; services concentram validações, auditoria e
transações; repositories usam SQL parametrizado e FireDAC. Controllers não
executam SQL e repositories não decidem regras de negócio.

As units seguem o padrão `LabVet.<Camada>.<Entidade>`, por exemplo
`LabVet.Repositories.Exame`, `LabVet.Services.Exame` e
`LabVet.Controllers.Exame`.

## Operação local

- API: `http://127.0.0.1:9010`;
- interface web: `http://127.0.0.1:5173`;
- PostgreSQL: porta e credenciais locais definidas em `.env`;
- cliente nativo PostgreSQL para FireDAC: `backend/Lib`.

Os comandos de inicialização e os detalhes das bibliotecas estão em
[backend/README.md](../backend/README.md).
