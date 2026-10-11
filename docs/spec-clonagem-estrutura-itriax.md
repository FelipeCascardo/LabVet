# Spec — fundação Itriax para o LabVet

## Objetivo

Criar a estrutura-base de backend e frontend do LabVet, inspirada na organização do Itriax e adaptada ao domínio de laboratório veterinário. Esta etapa não replica código, dados, marca ou regras financeiras do Itriax: estabelece uma fundação segura e extensível para os módulos do LabVet.

A referência visual da navegação é uma barra lateral escura fixa, com marca no topo, busca no menu, ícones lineares, item ativo destacado, grupos recolhíveis e atalhos de usuário no rodapé.

## Escopo

### Incluído

- Estrutura de aplicações backend e frontend.
- Conexão com o PostgreSQL já dedicado ao LabVet.
- Autenticação, autorização e gestão básica de usuários.
- Convenções para rotas, controladores, serviços, repositórios e providers.
- Casca navegável da interface, menu, layouts, permissões e estados de tela.
- Contratos de API, logs, auditoria e notificações base.
- Páginas iniciais dos módulos, ainda sem fluxos clínicos completos.

### Fora desta primeira clonagem

- Migração automática do modelo físico legado.
- Regras clínicas completas, cálculos financeiros e faturamento.
- Integrações externas, envio de mensagens e upload definitivo de arquivos.
- Importação definitiva de planilhas e emissão final de laudos.
- Cópia de código, identidade visual proprietária, dados ou regras internas do Itriax.

## Princípios

1. **Estrutura primeiro.** Cada módulo nasce com rota, permissão, página e contrato de API antes de seu fluxo completo.
2. **Domínio LabVet.** Nomes, papéis e regras pertencem à operação veterinária; o Itriax é somente referência de organização.
3. **Banco protegido.** A aplicação acessa PostgreSQL por conexão e repositórios; controladores não executam SQL.
4. **Segurança desde o início.** Hash de senha, expiração de sessão, RBAC, validação, logs sem credenciais e auditoria.
5. **Evolução incremental.** Cada corte deve ser testável e útil sem depender do próximo.
6. **Compatibilidade planejada.** A camada de dados considera tanto o esquema atual como a proposta de padronização, sem assumir aprovação desta.

## Arquitetura-alvo

~~~text
labvet/
├── backend/
│   ├── src/
│   │   ├── config/          # ambiente, banco e autenticação
│   │   ├── shared/
│   │   │   ├── errors/      # erros de domínio e respostas HTTP
│   │   │   ├── http/        # rotas e middlewares
│   │   │   └── providers/   # hash, token, relógio, arquivos e e-mail
│   │   ├── modules/
│   │   │   └── <modulo>/
│   │   │       ├── controllers/
│   │   │       ├── dto/
│   │   │       ├── models/
│   │   │       ├── repositories/
│   │   │       ├── services/
│   │   │       └── routes/
│   │   └── app.ts
│   └── tests/
├── frontend/
│   └── src/
│       ├── app/             # rotas, providers e proteção de páginas
│       ├── components/      # componentes reutilizáveis
│       ├── features/        # telas por módulo
│       ├── layouts/         # shell autenticado e autenticação
│       ├── services/        # cliente API e consultas
│       └── styles/          # tokens, tema e estilos globais
├── database/                # esquema, migrações e importações existentes
└── docs/
~~~

### Tecnologia de referência

- Backend: Delphi + Horse, PostgreSQL e migrações versionadas, seguindo as camadas já adotadas no Itriax.
- Frontend: React + TypeScript, roteamento no cliente, componentes acessíveis e cache de API.
- Qualidade: lint, formatação, testes unitários dos serviços e integração das rotas críticas.

O framework de servidor, ORM e biblioteca visual serão decididos no Corte 0. Independentemente da escolha, a separação de camadas desta spec é obrigatória.

## Backend

### Infraestrutura

| Componente | Responsabilidade | Aceite |
| --- | --- | --- |
| Configuração | Ler e validar variáveis de ambiente por perfil. | Falha ao iniciar se uma configuração obrigatória estiver ausente. |
| Conexão | Criar e encerrar pool PostgreSQL. | GET /health informa aplicação e banco separadamente. |
| Migrações | Aplicar mudanças de esquema ordenadamente. | Uma base vazia pode ser preparada sem intervenção manual. |
| Providers | Abstrair hash, tokens, relógio, IDs, arquivos e e-mail. | Serviços usam interfaces e permanecem testáveis. |
| Observabilidade | Log estruturado e ID de requisição. | Erros mantêm contexto técnico sem dados sensíveis. |

### Padrão de módulo

