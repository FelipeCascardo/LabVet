# LabVet — Estado do Projeto

Atualizado: 15/10/2026

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
- página de Modelo de Exames no frontend, organizada em três painéis: árvore
  de grupos de animais, modelos do grupo selecionado e analitos do modelo
  selecionado agrupados por seção;
- diagramas de entidade-relacionamento e de classes atualizados;
- regra de importação explícita de `Data.DB` quando units acessam `TDataSet`.
- ambiente de produção local preparado com Nginx em Docker em
  `127.0.0.1:8081`, isolado do Itriax em `8080`.

## Em andamento

- concluir o CRUD consistente de cada repository;
- criar services individuais, com validações e transações;
- validar as rotas autenticadas contra a base Labvet V1 no ambiente Docker.

## Próximas atividades priorizadas

Prioridade para 16/10/2026:

1. Revisar e concluir as tabelas `atendimentos`, `laudos`, `laudoanalitos` e
   `laudonotas`, antes de aplicá-las na base oficial.
2. Implementar o processo de importação, com mapeamento dos dados importados
   para os modelos de exame e seus analitos.
3. Implementar as consultas de atendimentos e laudos.

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
