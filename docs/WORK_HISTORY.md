# LabVet — Histórico de Trabalho

## Próximas prioridades — 22/10/2026

- Retomar a modelagem de dados de atendimentos e laudos.

## 22/10/2026 — Seções e referências dos analitos do Modelo de Exame

- O editor passou a identificar o tipo de valor do analito e a tratar as
  referências de inteiro, decimal e caractere conforme esse tipo.
- Limites convencionais e percentuais são validados antes do envio; decimais
  recebem formatação brasileira de duas casas ao concluir a edição do campo.
- Os itens agora são agrupados em painéis por seção. A convenção `SN <número>`
  organiza painéis silenciosos em ordem numérica e itens sem seção aparecem no
  painel final **Sem seção**.
- Os cartões exibem as referências à direita, com percentual antes da faixa
  convencional.
- Validação: `npm run build` do frontend concluiu sem erros de TypeScript ou
  Vite. O lint não reportou erros; os avisos existentes permanecem em outras
  telas e no carregamento da lista de modelos.
- Publicação: o container de produção local foi reconstruído e reiniciado. A
  confirmação do bundle servido em `127.0.0.1:8081` encontrou os agrupamentos
  por seção e o editor de valores de referência; o healthcheck da API retornou
  `{"status":"ok"}`.
- Ajuste visual posterior: os cartões passaram a exibir a técnica abaixo do
  nome, os valores convencionais sem o prefixo `Vr` e a unidade à direita da
  faixa. O tipo de valor saiu do cartão e permanece no painel de edição; os
  valores decimais existentes são apresentados com duas casas e vírgula ao
  abrir a edição.
- A revisão visual foi compilada e publicada no container local; o bundle
  ativo e o healthcheck da API foram conferidos após a reinicialização.
- Auditoria de tipos: a base oficial não contém analitos sem tipo válido. Antes
  da correção do leucograma, eram 19 inteiros, 30 decimais e 25 de caractere;
  também não há vínculos ativos de analitos de modelo que apontem para cadastro
  ou vínculo de exame inativo/incompatível.
- Os valores convencionais do cartão foram organizados em colunas estáveis de
  mínimo, separador, máximo e unidade; ausência de técnica passou a usar
  `—`. A revisão foi compilada e publicada no frontend local com healthcheck
  da API confirmado.
- A revisão do leucograma confirmou Bastões, Leucócitos e Mielócitos como
  inteiros; Metamielócitos, Segmentados, Linfócitos, Monócitos e Eosinófilos
  já estavam corretamente classificados. Basófilos permanece caractere pela
  referência textual `raros`.
- A migration 017 foi aplicada com sucesso na base oficial e registra a
  correção dos três tipos no catálogo. A tela passou a salvar valores inteiros
  sem agrupador de milhar, mantendo o valor numérico íntegro entre edição e
  API. O total atual é de 22 inteiros, 30 decimais e 22 de caractere.
- A faixa percentual passou a ocupar o par de colunas à esquerda da faixa
  convencional, em uma grade mais compacta. A atualização foi publicada no
  frontend local e o healthcheck da API foi confirmado.
- Os traços separadores foram removidos dos cartões. Cada painel passou a ter
  os cabeçalhos `Vr Min`, `Vr Max` e `Und` alinhados às referências, com `Per
  Min` e `Per Max` quando a seção possui percentual; as colunas de valores e
  percentuais foram ampliadas. A compilação e a publicação local foram
  confirmadas pelo healthcheck da API.
- A coluna de unidade foi ampliada para acomodar unidades extensas. A migration
  018 foi aplicada na base oficial e alterou somente `ANA-PROTEINAS`
  (Proteínas) para o tipo decimal. A publicação local e o healthcheck da API
  foram confirmados.
- O logo do LabVet no menu lateral passou a ocupar toda a largura útil do
  cabeçalho, com altura proporcional à imagem. A publicação local e o
  healthcheck da API foram confirmados.