Cada módulo contém:

- routes: método, URL, middleware e controller;
- controllers: entrada/saída HTTP, sem regra de negócio;
- dto: validação e normalização;
- services: casos de uso e regras do domínio;
- repositories: persistência e consultas;
- models: entidades, tipos e contratos;
- tests: testes do serviço e das rotas relevantes.

Fluxo obrigatório: rota → middleware → controller → service → repository → banco. A resposta percorre o caminho inverso, serializada pelo DTO.

### Middlewares mínimos

| Middleware | Aplicação |
| --- | --- |
| requestId e log | Todas as requisições. |
| CORS e headers de segurança | Borda HTTP. |
| Autenticação | Todas as rotas privadas. |
| Autorização | Rotas que exigem permissão. |
| Validação de DTO | Antes do controller. |
| Tratamento global de erro | Última camada HTTP. |
| Rate limiting | Login, redefinição de senha e futuras APIs públicas. |

### Autenticação e autorização

- Login por e-mail e senha, armazenada apenas como hash.
- Access token curto e renovação/encerramento de sessão seguros.
- Recuperação de senha preparada por provider, sem envio real no primeiro corte.
- Papéis iniciais: administrador, gestor_laboratorio, atendente, veterinario e consulta.
- Permissões no padrão recurso:ação, por exemplo cadastros.animais:ler, laboratorio.laudos:editar e usuarios:gerenciar.
- Criação, alteração e exclusão lógica registram usuário, data/hora e entidade em auditoria.

### API inicial

| Grupo | Endpoints iniciais | Finalidade |
| --- | --- | --- |
| Sistema | GET /health, GET /api/v1/me | Saúde e usuário da sessão. |
| Autenticação | POST /api/v1/auth/login, POST /logout, POST /refresh | Início, fim e renovação de sessão. |
| Usuários | GET/POST /api/v1/users, GET/PATCH /api/v1/users/:id | Gestão administrativa inicial. |
| Papéis | GET /api/v1/roles | Papéis e permissões disponíveis. |
| Dashboard | GET /api/v1/dashboard/summary | Contrato inicial de indicadores. |
| Notificações | GET /api/v1/notifications, PATCH /:id/read | Lista e leitura. |

Recursos veterinários entram nos cortes seguintes, com paginação, filtros e ordenação desde a primeira listagem. Convenção: coleções respondem { data, meta }, itens respondem { data }, e erros respondem { error: { code, message, details, requestId } }.

## Frontend

### Layouts e padrões

| Elemento | Padrão |
| --- | --- |
| Layout público | Login e recuperação de senha, sem menu lateral. |
| Layout autenticado | Sidebar fixa, cabeçalho contextual, área responsiva de conteúdo e alertas. |
| Listagem | Título, descrição, ação primária, filtros, tabela/cartões, paginação e estados vazio/carregando/erro. |
| Formulário | Breadcrumb, seções curtas, validação no campo, cancelar/salvar e aviso de alterações não salvas. |
| Detalhe | Cabeçalho do registro, ações autorizadas, abas e auditoria quando aplicável. |
| Feedback | Toast para resultado breve; alerta em tela para ação necessária; diálogo em confirmação destrutiva. |

Rotas privadas devem ser protegidas no roteador e no backend. Ocultar menu não substitui negar o acesso.

### Menu inicial

| Grupo | Item | Rota sugerida | Permissão |
| --- | --- | --- | --- |
| Início | Home | / | sessão autenticada |
| Operação | Dashboards | /dashboards | dashboard:ler |
| Cadastros | Médicos veterinários | /cadastros/veterinarios | cadastros.veterinarios:ler |
| Cadastros | Tutores | /cadastros/tutores | cadastros.tutores:ler |
| Cadastros | Espécies | /cadastros/especies | cadastros.especies:ler |
| Cadastros | Animais | /cadastros/animais | cadastros.animais:ler |
| Laboratório | Tipos de exames | /laboratorio/tipos-exames | laboratorio.tipos_exames:ler |
| Laboratório | Atendimentos | /laboratorio/atendimentos | laboratorio.atendimentos:ler |
| Laboratório | Laudos | /laboratorio/laudos | laboratorio.laudos:ler |
| Laboratório | Importação de atendimentos | /laboratorio/importacoes/atendimentos | laboratorio.importacoes:gerenciar |
| Utilitários | Notificações | /notificacoes | notificacoes:ler |
| Utilitários | Suporte | /suporte | sessão autenticada |
| Administração | Configurações | /configuracoes | configuracoes:gerenciar |
| Administração | Usuários | /usuarios | usuarios:gerenciar |

