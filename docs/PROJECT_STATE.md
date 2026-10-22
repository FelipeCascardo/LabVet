# LabVet — Estado do Projeto

Atualizado: 21/10/2026

## Marco atual

Fundação do módulo de catálogo de exames e modelos de exame. O modelo de dados
foi desenhado, as migrations estão versionadas e o backend iniciou a separação
por camadas adotada no Itriax.

## Situação conferida

- A base oficial definida para o produto é **Labvet V1**.
- A configuração `.env` declara `POSTGRES_DB=Labvet V1`.
- A base **Labvet V1** já foi provisionada e está confirmada como o destino
  oficial do projeto.
- Antes de qualquer alteração de schema, a conexão de execução deve apenas ser
  conferida para garantir que está apontando para essa base oficial.

## Entregue

- modelos Delphi do domínio de exames;
- base comum para tipos opcionais e auditoria;
- repositories individuais para as entidades de catálogo já iniciados;
- renomeação de `modeloslaudos` para `modeloexames` representada nas migrations
  e no modelo;
- script versionado para renomear `tiposanimais` para `animalgrupos` e ajustar
  as dependências;
- migration 011 aplicada com sucesso na base oficial Labvet V1;
- migrations 012 e 013 aplicadas com sucesso na base oficial Labvet V1, com
  referências convencionais textuais, referências percentuais e controle por
  analito;
- nomenclatura Delphi alinhada a `AnimalGrupo` nos models e repositories
  afetados, incluindo o vínculo em `ModeloExame`;
- services de catálogo para analitos, grupos de animais, categorias, exames,
  vínculos e modelos de exame registrados no projeto Delphi;
- controllers HTTP para os sete recursos do catálogo, com CRUD disponível
  conforme o service, inativação, reativação e respostas de erro padronizadas;
- contratos JSON registrados nos models do catálogo e rotas registradas no
  `LabVet.dpr` e no `LabVet.dproj`;
- fluxo de Modelo de Exames no frontend, iniciado pela árvore de grupos de
  animais, seguido pela lista filtrável de modelos do grupo e pelo editor;
- editor de Modelo de Exame com manutenção do cabeçalho e dos analitos do
  modelo; dados do Exame e do Analito de origem são exibidos somente para
  consulta;
- especificação funcional e técnica das páginas de cadastro do catálogo,
  incluindo a reorganização da navegação no novo menu Exames;
- padrão reutilizável de página de pesquisa/seleção e de edição para os
  cadastros de Exames no frontend;
- cadastro de Analitos implementado com listagem, filtros, ordenação,
  seleção, inclusão, edição, inativação e reativação pelos endpoints
  autenticados já existentes;
- cadastro de Categorias de Exame implementado com pesquisa, seleção,
  ordenação, paginação, inclusão, edição, inativação e reativação pelos
  endpoints autenticados já existentes;
- cadastro de Exames implementado com pesquisa, filtros de categoria e
  situação, ordenação, paginação, inclusão, edição, inativação e reativação;
- cadastro de Grupos de Animais implementado com árvore hierárquica,
  filtros, seleção, paginação, inclusão, edição, inativação e reativação;
- seleção de um nó da árvore restringe a manutenção ao grupo e aos seus
  subgrupos, e o formulário impede que um grupo seja atribuído como pai de si
  mesmo ou de um descendente;
- manutenção de analitos vinculados a um exame, liberada após salvar o
  cabeçalho, com inclusão, inativação e reativação de vínculos;
- novo menu **Exames** com Categorias, Exames, Grupos de Animais, Analitos e
  Modelo de Exames; a rota anterior de modelos redireciona para o novo menu;
- listagem de Analitos otimizada para celular: código ampliado e disposto na
  primeira linha, nome na segunda, com unidade e tipo de valor alinhados à
  direita nas respectivas linhas;
- diagramas de entidade-relacionamento e de classes atualizados;
- regra de importação explícita de `Data.DB` quando units acessam `TDataSet`.
- ambiente de produção local preparado com Nginx em Docker em
  `127.0.0.1:8081`, isolado do Itriax em `8080`.

## Em andamento

- concluir o CRUD consistente de cada repository;
- criar services individuais, com validações e transações;
- validar as rotas autenticadas contra a base Labvet V1 no ambiente Docker.
- validar as rotas autenticadas de Modelo de Exames contra a base oficial;
  Categorias, Exames, Grupos de Animais, Analitos e Modelos de Exames estão
  disponíveis como referências do padrão compartilhado.

### Validação da página de Grupos de Animais — 21/10/2026