- A página de login foi simplificada para um formulário centralizado. O painel
  institucional lateral foi removido e o logo passou a ter a largura dos
  campos de e-mail e senha. A publicação local e o healthcheck da API foram
  confirmados.
- O logo da página de login passou a recortar o excesso de área branca sem
  deformar a marca, e o formulário foi deslocado para mais próximo do topo. A
  publicação local e o healthcheck da API foram confirmados.
- O logo do cabeçalho lateral também passou a usar recorte proporcional, com
  altura reduzida e a largura útil preservada. A publicação local e o
  healthcheck da API foram confirmados.
- Os cartões de analitos do modelo passaram a exibir o nome sem unidade na
  identificação. A unidade fica exclusivamente após os valores, na coluna
  `Und`, inclusive para rótulos históricos que a traziam entre parênteses. A
  publicação local e o healthcheck da API foram confirmados.
- O editor de Modelo de Exame recebeu o comando **Gerar PDF**. Ele abre uma
  impressão A4 vertical pronta para salvar como PDF, que reúne os dados do grupo de
  animal, do modelo, do exame vinculado e dos analitos nas mesmas seções e
  colunas da edição, sem comandos de manutenção. A impressão também pode ser
  gerada antes da inclusão de analitos. A publicação local e o healthcheck da
  API foram confirmados após esta atualização.

## 21/10/2026 — Rodapé e rolagem da lista de modelos por grupo

- A página de modelos aberta a partir do grupo de animal foi migrada para o
  padrão de pesquisa e seleção dos demais cadastros.
- Cabeçalho, filtros e rodapé com seleção/paginação são fixos; a rolagem fica
  limitada à grade de modelos, inclusive no celular.
- Validação: `npm run build` do frontend concluiu TypeScript e Vite sem erros.
- Publicada a correção no ambiente local de produção; o healthcheck do proxy
  respondeu HTTP 200 com `{"status":"ok"}`.

## 21/10/2026 — Manutenção de Modelos de Exames por grupo

- A página inicial de Modelo de Exames agora parte da seleção de um grupo de
  animais. A lista filtrável do grupo é uma página própria, o que preserva a
  usabilidade em telas móveis.
- A lista permite incluir, selecionar, alterar e inativar o modelo escolhido.
- Criado o editor do modelo, com manutenção livre dos campos de
  `modeloexames` e dos itens de `modeloexameanalitos` após a gravação do
  cabeçalho.
- As informações do Exame e do Analito de origem são mostradas como consulta;
  a tela não altera os cadastros de Exames nem de Analitos.
- Validação: `npm run build` do frontend concluiu TypeScript e Vite sem erros.
- Publicado no ambiente local de produção; o healthcheck do proxy respondeu
  HTTP 200 com `{"status":"ok"}`.

## 21/10/2026 — Cadastro hierárquico de Grupos de Animais

- Implementada a rota `/exames/grupos-animais`, com árvore navegável da
  hierarquia e painel de manutenção dos grupos selecionados.
- A seleção de um nó mostra o grupo e seus descendentes na grade. A árvore
  permite expandir e recolher ramos sem perder a seleção.
- Incluídos pesquisa, filtro de situação, paginação, seleção por caixa ou
  toque contínuo, inclusão, edição, inativação e reativação.
- O editor apresenta a escolha de grupo pai na própria hierarquia e bloqueia
  o grupo em edição e seus descendentes, evitando ciclos no cliente.
- A rota de listagem de grupos passou a aceitar `?incluirInativos=true`, em
  alinhamento com os demais cadastros do catálogo. A disponibilização dessa
  parte depende da compilação do backend Delphi pela IDE.
- Validação: `npm run build` do frontend concluiu TypeScript e Vite sem erros.
- Publicada a interface no ambiente local de produção; o healthcheck do proxy
  respondeu HTTP 200 com `{"status":"ok"}`.

