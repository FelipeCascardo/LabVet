# LabVet — Histórico de Trabalho

## 12/10/2026 — Compilação limpa das services de catálogo

- Foram implementadas as operações pendentes de inclusão e alteração do
  repository de `ModeloExame`, passando a utilizar `SetOptionalIds`.
- A service de `ModeloExame` passou a criar e alterar modelos com validação e
  prevenção de código duplicado.
- A compilação Win64 do backend foi concluída com sucesso, sem hints.

## 12/10/2026 — Padronização das services de catálogo

- As units `AnimalGrupo`, `Exame`, `ModeloExame` e `ModeloExameAnalito` foram
  reformatadas conforme o guia canônico de programação Delphi.
- Foram removidos blocos de controle, tratamento de recursos e declarações
  compactados, preservando a separação de responsabilidades e o uso de
  `try/finally` para recursos criados pelas units.

## 12/10/2026 — Rotina de units Delphi

- O início de toda sessão passou a exigir a leitura do guia canônico em
  `C:\Projetos\Documentacoes\Padroes-Gerais\PADROES_PROGRAMACAO_DELPHI.md`.
- Toda nova unit Delphi do backend passou a exigir registro simultâneo em
  `backend/LabVet.dpr` e `backend/LabVet.dproj`.

## 12/10/2026 — Alinhamento do backend a animalgrupos

- `TTipoAnimal` foi substituído por `TAnimalGrupo`, com as propriedades
  `IdAnimalGrupo`, `IdAnimalGrupoPai` e `NmAnimalGrupo`.
- `TTipoAnimalRepository` foi substituído por `TAnimalGrupoRepository`; as
  consultas, inserções, alterações e inativações passaram a usar os nomes
  físicos vigentes em `animalgrupos`.
- O vínculo opcional de `TModeloExame` passou a ser `IdAnimalGrupo`, e o
  detalhe do modelo passou a expor `AnimalGrupo`.
- As referências do projeto Delphi e o diagrama de classes foram atualizados.
- Não havia service implementado que referisse `TipoAnimal`; portanto, nenhuma
  unit de service exigiu alteração.
- A compilação Win64 foi concluída com sucesso no ambiente Delphi local.

## 12/10/2026 — Aplicação da migration 011

- A conexão foi confirmada na base oficial `Labvet V1`, com o usuário
  `labvet_app`.
- A migration `011_renomear_tiposanimais_para_animalgrupos.sql` foi aplicada
  com sucesso.
- A validação posterior confirmou a substituição de `tiposanimais` por
  `animalgrupos`, as colunas `idanimalgrupo` e `idanimalgrupopai`, as
  constraints renomeadas e o trigger `tratualizaranimalgrupos`.

## 12/10/2026 — Organização do módulo de exames

- Foram consolidados os modelos de domínio para categorias, exames, analitos,
  grupos de animais, vínculos de exame e modelos de exame.
- A entidade anteriormente nomeada `ModeloLaudo` foi substituída por
  `ModeloExame`; a tabela correspondente é `modeloexames`.
- Foi criada a migration 010 para a renomeação de `modeloslaudos` para
  `modeloexames`.
- Foi criada a migration 011 para renomear `tiposanimais` para `animalgrupos`,
  inclusive colunas, chaves, índices, trigger e referência em `modeloexames`.
- Os repositories começaram a ser separados em units individuais por entidade,
  conforme o padrão do Itriax.
- `Data.DB` foi incluída explicitamente nas units de repository que usam
  membros de `TDataSet`, evitando avisos de compilação do Delphi.

## 12/10/2026 — Conferência das bases de dados

- Foi confirmado que `.env` identifica a base oficial como `Labvet V1`.
- Foi confirmado que a base `Labvet V1` já está provisionada e é a base
  oficial do projeto.
- Foi formalizada a regra de conferir `current_database()` e `current_user`
  antes de aplicar scripts de `database/estrutura`.
- A aplicação de migrations permanece condicionada à validação do destino e do
  schema resultante.

## 12/10/2026 — Artefatos de projeto

Foram criados os artefatos de acompanhamento inspirados no padrão do Itriax:

- `PRODUCT.md`;
- `ARCHITECTURE.md`;
- `PROJECT_STATE.md`;
- `ROADMAP.md`;
- `WORK_HISTORY.md`.

Eles são a referência de produto, arquitetura, estado, planejamento e registro
cronológico do LabVet. Documentos de especificação detalhada e diagramas
continuam em `docs` e devem ser atualizados junto de cada entrega.

## 12/10/2026 — Organização do repositório e diagrama ER

- Os artefatos históricos do modelo inicial foram isolados em `poc`, sem
  participação na inicialização do ambiente oficial.
- A raiz `database` passou a manter somente `database/estrutura`, destinada à
  evolução da base Labvet V1.
- O diagrama `diagrama-er-labvet-v1.svg` foi reconstruído com as 15 tabelas
  criadas pelas migrations 001 a 011.
- Foi estabelecida a rotina obrigatória de ler `PROJECT_STATE.md` no início de
  cada sessão e atualizar a documentação impactada em toda evolução ou
  correção.
