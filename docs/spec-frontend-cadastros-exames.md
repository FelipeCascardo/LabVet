# Especificação — páginas de cadastro de exames

## Objetivo

Implementar no frontend os cadastros que usam o catálogo de exames já
disponibilizado pela API do LabVet: categorias de exames, exames, grupos de
animais, analitos e modelos de exames. As páginas devem atender à manutenção
administrativa do catálogo, incluindo consulta, criação, edição, inativação e
reativação, sem excluir fisicamente dados.

Esta especificação usa os contratos HTTP já expostos. Ela não exige mudança no
schema nem presume a existência do endpoint composto de detalhe de modelo de
exame, que ainda não está disponível.

## Navegação

Criar o grupo **Exames** na barra lateral, logo após **Cadastros** e antes de
**Laboratório**, com os itens abaixo.

| Rótulo | Rota | Finalidade |
| --- | --- | --- |
| Categorias | `/exames/categorias` | Manter as categorias do catálogo. |
| Exames | `/exames` | Manter exames e seus analitos. |
| Grupos de Animais | `/exames/grupos-animais` | Manter a hierarquia usada pelos modelos. |
| Analitos | `/exames/analitos` | Manter os parâmetros laboratoriais reutilizáveis. |
| Modelo de Exames | `/exames/modelos` | Manter modelos, por grupo de animais, e seus analitos configurados. |

Remover **Modelo de Exames** de **Cadastros**. A rota antiga
`/cadastros/modelos-exames` deve redirecionar para `/exames/modelos`, para
preservar favoritos e links já compartilhados. A antiga tela provisória
**Tipos de exames** não deve permanecer no menu; sua finalidade é substituída
pelas cinco páginas deste grupo.

Os itens usam os mesmos padrões visuais da barra lateral atual: grupo
expansível, ícone relacionado ao domínio, estado ativo pela rota e fechamento
do menu em telas pequenas após a navegação.

## Padrões comuns das páginas

Todas as páginas devem ser protegidas pela sessão existente e enviar
`Authorization: Bearer <token>` em cada chamada. A interface deve reutilizar o
layout, a barra superior, botões e estados de carregamento já adotados no
frontend.

- Cabeçalho: ícone do assunto, título da página e painel de ações com
  **Incluir**, **Editar**, **Inativar** e **Reativar**. Não exibir a barra
  global de área de trabalho nesta família de páginas.
- Listagem: busca textual local sobre o resultado da API, filtro **Ativos / Inativos / Todos**, total de itens e ordenação determinística pelos títulos da grade. Enquanto a API não oferecer paginação, a paginação é local, com **25 registros por página**, sobre a lista carregada.
- Área útil: título, filtros e rodapé permanecem fixos; somente a área da
  grade possui rolagem. O rodapé mantém a mesma largura dos demais painéis e
  exibe seleção da página, contador de selecionados, navegação de primeira,
  anterior, próxima e última página, além do retorno à página chamadora.
- Formulário: aberto em modal ou painel lateral; mantém os valores em caso de
  erro e evidencia os campos inválidos junto da mensagem devolvida pela API.
- Ações por registro: editar, inativar e reativar. Inativar requer confirmação
  com o nome do registro; reativar pede confirmação simples. `DELETE` é
  inativação, nunca remoção definitiva.
- Estados: skeleton ou indicador no primeiro carregamento, vazio orientativo,
  erro recuperável com **Tentar novamente** e confirmação não intrusiva após
  uma gravação bem-sucedida.
- Acessibilidade: todos os controles possuem rótulo acessível, foco inicial no
  primeiro campo do formulário, foco devolvido ao acionador no fechamento e
  ações não dependem exclusivamente de cor ou ícone.

## Categorias de Exames

**Rota:** `/exames/categorias`
**Recurso:** `/api/v1/exame-categorias`

A listagem apresenta **Nome**, **Situação** e **Ações**. O formulário de novo
ou edição contém somente:

| Campo | JSON | Obrigatório | Regra da tela |
| --- | --- | --- | --- |
| Nome da categoria | `nome` | Sim | Remover espaços excedentes; até 100 caracteres. |

Chamadas: `GET` para listar, `GET /:id` ao abrir edição, `POST` para criar,
`PUT /:id` para alterar, `DELETE /:id` para inativar e `POST /:id/reativar`
para reativar. Conflitos ou duplicidades devolvidos pela API devem ficar
visíveis no formulário, sem mensagem genérica.

## Exames e analitos do exame

**Rota:** `/exames`
**Recursos:** `/api/v1/exames`, `/api/v1/exame-categorias`,
`/api/v1/exame-analitos` e `/api/v1/analitos`

A lista de exames exibe **Código**, **Nome**, **Categoria**, **Tipo**
(unitário/pacote), **Quantidade**, **Valor**, **Situação** e **Ações**. O
filtro de categoria deve considerar as categorias ativas; o registro editado
pode continuar exibindo sua categoria inativa.

O formulário de cabeçalho usa o contrato abaixo.