## 21/10/2026 — Valor monetário e mensagens de erro de Exames

- O campo de valor passou a preservar sempre duas casas decimais, inclusive em
  valores inteiros, e mantém pontos de milhar e vírgula decimal durante a
  edição.
- Corrigida a leitura de respostas de erro cujo campo `error` é um texto, para
  apresentar mensagens com acentos em vez do JSON com escapes Unicode.
- O parser Delphi de `valor` foi ajustado para interpretar números JSON com
  ponto decimal de forma independente da configuração regional do servidor.
- Validação: `npm run build` do frontend concluiu TypeScript e Vite sem erros.

## 21/10/2026 — Formulário e moeda de Exames no celular

- Reorganizado o formulário de Exames em Código/Categoria, Nome e
  Quantidade/Valor, mantendo a composição complementar abaixo dessas linhas.
- Criado o campo de moeda reutilizável com a interação do Itriax: pontos nos
  milhares, vírgula decimal e interpretação de ponto ou vírgula como início
  da fração durante a digitação.
- Corrigida a contenção horizontal do painel rolável de edição, para que uma
  lista de analitos não amplie a área de formulário no celular.
- Validação: `npm run build` do frontend concluiu TypeScript e Vite sem erros.

## 21/10/2026 — Ajuste móvel dos analitos do exame

- Corrigida a largura dos painéis e cartões de analitos no editor móvel,
  impedindo que seu conteúdo ultrapasse a área útil.
- A remoção passou a usar apenas um botão compacto com ícone, alinhado à
  direita de cada cartão de analito.

## 21/10/2026 — Cadastro de Exames e analitos vinculados

- Implementada a rota `/exames` com busca, filtros de categoria e situação,
  ordenação, paginação local, seleção por caixa ou toque contínuo, inclusão,
  edição, inativação e reativação.
- O editor separa a identificação do exame de sua composição e valor. Depois
  de salvo o cabeçalho, apresenta o painel **Analitos do exame**, com seletor
  de analitos ativos, pesquisa nos vínculos, inclusão, remoção funcional e
  reativação de vínculos históricos.
- As APIs de categorias, exames, analitos e vínculos passaram a aceitar
  `?incluirInativos=true`, habilitando os filtros de inativos e a reativação
  de um vínculo sem duplicá-lo.
- Validação: `npm run build` do frontend concluiu TypeScript e Vite sem erros.
- Publicada a interface no ambiente local de produção; o healthcheck do proxy
  respondeu HTTP 200 com `{"status":"ok"}`. A confirmação da compilação do
  controller Delphi fica para a IDE, pois a edição Community não oferece
  validação por linha de comando neste ambiente.

## 21/10/2026 — Pesquisa e edição de Categorias de Exame

- Implementada a rota `/exames/categorias` com busca, filtro de situação,
  ordenação, paginação, seleção por caixa ou toque contínuo e rodapé fixo.
- Incluídos formulário de criação/edição com o campo obrigatório Nome, e as
  operações autenticadas de inclusão, alteração, inativação e reativação.
- O nome enviado à API remove espaços excedentes, conforme a especificação.
- Validação: `npm run build` do frontend concluiu TypeScript e Vite sem erros.
- Publicada a versão no ambiente local de produção; o healthcheck do proxy
  respondeu HTTP 200 com `{"status":"ok"}`.

## 21/10/2026 — Imagem PNG do diagrama ER

- Convertido o diagrama ER de exames e modelos para
  `docs/diagrama-er-exames-modelos.png`.
- Validação: a imagem PNG foi aberta e conferida visualmente.

## 21/10/2026 — Navegação e diagrama ER de exames

- Corrigido o destaque dos itens do menu para que cada submenu seja ativo
  apenas na sua rota exata.
- Restaurada a exibição do botão de primeira página na paginação móvel.
- Criado `docs/diagrama-er-exames-modelos.svg`, com as relações entre
  categorias, exames, analitos, grupos de animais, modelos e itens de modelo.