- `npm run build` em `frontend` concluiu sem erros de TypeScript ou Vite;
- a interface foi publicada no ambiente local de produção;
- o healthcheck em `http://127.0.0.1:8081/api/v1/health` respondeu
  `{"status":"ok"}`.
- a leitura de inativos no endpoint depende de recompilar o backend Delphi na
  IDE, pois o executável em execução não é recompilável por linha de comando
  nesta instalação Community.

### Validação do fluxo de Modelo de Exames — 21/10/2026

- `npm run build` em `frontend` concluiu sem erros de TypeScript ou Vite;
- o fluxo foi publicado no ambiente local de produção;
- o healthcheck em `http://127.0.0.1:8081/api/v1/health` respondeu
  `{"status":"ok"}`.

### Correção da lista de modelos por grupo — 21/10/2026

- a lista aberta a partir de um grupo de animais agora usa o componente
  padrão de pesquisa e seleção;
- título, filtros e rodapé com paginação permanecem fixos; apenas a grade de
  modelos aceita rolagem;
- `npm run build` em `frontend` concluiu sem erros de TypeScript ou Vite.

## Próximas atividades priorizadas

Prioridade para 22/10/2026:

1. Melhorar o layout da página de edição de Modelo de Exame e de seus
   analitos, preservando a apresentação móvel de cabeçalho e rodapé fixos.
2. Retomar a modelagem de dados de atendimentos e laudos, começando pela
   revisão das tabelas `atendimentos`, `laudos`, `laudoanalitos` e
   `laudonotas` antes de qualquer aplicação na base oficial.
3. Implementar o processo de importação, com mapeamento dos dados importados
   para os modelos de exame e seus analitos.
4. Implementar as consultas de atendimentos e laudos.

Pendências subsequentes:

1. Validar as rotas autenticadas do catálogo contra a base oficial.
2. Implementar o endpoint composto de detalhe para a tela de modelos de exames.
3. Evoluir a página para manutenção de modelos e analitos.

## Pendências e riscos conhecidos

- `spec-backend-modelosexames.md` ainda contém nomes anteriores, sobretudo
  `TModeloLaudo`, e precisa ser revisada junto da entrega das rotas.
- Os contratos, models e consultas devem permanecer alinhados ao schema
  oficial versionado.
- A especificação preserva referências históricas a `ModeloLaudo` no desenho
  do agregado; elas devem ser concluídas na evolução do endpoint de detalhe.
- A validação das rotas autenticadas do catálogo deve ser ampliada para os
  demais recursos além de modelos de exame e seus analitos.
- Falta configurar Cloudflare Access para proteger o acesso externo de
  `app.labvet.app`; o Tunnel público já aponta para `127.0.0.1:8081`.
- `014_laudos_e_laudoanalitos.sql` é um rascunho não aplicado; faltam os
  campos e regras da realização do exame, como paciente, atendimento, coleta,
  resultado e emissão. Sua sintaxe foi validada em transação revertida, sem
  criação persistente de tabelas na base oficial.
- Um registro de origem de Linfócitos contém a faixa convencional invertida
  (`1000 - 672`) em `dsreferencia`; a recuperação preservou os percentuais,
  mas manteve os limites convencionais vazios para não publicar uma referência
  inválida. A fonte deve ser corrigida antes de completar essa referência.

## Validação registrada

Em 17/10/2026, o acesso a `app.labvet.app` retornava HTTP 502 porque a
API Delphi estava parada, sem processo `LabVet.exe` ou serviço na porta
9010. Os containers de frontend e PostgreSQL estavam saudáveis. A API foi
iniciada com `.env.producao.local`; os healthchecks direto em 9010, pelo
proxy em 8081 e pelo endereço público HTTPS responderam HTTP 200 com
`{"status":"ok"}`. O usuário confirmou que o login voltou a funcionar.

O iniciador de produção foi ajustado para reutilizar a API existente do mesmo
executável, iniciar a API ausente sem janela adicional, aguardar banco e
frontend saudáveis e validar a API pelo proxy antes de abrir o domínio HTTPS.
O healthcheck do PostgreSQL passou a aceitar nomes de banco com espaços.

A migration 011 foi aplicada após confirmação de `current_database() =
Labvet V1` e `current_user = labvet_app`. A validação do schema confirmou a
remoção de `tiposanimais`, a presença de `animalgrupos`, das colunas
`idanimalgrupo` e `idanimalgrupopai`, das constraints renomeadas e do trigger
`tratualizaranimalgrupos`.

Os artefatos Delphi afetados usam `TAnimalGrupo`,
`TAnimalGrupoRepository` e `IdAnimalGrupo`. A compilação Win64 foi concluída
com sucesso no ambiente Delphi local.