Os grupos **Cadastros** e **Laboratório** são recolhíveis e seu estado é lembrado por usuário. Notificações mostram contador somente quando houver itens não lidos. O rodapé mantém suporte, configurações e cartão do usuário com perfil e sair.

### Direção visual

- Navegação em azul-marinho quase preto, item ativo em ardósia azulado e conteúdo em fundo claro neutro.
- Verde próprio do LabVet para destaque, sem reproduzir a marca Itriax.
- Tipografia legível, ícones consistentes e contraste WCAG AA.
- Sidebar expansível em desktop e painel temporário no celular.
- Carregamento, vazio, erro e sem autorização são estados obrigatórios de cada página.

## Mapeamento de domínio inicial

Esta implementação se apoia no [modelo de dados atual](modelo-de-dados.md), sem exigir migração antecipada.

| Novo recurso | Fonte/entidade provável | Observação |
| --- | --- | --- |
| Tutores | owners | Nome de tela alinhado ao domínio veterinário. |
| Animais | animals, animal_owners | Preserva histórico de vínculo com tutor. |
| Espécies | Atributo hoje associado a animal | Exige catálogo próprio antes de CRUD definitivo. |
| Tipos de exames | exams e lab_report_types | Confirmar se são cadastros distintos. |
| Atendimentos | attendances e attendance_exams | Chave atual inclui origem e registro. |
| Laudos | laboratory_reports, resultados e notas | Dado clínico exige auditoria. |
| Importações | import_batches | Registra arquivo, executor, resultado e rejeições. |
| Médicos veterinários | Sem tabela identificada | Novo modelo antes da implementação. |

## Entregas por partes

| Corte | Entrega | Resultado verificável |
| --- | --- | --- |
| 0 — Decisões | Stack, autenticação, papéis e compatibilidade de banco. | Documento de decisões e ambiente local definido. |
| 1 — Fundação backend | Projeto, configuração, conexão PostgreSQL, health check, erros, logs, migrações e testes base. | API inicia e informa saúde do banco. |
| 2 — Acesso | Usuários, papéis, login, logout, sessão, proteção de rota e auditoria base. | Administrador entra e acessa /me. |
| 3 — Casca frontend | Login, layout autenticado, sidebar, rotas e guardas. | Menu navega por todas as páginas; acesso indevido é bloqueado. |
| 4 — Dashboard e notificações | Cards iniciais, contrato de resumo, central e perfil. | Resumo e leitura de notificação ponta a ponta. |
| 5 — Cadastros | Espécies, tutores, animais e médicos, um por vez. | CRUD com validação e auditoria por recurso. |
| 6 — Laboratório | Tipos de exame, atendimentos, laudos e importação, um fluxo por vez. | Fluxos seguros sobre dados reais. |
| 7 — Endurecimento | Testes críticos, acessibilidade, performance, backup, monitoramento e permissões. | Checklist de produção aprovado. |

Um corte só começa após os critérios do anterior serem validados. A exceção é o refinamento visual em protótipos, que pode evoluir sem dados reais.

## Critérios transversais de aceite

- Credenciais, tokens e dados clínicos não aparecem em logs, erros ou código versionado.
- Toda página tem estados de carregamento, vazio, erro e sem acesso.
- APIs privadas exigem autenticação; escritas exigem permissão.
- Entradas são validadas na borda HTTP; regras de negócio ficam nos serviços.
- Alterações clínicas e cadastrais relevantes são auditáveis.
- Entregas incluem execução local e testes proporcionais ao risco.

## Riscos e decisões pendentes

1. **Banco:** existe esquema legado e uma proposta de padronização Itriax não aplicada. A primeira API precisa declarar explicitamente a qual esquema atende.
2. **Médicos e espécies:** regras de cadastro e relacionamento devem ser definidas antes das tabelas finais.
3. **Tipos de exame:** confirmar se catálogo de exames e tipos de laudo são independentes para o usuário.
4. **Laudos e arquivos:** definir armazenamento, retenção, acesso e backup antes de upload.
5. **Perfis:** validar quem visualiza, edita e emite laudos; é decisão clínica e operacional.

## Próximo corte recomendado

Os **Cortes 0 a 3** estão concluídos na fundação local: API Delphi/Horse, conexão PostgreSQL, autenticação por sessão, auditoria base, login integrado e shell responsivo com o menu acordado. O acesso atual não possui o conceito de Espaço; perfis e permissões serão adicionados em etapa própria.

O próximo corte é o **4 — Dashboard e notificações**. Ele deve criar os contratos de resumo no backend e substituir os indicadores provisórios da Home por dados reais, antes de iniciar os CRUDs clínicos e cadastrais.
