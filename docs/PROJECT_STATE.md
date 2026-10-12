# LabVet — Estado do Projeto

Atualizado: 12/10/2026

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
- nomenclatura Delphi alinhada a `AnimalGrupo` nos models e repositories
  afetados, incluindo o vínculo em `ModeloExame`;
- services de catálogo para analitos, grupos de animais, categorias, exames,
  vínculos e modelos de exame registrados no projeto Delphi;
- diagramas de entidade-relacionamento e de classes atualizados;
- regra de importação explícita de `Data.DB` quando units acessam `TDataSet`.

## Em andamento

- concluir o CRUD consistente de cada repository;
- criar services individuais, com validações e transações;
- criar controllers e registrar as rotas por entidade;
- validar a conexão do backend com a base Labvet V1 no ambiente Docker.

## Próximas atividades priorizadas

1. Finalizar repositories, services e controllers por entidade.
2. Validar as rotas do backend contra a base oficial.
3. Integrar a tela de modelos de exames ao endpoint de detalhe.

## Pendências e riscos conhecidos

- `spec-backend-modelosexames.md` ainda contém nomes anteriores, sobretudo
  `TModeloLaudo`, e precisa ser revisada junto da entrega das rotas.
- Os contratos, models e consultas devem permanecer alinhados ao schema
  oficial versionado.

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