A compilação posterior das services e do repository de `ModeloExame` foi
concluída com sucesso e sem hints.

Os controllers de catálogo foram criados e registrados no projeto. A
compilação Win64 foi confirmada com sucesso no Delphi local; a validação de
integração HTTP permanece pendente.

O frontend possui a página inicial de Modelo de Exames e sua compilação de
produção foi concluída com sucesso. A validação funcional depende de dados e
rotas autenticadas em execução.

Em 20/10/2026, o frontend recebeu os componentes reutilizáveis de
pesquisa/seleção e edição para os cadastros de Exames. A primeira adoção é a
página de Analitos em `/exames/analitos`, integrada a `GET`, `GET /:id`,
`POST`, `PUT`, `DELETE` e `POST /:id/reativar`. A página mantém filtros no
cliente, ordenação pelos títulos da grade e ações sobre a seleção. A imagem do
analito passou a fazer parte dos arquivos públicos do frontend, eliminando a
dependência de imagens externas ou da prévia de layout. A compilação de
produção TypeScript/Vite foi concluída com sucesso; a validação interativa com
uma sessão autenticada da API ainda é pendente.

Em 20/10/2026, a listagem de Analitos passou a manter título, filtros e
rodapé fixos nos limites da área útil, com rolagem restrita ao painel da grade.
A paginação local agora apresenta 25 registros por página e responde aos
controles de primeira, anterior, próxima e última página sobre o resultado
filtrado e ordenado. A compilação de produção do frontend foi concluída sem
erros; a validação visual autenticada permanece pendente.

Na revisão seguinte da listagem, os painéis de título, filtros, grade e rodapé
foram alinhados à mesma largura útil. O atalho de atualização foi removido da
base da grade e a coluna Código foi ampliada para 350px, acomodando códigos
longos sem quebra prematura.

Em 21/10/2026, a versão consolidada do frontend foi recompilada e publicada
no ambiente local de produção. O healthcheck pelo proxy em `127.0.0.1:8081`
respondeu HTTP 200 com `{"status":"ok"}`. A validação de lint não encontrou
novos avisos nas páginas de cadastro; permanecem somente dois avisos já
existentes em `ModeloExamesPage` sobre atualização de estado em effects.

Em 21/10/2026, a apresentação móvel dos registros de Analitos foi reorganizada
em duas linhas: código com largura ampliada e nome à esquerda, unidade e tipo
de valor à direita. A compilação TypeScript/Vite foi concluída sem erros; a
versão foi publicada no ambiente local de produção e o healthcheck pelo proxy
em `127.0.0.1:8081` respondeu HTTP 200 com `{"status":"ok"}`.

Na revisão seguinte, os cartões móveis de Analitos foram compactados em cerca
de 17%, removendo o espaço vertical entre suas linhas. A página passou a abrir
com o painel de filtros recolhido. A compilação TypeScript/Vite foi concluída
sem erros; a versão foi publicada no ambiente local de produção e validada
pelo healthcheck do proxy.

Na página de edição móvel, o cabeçalho e o rodapé passaram a permanecer nos
limites da viewport; somente o painel de campos aceita rolagem. A compilação
TypeScript/Vite foi concluída sem erros; a versão foi publicada no ambiente
local de produção e validada pelo healthcheck do proxy.

Na página móvel de pesquisa e seleção, o cabeçalho, os filtros e o rodapé
passaram a permanecer nos limites da viewport; somente a grade de cartões
aceita rolagem. Um toque contínuo de 0,3 segundo em um cartão alterna sua
seleção, sem interferir na rolagem. A compilação TypeScript/Vite foi concluída
sem erros; a versão foi publicada no ambiente local de produção e validada
pelo healthcheck do proxy.

O menu lateral passou a destacar somente a rota exata de cada item, eliminando
o destaque permanente de **Exames** ao navegar pelos demais submenus. A
paginação móvel voltou a apresentar o botão de primeira página. Foi criado o
diagrama ER de exames e modelos em `docs/diagrama-er-exames-modelos.svg`. A
compilação TypeScript/Vite foi concluída sem erros; a versão foi publicada no
ambiente local de produção e o healthcheck pelo proxy respondeu HTTP 200 com
`{"status":"ok"}`.

O diagrama ER de exames e modelos também foi convertido para
`docs/diagrama-er-exames-modelos.png` e conferido visualmente, preservando os
relacionamentos e campos apresentados na versão vetorial.