| Campo | JSON | Obrigatório | Regra da tela |
| --- | --- | --- | --- |
| Categoria | `idCategoria` | Sim | Seletor com categorias ativas. |
| Código | `codigo` | Sim | Até 50 caracteres; não normalizar códigos como `44/45` ou `7.35`. |
| Nome | `nome` | Sim | Até 200 caracteres. |
| Quantidade | `quantidade` | Sim | Inteiro maior ou igual a 1; inicia em 1. |
| Valor | `valor` | Não | Moeda BRL; enviar `null` quando não informado. |
| Exame unitário | `primario` | Sim | Inicia marcado. |
| Exame-pai | `idExamePai` | Não | Disponível apenas para não unitário; não pode ser o próprio exame. |

Depois que o exame existir, a edição mostra a aba ou seção **Analitos do
exame**. Ela apresenta nome, código, unidade, tipo de valor, situação do
vínculo e ações. **Adicionar analito** abre um seletor pesquisável de analitos
ativos que ainda não estão vinculados, criando `POST /exame-analitos` com
`{ "idExame": ..., "idAnalito": ... }`. A remoção funcional usa
`DELETE /exame-analitos/:id`; um vínculo já conhecido pode ser reativado por
`POST /exame-analitos/:id/reativar` em vez de criar duplicata.

O botão de analitos fica desabilitado no cadastro novo até a confirmação do
exame, com a orientação de salvar o cabeçalho primeiro.

## Grupos de Animais

**Rota:** `/exames/grupos-animais`
**Recurso:** `/api/v1/animal-grupos`

Esta página combina uma árvore à esquerda com a tabela de manutenção à direita.
A árvore usa `idGrupoPai`, é ordenada alfabeticamente em cada nível e mostra
os inativos apenas quando o filtro permitir. Selecionar um nó aplica a busca
na tabela, mas não restringe a criação de outro grupo.

| Campo | JSON | Obrigatório | Regra da tela |
| --- | --- | --- | --- |
| Nome | `nome` | Sim | Nome claro do grupo. |
| Descrição | `descricao` | Não | Texto explicativo curto. |
| Grupo pai | `idGrupoPai` | Não | Seletor em árvore; não listar o próprio registro nem seus descendentes na edição. |

A lista contém **Nome**, **Grupo pai**, **Descrição**, **Situação** e
**Ações**. Ao tentar inativar um grupo, informar que modelos que o referenciem
preservam o histórico; eventuais bloqueios são definidos e devolvidos pela
API.

## Analitos

**Rota:** `/exames/analitos`
**Recurso:** `/api/v1/analitos`

A tabela apresenta **Código**, **Nome**, **Técnica**, **Unidade de medida**,
**Tipo de valor**, **Aceita percentual**, **Situação** e **Ações**.

| Campo | JSON | Obrigatório | Regra da tela |
| --- | --- | --- | --- |
| Código | `codigo` | Sim | Código único do catálogo. |
| Nome | `nome` | Sim | Nome do parâmetro exibido ao usuário. |
| Técnica | `tecnica` | Não | Método ou técnica laboratorial. |
| Unidade de medida | `unidadeMedida` | Não | Ex.: `mg/dL`, `g/dL` ou `%`. |
| Tipo de valor | `tipoValor` | Sim | Seletor: `1` Inteiro, `2` Decimal, `3` Caractere. |
| Aceita referência percentual | `percentual` | Sim | Interruptor; só habilita percentuais em configurações de modelo. |

O formulário deve explicar que o tipo de valor não formata apenas a tela: ele
define a validação das referências em modelos. A troca de tipo ou do indicador
percentual em um analito com uso já existente deve exibir o alerta de impacto e
confiar a decisão final à validação da API.

## Modelo de Exames

**Rota:** `/exames/modelos`
**Recursos:** `/api/v1/modelos-exames`, `/api/v1/modelos-exames-analitos`,
`/api/v1/animal-grupos`, `/api/v1/exames`, `/api/v1/exame-analitos` e
`/api/v1/analitos`

A página preserva a organização visual de três painéis já existente:

1. árvore de grupos de animais;
2. modelos do grupo selecionado;
3. analitos do modelo selecionado, agrupados por seção e ordenados por
   `ordem`.

O cabeçalho ganha as ações **Novo modelo**, **Editar modelo** e **Inativar /
Reativar modelo**. O formulário de modelo usa:

| Campo | JSON | Obrigatório | Regra da tela |
| --- | --- | --- | --- |
| Código | `codigo` | Sim | Código único do modelo. |
| Nome | `nome` | Sim | Nome descritivo. |
| Exame | `idExame` | Não | Seletor de exames ativos; necessário para incluir analitos. |
| Grupo de animais | `idAnimalGrupo` | Não | Seletor em árvore. |
| Faixa etária | `faixaIdade` | Não | Texto livre conforme a origem do laboratório. |
| Arquivo de origem | `arquivoOrigem` | Não | Apenas nome/referência do arquivo, sem upload nesta entrega. |

### Manutenção dos analitos de um modelo