- Validação: `npm run build` do frontend concluiu TypeScript e Vite sem erros.
- Publicada a versão no ambiente local de produção; o healthcheck do proxy
  respondeu HTTP 200 com `{"status":"ok"}`.

## 21/10/2026 — Lista móvel fixa e seleção por toque contínuo

- Delimitada a página de pesquisa e seleção pela viewport para manter título,
  filtros e rodapé fixos; a rolagem ficou restrita à grade de cartões.
- Implementada a alternância de seleção do analito após 0,3 segundo de toque
  contínuo no cartão; o gesto é cancelado quando o usuário move o dedo.
- Validação: `npm run build` do frontend concluiu TypeScript e Vite sem erros.
- Publicada a versão no ambiente local de produção; API e frontend foram
  validados pelo healthcheck do proxy.

## 21/10/2026 — Área de edição móvel fixa

- Delimitada a página de edição pela viewport para manter o cabeçalho e as
  ações de Cancelar/Salvar sempre visíveis.
- A rolagem foi restrita à área que contém o painel de campos do formulário.
- Validação: `npm run build` do frontend concluiu TypeScript e Vite sem erros.
- Publicada a versão no ambiente local de produção; API e frontend foram
  validados pelo healthcheck do proxy.

## 21/10/2026 — Compactação da lista móvel de Analitos

- Reduzida a altura dos cartões móveis de Analitos e removido o espaço vertical
  entre as linhas de código/nome e unidade/tipo.
- O painel de filtros da página passou a iniciar recolhido.
- Validação: `npm run build` do frontend concluiu TypeScript e Vite sem erros.
- Publicada a versão no ambiente local de produção; API e frontend foram
  validados pelo healthcheck do proxy.

## 21/10/2026 — Ajuste da listagem móvel de Analitos

- Reorganizada a visualização móvel de cada analito: o código ocupa a primeira
  linha em uma coluna mais larga e o nome passou para a segunda linha.
- Unidade de medida e tipo de valor passaram a ocupar, respectivamente, a
  primeira e a segunda linha da coluna direita, ambas alinhadas à direita.
- Validação: `npm run build` do frontend concluiu TypeScript e Vite sem erros.
- Publicada a versão no ambiente local de produção; o healthcheck pelo proxy
  em `127.0.0.1:8081` respondeu HTTP 200 com `{"status":"ok"}`.

## 21/10/2026 — Consolidação da primeira entrega de cadastros

- Consolidado o padrão compartilhado de pesquisa/seleção e edição no cadastro
  de Analitos, com grade rolável, painéis fixos, ordenação e paginação local
  de 25 registros.
- Confirmada a organização definitiva do menu **Exames** e o redirecionamento
  de Modelo de Exames para a nova rota.
- Recompilado e publicado o frontend no ambiente local de produção.
- Validação: build TypeScript/Vite concluído e healthcheck do proxy retornando
  HTTP 200 em `127.0.0.1:8081`; o lint mantém somente avisos preexistentes em
  `ModeloExamesPage`.

## 20/10/2026 — Refinamento de alinhamento da grade de Analitos

- Alinhadas as larguras dos painéis de título, filtros, grade e rodapé.
- Removido o atalho de atualização que ocupava espaço entre a grade e o
  rodapé; o espaçamento inferior da grade foi reduzido.
- Ampliada a coluna Código para 350px, mantendo códigos longos legíveis.
- Validação: `npm run build` concluído sem erros; o lint conserva somente os
  avisos preexistentes na página de Modelo de Exames.

## 20/10/2026 — Rolagem e paginação da listagem de Analitos

- A área de pesquisa/seleção passou a fixar título, filtros e rodapé no limite
  da página, restringindo a rolagem ao painel da grade.
- Implementada paginação local de 25 registros por página, com controles de
  início, anterior, próxima e última página, estado desabilitado nos limites e
  total de registros compatível com os filtros aplicados.
