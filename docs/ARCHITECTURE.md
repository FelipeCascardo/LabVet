# LabVet — arquitetura vigente

## Visão geral

O repositório é organizado como um monorepo com backend Delphi/Horse,
PostgreSQL em Docker e frontend React/TypeScript/Vite.

```text
frontend (React) → API HTTP /api/v1 (Horse) → serviços → repositórios (FireDAC) → PostgreSQL
```

No ambiente de desenvolvimento, o frontend é servido pelo Vite e a API Delphi
Win64 é um processo separado. O PostgreSQL executa no container
`labvet-postgres`. Para produção local, o frontend compilado é servido por
Nginx no container `labvet-frontend-producao`, ligado exclusivamente a
`127.0.0.1:8081`; o proxy encaminha `/api` para a API Delphi local em `9010`.

## Componentes confirmados

| Área | Estado confirmado |
| --- | --- |
| Backend | Aplicação console Win64 Delphi, Horse, FireDAC e camadas de controllers, services, repositories, models, providers e middlewares. |
| API | Healthcheck, autenticação, sessões, usuários e controllers REST do catálogo de exames. |
| Banco | PostgreSQL 17 via `docker-compose.yml`; a base oficial é Labvet V1. |
| Frontend | React 19, TypeScript e Vite. |
| Proxy de produção local | Nginx em Docker, expondo somente `127.0.0.1:8081` e encaminhando `/api` para a API local. |
| Contratos | As rotas de catálogo estão registradas em `spec-backend-modelosexames.md`; ainda não há OpenAPI versionado. |
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

O script `014_laudos_e_laudoanalitos.sql` é um rascunho não aplicado da camada
transacional: `laudos` registra a realização e `laudoanalitos` os itens
realizados. Ele reutiliza a estrutura de configuração como ponto de partida,
mas ainda depende da modelagem de paciente, atendimento, coleta, resultados e
emissão antes de integrar o esquema oficial.

Em `analitos`, `tpvalor` aceita somente `1` (inteiro), `2` (decimal) e `3`
(caractere); `fgpercentual` determina se o analito pode receber limites
percentuais. Em `modeloexameanalitos`, `vrrefminimo` e `vrrefmaximo` são
textuais e seguem a validação de `tpvalor`; `vrrefperminimo` e
`vrrefpermaximo` são `NUMERIC(7,4)`, limitados ao intervalo de 0 a 100. O
banco bloqueia a gravação de percentual para analitos sem essa autorização.
As migrations 015 e 016 recuperam referências importadas preservadas em
`dsreferencia`: a primeira trata faixas numéricas simples, e a segunda o
formato de quatro valores que combina percentual e faixa convencional. A
recuperação de quatro valores não substitui limites existentes e descarta a
faixa convencional quando o mínimo de origem é maior que o máximo.

Antes de aplicar qualquer script, o destino deve ser confirmado com:

```sql
select current_database(), current_user;
```

A configuração `.env` declara a base oficial **Labvet V1**. A inicialização do
ambiente e a execução de migrations devem sempre confirmar essa base antes de
alterar o schema. Consulte [BASES_DE_DADOS.md](BASES_DE_DADOS.md).

## Regras de domínio com documentação existente

- [Especificação do backend de modelos de exames](spec-backend-modelosexames.md)
  descreve o agregado, regras e rotas registradas, com as nomenclaturas
  `modeloexames` e `animalgrupos`.
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

Os recursos `Analito`, `AnimalGrupo`, `ExameCategoria`, `Exame`,
`ExameAnalito`, `ModeloExame` e `ModeloExameAnalito` expõem listagem, consulta
por identificador, criação, atualização, inativação e reativação. A unit
`LabVet.Controllers.Base` concentra apenas a leitura técnica de JSON e IDs e a
serialização das respostas.

No frontend, a rota `/cadastros/modelos-exames` consome os recursos de grupos
de animais, modelos de exames e itens de modelo. A hierarquia visual é montada
no cliente com `idGrupoPai`, enquanto os analitos são carregados por modelo.
Para a composição dos três painéis, a página também consulta `Exame`,
`ExameAnalito` e `Analito`, resolvendo os identificadores no cliente até a
disponibilização do endpoint agregado de detalhe.

As units seguem o padrão `LabVet.<Camada>.<Entidade>`, por exemplo
`LabVet.Repositories.Exame`, `LabVet.Services.Exame` e
`LabVet.Controllers.Exame`.

## Operação local

- API: `http://127.0.0.1:9010`;
- interface web: `http://127.0.0.1:5173`;
- interface de produção local: `http://127.0.0.1:8081`;
- PostgreSQL: porta e credenciais locais definidas em `.env`;
- cliente nativo PostgreSQL para FireDAC: `backend/Lib`.

Os comandos de inicialização e os detalhes das bibliotecas estão em
[backend/README.md](../backend/README.md).

O acesso externo em `https://app.labvet.app` é realizado por Cloudflare Tunnel
apontando para `127.0.0.1:8081`, sem exposição de portas de entrada. A rota
pública é independente do Tunnel do Itriax e o serviço Cloudflared do LabVet
executa em paralelo ao já existente. A preparação e o uso local estão documentados em
[deploy/producao/README.md](../deploy/producao/README.md).