Em 21/10/2026, a rota `/exames/categorias` recebeu páginas de pesquisa e
edição conectadas ao recurso autenticado `exame-categorias`. A manutenção
permite buscar, filtrar por situação, ordenar, paginar, selecionar, incluir,
editar, inativar e reativar categorias; o nome é normalizado antes do envio.
A compilação TypeScript/Vite foi concluída sem erros; a versão foi publicada
no ambiente local de produção e o healthcheck pelo proxy respondeu HTTP 200
com `{"status":"ok"}`.

Em 21/10/2026, a rota `/exames` recebeu páginas de pesquisa e edição
conectadas a `exames`, `exame-categorias`, `analitos` e `exame-analitos`. O
editor organiza identificação e composição/valor no cabeçalho e, após a
primeira gravação, libera o painel de analitos vinculados. A listagem e o
editor preservam o padrão móvel de áreas fixas e conteúdo rolável. As rotas de
categorias, exames, analitos e vínculos passaram a aceitar
`?incluirInativos=true`, permitindo filtros de inativos e a reativação de
vínculos históricos sem tentar criá-los novamente. A
compilação TypeScript/Vite foi concluída sem erros; a versão foi publicada no
ambiente local de produção e o healthcheck pelo proxy respondeu HTTP 200 com
`{"status":"ok"}`. A validação visual autenticada permanece pendente. A
compilação da alteração no controller Delphi deve ser confirmada pela IDE, pois
o compilador Community não oferece validação em linha de comando neste ambiente.

Na revisão móvel seguinte do editor de Exames, os painéis e cartões de
analitos passaram a respeitar a largura útil, inclusive para campos e ações.
O comando de remoção ficou reduzido a um botão de ícone à direita de cada
cartão.

Na revisão posterior, a edição de Exames foi reorganizada nas linhas
Código/Categoria, Nome e Quantidade/Valor. O valor usa o mesmo formato
interativo de moeda do Itriax, com separadores brasileiros. A área rolável de
edição recebeu contenção horizontal explícita para que a presença de analitos
não altere a largura dos painéis no celular.

Na revisão seguinte, o campo de valor passou a exibir sempre duas casas e a
camada HTTP passou a decodificar corretamente erros textuais retornados no
campo JSON `error`. O model Delphi de Exames também passou a interpretar o
número JSON do valor com formato invariante; a atualização do executável exige
compilação pela IDE Delphi.

A estrutura de produção local separa o frontend compilado em Nginx no
container `labvet-frontend-producao`, em `127.0.0.1:8081`, da API Delphi em
`9010` e do PostgreSQL já executado no Docker. Docker validou o container
como saudável e `GET /api/v1/health` pelo proxy respondeu `200` com
`{"status":"ok"}`. O cookie seguro foi ativado no ambiente de produção e,
em 14/10/2026, a rota publicada `app.labvet.app` foi criada no Cloudflare
apontando para o loopback `127.0.0.1:8081`; a tela de login abriu por HTTPS.
Cloudflare Access ainda não foi configurado.

Em 14/10/2026, uma cópia desatualizada de `LabVet.exe` causava erro 500 na
consulta de analitos de modelos, apesar dos dados e do código-fonte estarem
corretos. Após a recompilação e reinicialização da API, a rota autenticada
`GET /api/v1/modelos-exames-analitos?idModeloExame=249` respondeu HTTP 200
com 26 analitos e referências como `2.100000` a `3.300000`.

As referências da tela de Modelo de Exames são formatadas pelo tipo de valor
do analito: decimais usam duas casas no padrão brasileiro, inteiros não exibem
casas decimais e valores de caractere são preservados.

Em 15/10/2026, a migration 015 foi aplicada na base oficial e recuperou 660
faixas numéricas que estavam somente em `dsreferencia`. A migration 016 foi
aplicada em seguida e recuperou 94 referências percentuais de quatro valores,
habilitando o controle percentual em sete analitos hematológicos. A simulação
em transação revertida e a aplicação definitiva concluíram sem violar os
gatilhos de validação; 93 dessas referências também possuem faixa
convencional ordenada recuperada.

A migration 012 foi aplicada após confirmação de `current_database() =
Labvet V1` e `current_user = labvet_app`. A validação confirmou
`fgpercentual` em `analitos`, os limites textuais `vrrefminimo` e
`vrrefmaximo`, os limites percentuais `NUMERIC(7,4)`, a conversão dos 11
registros antes classificados como tipo misto para caractere e os triggers de
proteção de referências percentuais. A migration 013 qualificou o schema
nesses triggers; ambos os bloqueios foram validados em transações revertidas,
sem dados de teste persistidos.