- A seleção de todos agora se limita aos registros visíveis da página atual.
- Validação: `npm run build` concluiu sem erros; o lint conserva apenas dois
  avisos preexistentes na página de Modelo de Exames.

## 20/10/2026 — Padrão de cadastros e implementação de Analitos

- Criados os componentes reutilizáveis de pesquisa/seleção e edição para as
  páginas administrativas do grupo **Exames**.
- Implementada a rota `/exames/analitos`, com carregamento autenticado,
  filtros por texto, situação e tipo de valor, ordenação pelos cabeçalhos,
  seleção de registros e ações de inclusão, edição, inativação e reativação.
- A edição apresenta painel com rolagem, identificação e configuração
  laboratorial; os dados são enviados aos contratos existentes de Analito.
- Criado o grupo **Exames** no menu lateral com os cinco submenus definidos;
  Modelo de Exames foi removido de Cadastros, movido para `/exames/modelos` e
  a rota antiga passou a redirecionar para a nova.
- Incluída a imagem do analito em `frontend/public/images`, para ser servida
  pelo próprio Vite/Nginx nas páginas reais.
- Validação: `npm run build` do frontend concluiu TypeScript e Vite sem erros.
  A validação navegada depende de uma sessão autenticada e da API em execução.

## 20/10/2026 — Especificação das páginas de cadastro de exames

- Criado o branch `paginas-cadastros`, conforme solicitado pelo usuário.
- Criada a especificação `spec-frontend-cadastros-exames.md` para os cadastros
  de categorias, exames e seus analitos, grupos de animais, analitos e modelos
  de exames.
- Definido o novo grupo de navegação **Exames**, com cinco submenus, a remoção
  de Modelo de Exames de **Cadastros** e o redirecionamento da rota antiga.
- A especificação foi limitada aos endpoints já existentes: a manutenção de
  cabeçalho e itens do modelo é explicitamente não transacional até que o
  backend ofereça um endpoint composto.
- Validação: contratos JSON e rotas foram conferidos nas models e controllers
  Delphi; não houve alteração de código nem execução de migrations.

## 17/10/2026 — Inicialização conjunta da API e do frontend

- Usuário confirmou o restabelecimento do login após iniciar a API.
- Atualizado o iniciador para reutilizar a API do mesmo executável na porta
  9010 ou iniciá-la sem janela adicional, aguardar os containers e verificar
  a API pelo proxy antes de abrir o domínio HTTPS. Adicionado `--no-browser`.
- Corrigidas as aspas do healthcheck do PostgreSQL para `Labvet V1`.
- Atualizado o guia de produção com comportamento e requisitos do iniciador.
- Validação: execução real com `--no-browser` terminou com código zero,
  reutilizou a API e confirmou banco e frontend saudáveis e HTTP 200 pelo
  proxy. A partida da API ausente foi validada na recuperação anterior;
  esse caminho do script foi revisado sem parar a API durante o teste.

## 17/10/2026 — Restabelecimento da API de produção local

- Sessão mantida no branch `main`, conforme autorização do usuário.
- Investigado erro de login: a API Delphi estava parada e o proxy local e
  o endereço público retornavam HTTP 502. Frontend e PostgreSQL estavam
  saudáveis, com processos do Cloudflare Tunnel em execução.
- Iniciado `backend/LabVet.exe` com a configuração `.env.producao.local`.
- Validação: `/api/v1/health` respondeu HTTP 200 e `{"status":"ok"}` na
  API local, no proxy local e em `https://app.labvet.app`.
- Login com credenciais reais não foi validado. A alteração preexistente
  na migration 014 foi preservada.

## 15/10/2026 — Planejamento da próxima sessão

- Prioridades definidas para 16/10/2026:
  1. revisar e finalizar o schema de `atendimentos`, `laudos`,
     `laudoanalitos` e `laudonotas` antes de aplicar a migration 014;
  2. implementar a importação vinculada aos modelos de exame e analitos;
  3. criar as consultas de atendimentos e laudos.