Após salvar o cabeçalho, o painel direito passa a permitir inclusão e edição de
itens. **Adicionar analito** lista somente vínculos ativos de
`exame-analitos` do exame escolhido; não cria vínculo de exame nesta página.
Se o exame ainda não tiver analitos, a interface orienta a configurá-los na
página **Exames**.

| Campo | JSON | Obrigatório | Regra da tela |
| --- | --- | --- | --- |
| Vínculo exame–analito | `idExameAnalito` | Sim | Seleção única entre os vínculos ativos do exame. |
| Seção | `secao` | Não | Ex.: Eritrograma ou Leucograma. |
| Ordem | `ordem` | Sim | Inteiro positivo e único dentro do modelo. |
| Rótulo | `rotulo` | Não | Sobrescreve a apresentação quando informado. |
| Técnica | `tecnica` | Não | Sobrescreve a técnica do catálogo quando informado. |
| Unidade de medida | `unidadeMedida` | Não | Sobrescreve a unidade do catálogo quando informado. |
| Referência livre | `referencia` | Não | Texto complementar. |
| Referência mínima/máxima | `referenciaMinima`, `referenciaMaxima` | Não | Validadas no cliente conforme o tipo do analito. |
| Percentual mínimo/máximo | `referenciaPercentualMinima`, `referenciaPercentualMaxima` | Não | Visíveis somente quando `percentual` do analito estiver ativo; de 0 a 100, até quatro casas. |

Para inteiro, as referências convencionais aceitam somente inteiros; para
decimal, aceitam número com vírgula ou ponto e são enviados no formato
numérico aceito pela API; para caractere, permanecem texto. O mínimo não pode
ser maior que o máximo quando ambos forem numéricos. Os limites percentuais
também obedecem a essa ordenação.

Os itens usam `POST /modelos-exames-analitos`, `PUT /:id`, `DELETE /:id` e
`POST /:id/reativar`. O backend atual não possui gravação transacional do
agregado: o frontend deve salvar primeiro o cabeçalho e depois cada item,
informando o resultado de cada operação e recarregando os dados após sucesso.
Não deve simular uma única confirmação atômica para ações que são várias
requisições independentes.

## Contrato HTTP e tratamento de respostas

Os recursos de cadastro seguem a mesma convenção:

| Ação | Método e rota |
| --- | --- |
| Listar | `GET /api/v1/<recurso>` |
| Consultar | `GET /api/v1/<recurso>/:id` |
| Criar | `POST /api/v1/<recurso>` |
| Alterar | `PUT /api/v1/<recurso>/:id` |
| Inativar | `DELETE /api/v1/<recurso>/:id` |
| Reativar | `POST /api/v1/<recurso>/:id/reativar` |

`modelos-exames-analitos` usa `GET /api/v1/modelos-exames-analitos?idModeloExame=<id>` para listar itens de um modelo. Os corpos e respostas mantêm os
nomes JSON emitidos pelas classes Delphi; a camada de serviço TypeScript deve
centralizar `request`, normalização de erros e tipos compartilhados.

Erros `400` ficam associados ao formulário; `404` pede recarregamento da
lista; `409`, quando disponibilizado pela API, explica o conflito sem descartar
os valores digitados; `401` e `403` seguem o fluxo global de autenticação.

## Organização sugerida do frontend

```text
frontend/src/
├── app/navigation.ts                 # grupo Exames e rotas
├── features/exames/
│   ├── shared/                       # tabela, filtros, situação e diálogos reutilizáveis
│   ├── categorias/
│   ├── exames/                       # inclui a seção de exame–analito
│   ├── grupos-animais/
│   ├── analitos/
│   └── modelos/                      # evolução da página atual de três painéis
└── services/
    └── examesApi.ts                  # contratos e chamadas do catálogo
```

`ModeloExamesPage` e `modeloExamesApi.ts` podem ser movidos gradualmente para
essa estrutura, preservando os tipos e a formatação de referências já
validados. Componentes de domínio não devem depender de textos ou rotas de
**Cadastros**.

## Critérios de aceite

- O menu **Exames** contém exatamente os cinco submenus definidos e o modelo
  não aparece mais em **Cadastros**.
- A rota antiga de modelos redireciona corretamente para a nova rota.
- Cada página lista, pesquisa, cria, edita, inativa e reativa seu recurso
  usando a API autenticada correspondente.
- Exames permitem administrar seus vínculos de analitos, sem duplicar o mesmo
  analito ativo.
- Grupos respeitam a hierarquia e impedem ciclos na interface.
- Modelos mantêm a navegação grupo → modelo → analitos e só oferecem analitos
  vinculados ao exame selecionado.
- As referências do modelo obedecem ao tipo e ao indicador percentual do
  analito, sem contrariar as validações do backend.
- Estados de carregamento, vazio, erro e confirmação são acessíveis e não
  descartam dados de formulário por falha da API.

## Fora do escopo

- Alterar migrations, schema, units Delphi ou regras do backend.
- Criar o endpoint composto/transacional de detalhe e gravação do modelo.
- Upload ou importação do arquivo de origem.
- Gestão de composição definitiva de pacotes de exames.
