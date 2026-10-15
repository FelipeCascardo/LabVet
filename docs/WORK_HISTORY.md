# LabVet — Histórico de Trabalho

## 12/10/2026 — Planejamento para 13/10/2026

- Registradas como prioridades da próxima sessão: concluir as tabelas
  `atendimentos`, `laudos`, `laudoanalitos` e `laudonotas`; implementar a
  importação com mapeamento para modelos de exame; e disponibilizar consultas
  de atendimentos e laudos.

## 12/10/2026 — Rascunho do modelo de realização de exames

- Criado o script não aplicado `014_laudos_e_laudoanalitos.sql`, baseado nas
  tabelas de configuração `modeloexames` e `modeloexameanalitos`.
- As chaves foram renomeadas para `idlaudo`, `idlaudoanalito` e `idlaudo` como
  vínculo dos itens. O script foi deixado propositalmente como base editável
  para a definição dos dados de paciente, atendimento, coleta e resultado.
- A sintaxe foi validada em uma transação revertida na base oficial; nenhuma
  tabela, trigger ou função do rascunho permaneceu persistida.

## 12/10/2026 — Migration 012: referências percentuais por modelo

- Criada e aplicada a migration
  `012_referencias_percentuais_modeloexameanalitos.sql` na base oficial
  `Labvet V1`, após o backup local confirmado.
- `analitos` recebeu `fgpercentual`; `tpvalor` passou a aceitar somente
  inteiro, decimal e caractere. Os 11 registros anteriormente marcados como
  mistos foram migrados para caractere.
- `modeloexameanalitos.vrrefminimo` e `vrrefmaximo` passaram a ser textuais;
  foram incluídos `vrrefperminimo` e `vrrefpermaximo` como `NUMERIC(7,4)`.
- Constraints e triggers impedem percentuais fora de 0 a 100 ou associados a
  analitos sem `fgpercentual`.
- A migration corretiva 013 qualifica o schema `labvet` nas funções dos
  triggers, garantindo sua execução em conexões cujo `search_path` padrão não
  contém esse schema.
- Models, repositories e services do backend foram alinhados ao novo contrato;
  a recompilação Win64 no Delphi local permanece pendente.

## 12/10/2026 — Backup antes da evolução das referências

- Foi confirmado o destino `Labvet V1`, com o usuário `labvet_app`.
- Foi criado o backup PostgreSQL em formato custom:
  `database/backups/labvet-v1-2026-10-12-before-referencias-modeloexameanalitos.dump`.
- O arquivo de backup é local e foi incluído no `.gitignore`; ele não será
  versionado no repositório.

## 12/10/2026 — Página de Modelo de Exames

- Criada a página `ModeloExamesPage` na rota
  `/cadastros/modelos-exames`.
- A tela monta a estrutura hierárquica de grupos de animais a partir de
  `idGrupoPai`, permite selecionar um grupo e apresenta seus modelos ativos.
- Os analitos de cada modelo visível são carregados pela rota específica e
  exibidos em ordem, com rótulo e referência configurada.
- Criado o cliente autenticado `modeloExamesApi` para as rotas de grupos,
  modelos e itens de modelo.
- A compilação de produção do frontend (`tsc` e Vite) foi concluída com
  sucesso.

## 12/10/2026 — Organização em três painéis de Modelo de Exames

- A tela foi reorganizada em painéis simultâneos de grupos, modelos e analitos.
- Os cards de modelo passaram a apresentar os campos do exame vinculado:
  código, nome, quantidade total e valor; e do modelo: nome, faixa de idade e
  arquivo de origem.
- O painel de analitos busca e relaciona `ExameAnalito` e `Analito` para
  apresentar nome e unidade em azul-escuro, além da configuração do
  `ModeloExameAnalito`.
- Os analitos são agrupados por `DsSecao` e ordenados por `NrExibicao`.
- A compilação de produção do frontend foi concluída com sucesso.

## 12/10/2026 — Compactação dos cards de analitos

- O card de analito passou a exibir o nome e a unidade entre parênteses no
  cabeçalho, em azul-escuro.
- Os rótulos internos foram removidos; rótulo, referência e unidade do modelo
  são apresentados em uma linha compacta, e a técnica é exibida em itálico.
- A compilação de produção do frontend foi concluída com sucesso.

## 12/10/2026 — Reorganização de cards de modelos e analitos

- O card de modelo passou a exibir o código do exame em selo circular verde,
  o nome do exame ao lado e os campos em duas linhas: faixa etária, quantidade
  e valor; seguida do arquivo de origem.
- O card de analito passou a exibir rótulo, referência mínima e máxima na
  primeira linha e a técnica em itálico na segunda.
- A compilação de produção do frontend foi concluída com sucesso.

## 12/10/2026 — Hierarquia tipográfica dos analitos

- `DsRotulo`, `VrRefMinimo` e `VrRefMaximo` passaram a usar fonte de 13px;
  `DsTecnica` permanece em 11px, preservando a diferença de 2px solicitada.

## 12/10/2026 — Alternância visual dos analitos

- As linhas de analitos dentro de cada seção passaram a alternar entre fundo
  branco e verde-pastel suave para facilitar a leitura.

## 12/10/2026 — Simplificação dos dados de ModeloExameAnalito

- Removida a apresentação duplicada do nome de `Analito` nos cards.
- Cada linha agora usa somente `DsRotulo`, `VrRefMinimo` e `VrRefMaximo`; se
  presente, `DsTecnica` é exibida abaixo do rótulo em itálico.
- A compilação de produção do frontend foi concluída com sucesso.

## 12/10/2026 — Controllers do catálogo de exames

- Foram criadas as units `LabVet.Controllers.Analito`,
  `LabVet.Controllers.AnimalGrupo`, `LabVet.Controllers.ExameCategoria`,
  `LabVet.Controllers.Exame`, `LabVet.Controllers.ExameAnalito`,
  `LabVet.Controllers.ModeloExame` e
  `LabVet.Controllers.ModeloExameAnalito`.
- Cada controller converte JSON para o model correspondente, delega as regras
  ao service e traduz erros de validação e de recurso não encontrado para HTTP
  400 e 404; erros não tratados retornam HTTP 500 sem expor detalhes internos.
- As rotas de exclusão aplicam inativação lógica e cada recurso recebeu a rota
  `POST /:id/reativar`.
- As novas units foram registradas simultaneamente em `backend/LabVet.dpr` e
  `backend/LabVet.dproj`, incluindo a unit técnica comum
  `LabVet.Controllers.Base`.
- A especificação de rotas foi atualizada. A compilação Win64 e a validação
  HTTP contra `Labvet V1` permanecem pendentes no ambiente Delphi local.

## 12/10/2026 — Correção de compilação dos controllers

- Corrigida a declaração de `LInput` no procedimento `Save` de
  `LabVet.Controllers.Analito`, que impedia a compilação da unit.
- Eliminado o hint de variável não usada no service de `ExameAnalito`.
- As units novas de controller foram convertidas para CRLF, formato requerido
  pelo RAD Studio.

## 12/10/2026 — Branch de controllers e frontend de exames

- Foi criado o branch `codex/controllers-e-frontend-de-exames` a partir de
  `main` para a próxima etapa do módulo de exames.
- O checklist do projeto passou a exigir, no início de cada sessão, a decisão
  explícita entre criar um branch novo ou continuar no branch atual.

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