## 15/10/2026 — Recuperação de referências percentuais importadas

- A migration 015 foi aplicada na base oficial `Labvet V1`, recuperando 660
  faixas numéricas que haviam permanecido somente em `dsreferencia`.
- Criada e aplicada a migration 016 para o formato de quatro valores
  importado (`percentual mínimo`, `percentual máximo`, `mínimo convencional`
  e `máximo convencional`). Foram recuperadas 94 referências percentuais de
  sete analitos hematológicos e habilitado `fgpercentual` para esses analitos.
- A migration preserva limites convencionais já existentes e só recupera uma
  nova faixa convencional quando ela está ordenada. Um registro de Linfócitos
  com origem `12 54 1000 - 672` recebeu os percentuais 12% a 54%, mantendo os
  limites convencionais vazios, pois a fonte contém a faixa invertida.
- A execução foi simulada em transação revertida antes da aplicação e a
  validação posterior confirmou 94 referências percentuais persistidas, sem
  violação dos gatilhos do banco.

## 14/10/2026 — Recuperação de referências numéricas importadas

- Identificada carga incompleta nos modelos de 2026: faixas como
  `0 2.3 - 3.1` ficaram preservadas em `dsreferencia`, mas sem limites mínimo
  e máximo estruturados.
- Criada a migration 015 para recuperar somente faixas numéricas inequívocas,
  preservando referências textuais e os limites já existentes.

## 14/10/2026 — Formatação de referências dos analitos

- A tela de Modelo de Exames passou a carregar os vínculos e o tipo de valor
  do catálogo de analitos para formatar referências corretamente.
- Valores decimais agora são exibidos com duas casas e separador brasileiro;
  inteiros não recebem casas decimais e referências de caractere permanecem
  inalteradas.

## 14/10/2026 — Recompilação da API de modelos de exame

- Identificado que a API em execução havia sido compilada em 12/10 e não
  correspondia ao código-fonte atual do catálogo de modelos e analitos.
- Recompilado e reiniciado `LabVet.exe` no ambiente de produção local.
- Validada a rota autenticada de analitos do modelo 249: HTTP 200, 26 itens e
  referências mínimas e máximas retornadas corretamente (`2.100000` e
  `3.300000` no primeiro item referenciado).

## 14/10/2026 — Preparação de produção local e Cloudflare Tunnel

- Criado o perfil de produção local no `docker-compose.yml`: Nginx compila e
  serve o frontend em `127.0.0.1:8081`, encaminhando `/api` à API Delphi em
  `127.0.0.1:9010` sem expor a API ou PostgreSQL.
- Adicionados o Dockerfile, a configuração Nginx, o exemplo de ambiente e o
  iniciador `deploy/producao/iniciar-producao-local.bat`.
- A sessão de produção usa o cookie `labvetRefreshProducao`, separado do
  ambiente de desenvolvimento. A ativação de `LABVET_COOKIE_SECURE=true` ficou
  documentada como pré-requisito para a publicação em HTTPS pelo Tunnel.
- Incluído `.dockerignore` para manter credenciais, dados locais, binários e
  dependências restauráveis fora do contexto de construção da imagem.
- Docker Desktop construiu a imagem e confirmou o container
  `labvet-frontend-producao` saudável em `127.0.0.1:8081`. Com a API Delphi
  iniciada em `9010`, o healthcheck por `/api/v1/health` respondeu HTTP 200
  com `{"status":"ok"}`.
- Ativado `LABVET_COOKIE_SECURE=true` no ambiente local de produção e criada a
  rota publicada `app.labvet.app` no Cloudflare Tunnel, direcionada para
  `http://127.0.0.1:8081`. A validação externa por HTTPS abriu a tela de
  login; a proteção por Cloudflare Access permanece pendente.

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
