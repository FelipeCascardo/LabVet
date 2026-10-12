# Análise dos modelos de laudos de 2026

## Escopo e método

Foram lidos 161 modelos `.xlsx` na pasta `Importação/Laudos 2026`. A classificação de animal abaixo reproduz a organização operacional do laboratório, sem convertê-la para taxonomia científica. A extração considera títulos, parâmetros, valores de referência e técnicas presentes nas planilhas.

Foram identificadas **1991 ocorrências de analitos** nos modelos. Uma ocorrência representa a presença de um parâmetro em um modelo; o mesmo analito pode aparecer em vários modelos.

Quatro arquivos `.xls` não foram lidos estruturalmente pelo leitor disponível e estão listados como pendência de revisão manual no fim deste documento.

## Cobertura por tipo de animal do laboratório

| Tipo de animal / agrupamento operacional | Modelos |
| --- | ---: |
| Sem agrupamento | 1 |
| Bovino | 4 |
| Bubalino | 1 |
| Caprino | 6 |
| Cão | 36 |
| Equinos | 11 |
| Gato | 30 |
| Ovino | 4 |
| Silvestres > Aves | 18 |
| Silvestres > Mamíferos | 35 |
| Silvestres > Peixes | 2 |
| Silvestres > Répteis | 10 |
| Suino | 3 |

## Estrutura observada nos laudos

Os modelos geralmente apresentam o bloco **Parâmetros avaliados**, uma área de resultado, uma ou mais colunas de **Valores de Referência** e, em muitos casos, uma linha seguinte com a técnica de medição. Foram encontradas referências numéricas, textuais e mistas.

| Forma de referência identificada | Ocorrências de analitos |
| --- | ---: |
| misto | 111 |
| numérico | 1795 |
| texto | 85 |

As técnicas mais frequentes identificadas foram:

| Técnica | Ocorrências |
| --- | ---: |
| Cinético UV automatizado | 434 |
| Colorimétrico automatizado | 410 |
| Eletrodo ion-seletivo | 10 |
| Eletrodo ion seletivo | 3 |
| Cinético automatizado | 3 |

Há **19 modelos** com indicação textual de faixa ou condição de idade, como `adulto`, `filhote` ou referências em meses. Essas indicações vêm do nome do modelo e/ou do conteúdo da planilha.

## Comparação com o modelo atual

| Tabela | Situação atual | Evidência dos modelos | Ajuste necessário |
| --- | --- | --- | --- |
| `exames` | Representa o catálogo comercial. | Um mesmo exame possui vários modelos por tipo de animal e faixa de idade. | Criar entidade de modelo de laudo vinculada ao exame. |
| `analitos` | Possui nome, código, técnica, unidade e `tpvalor`. | Técnicas podem mudar conforme o modelo e alguns parâmetros têm resposta textual ou mista. | Manter a técnica padrão no analito, mas permitir técnica e rótulo de exibição no vínculo com o modelo. |
| `exameanalitos` | Liga exame e analito; referências mínima e máxima são `NUMERIC`. | Há 85 ocorrências textuais e 111 mistas; valores de referência variam por agrupamento operacional de animal e idade. | Não usar apenas limites numéricos. Mover as referências para uma estrutura própria, com texto livre e contexto de modelo, animal e idade. |

## Modelo recomendado para a próxima revisão

1. Manter `exameanalitos` como a associação base entre um exame e um analito.
2. Criar `tipoanimais` para os agrupamentos internos do laboratório, por exemplo `Cão`, `Bovino` e `Silvestres > Aves`. Esse cadastro não é uma tabela taxonômica.
3. Criar `modeloslaudos`, ligado a `exames` e `tipoanimais`, com nome do modelo e a faixa etária descritiva original.
4. Criar `modeloexameanalitos` para os parâmetros que aparecem em cada modelo. A tabela deve registrar `dssecao`, `nrexibicao`, `dsrotulo`, `dstecnica`, `dsreferencia`, `vrrefminimo` e `vrrefmaximo`.
5. Preservar `dsreferencia` como `TEXT`, mesmo quando houver limites numéricos. Os limites numéricos continuam úteis para cálculo, mas não conseguem representar referências como `negativo`, `ausente`, observações e faixas condicionais.
6. Para idade, registrar primeiro `dsfaixaidade` conforme o modelo original. A normalização em mínimo, máximo e unidade deve ser feita após validação do laboratório.

A regra de unicidade atual de `exameanalitos (idexame, idanalito)` deve permanecer para o vínculo base. As várias faixas de referência devem existir em `modeloexameanalitos`, e não como linhas duplicadas sem contexto em `exameanalitos`.

## Inventário dos modelos `.xlsx`

Cada item abaixo é um modelo de laudo. `Análitos` reproduz os parâmetros identificados automaticamente, incluindo referência e técnica quando presentes.

### Bovino

#### CHECKUP_BOV_Ad - Labvet 2026

- Arquivo: `Bovino 2026\CHECKUP_BOV_Ad - Labvet 2026.xlsx`
- Tipo de animal: Bovino
- Idade: Não indicada
- Analitos identificados: 11
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 2.5 - 3.8; tipo: numérico; técnica: Colorimétrico automatizado
  - AST (U/L) — referência: 60 - 125; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 - 1.6; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 8 - 11.4; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 - 350; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0.5 - 2.2; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 6 - 17.4; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 309 - 938; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 5.6 - 8; tipo: numérico; técnica: Cinético UV automatizado
  - Uréia (mg/dL) — referência: 10 - 25; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 5.8 - 7.8 #REF!; tipo: misto; técnica: Colorimétrico automatizado
#### HEM_BOV_Ad - Labvet 2026

- Arquivo: `Bovino 2026\HEM_BOV_Ad - Labvet 2026.xlsx`
- Tipo de animal: Bovino
- Idade: Não indicada
- Analitos identificados: 17
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 5 - 10; tipo: numérico
  - Hemoglobina (g/dL) — referência: 8 - 15; tipo: numérico
  - Hematócrito (%) — referência: 24 - 46; tipo: numérico
  - VCM (fL) — referência: 40 - 60; tipo: numérico
  - CHCM (g/dL) — referência: 30 - 36; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0 - 0; tipo: numérico
  - Leucócitos — referência: 4000 - 12000; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 1 0 - 120; tipo: numérico
  - Segmentados — referência: 40 75 600 - 4000; tipo: numérico
  - Linfócitos — referência: 20 50 2500 - 7500; tipo: numérico
  - Monócitos — referência: 1 4 25 - 850; tipo: numérico
  - Eosinófilos — referência: 1 10 0 - 2400; tipo: numérico
  - Basófilos — referência: 0 raros 0 - 200; tipo: misto
  - Proteínas (g/dL) — referência: 6 - 8; tipo: numérico
  - Fibrinogênio (g/dL) — referência: 0 0.2 - 0.4; tipo: numérico
#### HEM_BOV_Ad - RETICULOCITOS - Labvet 2026

- Arquivo: `Bovino 2026\HEM_BOV_Ad - RETICULOCITOS - Labvet 2026.xlsx`
- Tipo de animal: Bovino
- Idade: Não indicada
- Analitos identificados: 18
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 5 - 10; tipo: numérico
  - Hemoglobina (g/dL) — referência: 8 - 15; tipo: numérico
  - Hematócrito (%) — referência: 24 - 46; tipo: numérico
  - VCM (fL) — referência: 40 - 60; tipo: numérico
  - CHCM (g/dL) — referência: 30 - 36; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0 - 0; tipo: numérico
  - Leucócitos — referência: 4000 - 12000; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 1 0 - 120; tipo: numérico
  - Segmentados — referência: 40 75 600 - 4000; tipo: numérico
  - Linfócitos — referência: 20 50 2500 - 7500; tipo: numérico
  - Monócitos — referência: 1 4 25 - 850; tipo: numérico
  - Eosinófilos — referência: 1 10 0 - 2400; tipo: numérico
  - Basófilos — referência: 0 raros 0 - 200; tipo: misto
  - Proteínas (g/dL) — referência: 6 - 8; tipo: numérico
  - Fibrinogênio (g/dL) — referência: 0 0.2 - 0.4; tipo: numérico
  - Valor Absoluto (céls./µL) — referência: (>60.000/µL: Anemia regerenativa); tipo: misto
#### U_EAS_BOV relação- Labvet 2026

- Arquivo: `Bovino 2026\U_EAS_BOV relação- Labvet 2026.xlsx`
- Tipo de animal: Bovino
- Idade: Não indicada
- Analitos identificados: 3
- Estrutura de analitos:
  - Hemácias/campo — referência: (0-5); tipo: numérico
  - Leucócitos/campo — referência: (0-5); tipo: numérico
  - Relação prot/creat — referência: < 0,5 (normal); tipo: misto

### Bubalino

#### HEM_BUB_Ad - Labvet 2026

- Arquivo: `Bubalino 2026\HEM_BUB_Ad - Labvet 2026.xlsx`
- Tipo de animal: Bubalino
- Idade: Não indicada
- Analitos identificados: 17
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 5 -; tipo: numérico
  - Hemoglobina (g/dL) — referência: 10.46 - 13.34; tipo: numérico
  - Hematócrito (%) — referência: 26.54 - 32.66; tipo: numérico
  - VCM (fL) — referência: 39.2 - 44.8; tipo: numérico
  - CHCM (g/dL) — referência: 36.6 - 38.2; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0 - 0; tipo: numérico
  - Leucócitos — referência: 7290 - 11370; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 0 0 -; tipo: numérico
  - Segmentados — referência: 2470 - 4570; tipo: numérico
  - Linfócitos — referência: 4030 - 7250; tipo: numérico
  - Monócitos — referência: 0 - 12; tipo: numérico
  - Eosinófilos — referência: 0 - 370; tipo: numérico
  - Basófilos — referência: 0 raros 0 -; tipo: misto
  - Proteínas (g/dL) — referência: 6.18 - 7.58; tipo: numérico
  - Fibrinogênio (g/dL) — referência: 0 0.3 - 0.5; tipo: numérico

### Caprino

#### AVESSO BIOQUÍMICA_CAP - Labvet 2026

- Arquivo: `Caprino 2026\AVESSO BIOQUÍMICA_CAP - Labvet 2026.xlsx`
- Tipo de animal: Caprino
- Idade: Não indicada
- Analitos identificados: 18
- Estrutura de analitos:
  - ALT (U/L) — referência: 0 15 - 52; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 66 - 230; tipo: numérico; técnica: Cinético UV automatizado
  - Uréia (mg/dL) — referência: 0 13 - 26; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0 0.7 - 1.5; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 61 - 283; tipo: numérico; técnica: Cinético UV automatizado
  - GGT (U/L) — referência: 0 20 - 50; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 6.1 - 7.5; tipo: numérico; técnica: Colorimétrico automatizado
  - Albumina (g/dL) — referência: 0 2.3 - 3.6; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 2.7 - 4.4; tipo: numérico
  - Bilirrubina total (mg/dL) — referência: 0 0.1 - 0.2; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 -; tipo: numérico; técnica: Cinético UV automatizado
  - Colesterol Total (mg/dL) — referência: 0 65 - 136; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 16 - 48; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 79 - 265; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 3.7 - 9.7; tipo: numérico; técnica: Cinético UV automatizado
  - Triglicerídeos (mg/dL) — referência: 0 -; tipo: numérico; técnica: Colorimétrico automatizado
  - Glicose (mg/dL) — referência: 0 48 - 76; tipo: numérico; técnica: Colorimétrico automatizado
  - Cálcio total (mg/dL) — referência: 0 9 - 11.6; tipo: numérico; técnica: Colorimétrico automatizado
#### CHECKUP_CAP - Labvet 2026

- Arquivo: `Caprino 2026\CHECKUP_CAP - Labvet 2026.xlsx`
- Tipo de animal: Caprino
- Idade: Não indicada
- Analitos identificados: 11
- Estrutura de analitos:
  - Proteínas totais (g/dL) — referência: 6.1 - 7.5; tipo: numérico; técnica: Colorimétrico automatizado
  - Albumina (g/dL) — referência: 2.3 - 3.6; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 2.7 - 4.4; tipo: numérico
  - AST (U/L) — referência: 66 - 230; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 9 - 11.6; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 16 - 48; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0.7 - 1.5; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 0 20 - 50; tipo: numérico; técnica: Cinético UV automatizado
  - LDH (U/L) — referência: 79 - 265; tipo: numérico; técnica: Cinético UV automatizado
  - Fósforo (mg/dL) — referência: 3.7 - 9.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 13 - 26; tipo: numérico; técnica: Cinético UV automatizado
#### COMPATIBILIADE_Caprino - Labvet 2026

- Arquivo: `Caprino 2026\COMPATIBILIADE_Caprino - Labvet 2026.xlsx`
- Tipo de animal: Caprino
- Idade: Não indicada
- Analitos identificados: 2
- Estrutura de analitos:
  - Doador — referência: 22 - 38 6 - 7.8; tipo: numérico
  - Receptor — referência: 22 - 38 6 - 7.8; tipo: numérico
#### EAS_CAP - Labvet 2026

- Arquivo: `Caprino 2026\EAS_CAP - Labvet 2026.xlsx`
- Tipo de animal: Caprino
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Volume — referência: > 5 ml; tipo: misto
  - pH — referência: 7.5 - 8.5; tipo: numérico
  - Glicose — referência: Ausente; tipo: texto
  - Cetonas — referência: Ausente; tipo: texto
  - Sangue — referência: Ausente; tipo: texto
  - Proteínas — referência: Ausente; tipo: texto
  - Leucócitos — referência: Ausente; tipo: texto
  - Nitrito — referência: Negativo; tipo: texto
  - Hemácias/campo — referência: (0-4); tipo: numérico
  - Leucócitos/campo — referência: (0-4); tipo: numérico
  - Cristais — referência: Ausente; tipo: texto
  - Cilindros — referência: Ausente; tipo: texto
  - Células epiteliais — referência: Ausente; tipo: texto
  - Demais observações — referência: Ausente; tipo: texto
  - Sensiprot mg/dL — referência: 0 -; tipo: numérico
  - Relação prot/creat — referência: < 0,5 (normal); tipo: misto
#### HEM_CAP_Ad - Labvet 2026

- Arquivo: `Caprino 2026\HEM_CAP_Ad - Labvet 2026.xlsx`
- Tipo de animal: Caprino
- Idade: Não indicada
- Analitos identificados: 17
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 8 - 18; tipo: numérico
  - Hemoglobina (g/dL) — referência: 8 - 12; tipo: numérico
  - Hematócrito (%) — referência: 22 - 38; tipo: numérico
  - VCM (fL) — referência: 16 - 25; tipo: numérico
  - CHCM (g/dL) — referência: 30 - 36; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0 - 0; tipo: numérico
  - Leucócitos — referência: 4000 - 13000; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 raros raros; tipo: misto
  - Segmentados — referência: 30 48 1200 - 7200; tipo: numérico
  - Linfócitos — referência: 50 70 2000 - 9000; tipo: numérico
  - Monócitos — referência: 0 4 0 - 550; tipo: numérico
  - Eosinófilos — referência: 1 8 50 - 650; tipo: numérico
  - Basófilos — referência: 0 0 1 0 - 120; tipo: numérico
  - Proteínas (g/dL) — referência: 6 - 7.75; tipo: numérico
  - Fibrinogênio (g/dL) — referência: 0.2 - 0.6; tipo: numérico
#### HEM_CAP_Ad -RETICULOCITOS - Labvet 2026

- Arquivo: `Caprino 2026\HEM_CAP_Ad -RETICULOCITOS - Labvet 2026.xlsx`
- Tipo de animal: Caprino
- Idade: Não indicada
- Analitos identificados: 18
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 8 - 18; tipo: numérico
  - Hemoglobina (g/dL) — referência: 8 - 12; tipo: numérico
  - Hematócrito (%) — referência: 22 - 38; tipo: numérico
  - VCM (fL) — referência: 16 - 25; tipo: numérico
  - CHCM (g/dL) — referência: 30 - 36; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0 - 0; tipo: numérico
  - Leucócitos — referência: 4000 - 13000; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 raros raros; tipo: misto
  - Segmentados — referência: 30 48 1200 - 7200; tipo: numérico
  - Linfócitos — referência: 50 70 2000 - 9000; tipo: numérico
  - Monócitos — referência: 0 4 0 - 550; tipo: numérico
  - Eosinófilos — referência: 1 8 50 - 650; tipo: numérico
  - Basófilos — referência: 0 0 1 0 - 120; tipo: numérico
  - Proteínas (g/dL) — referência: 6 - 7.75; tipo: numérico
  - Fibrinogênio (g/dL) — referência: 0.2 - 0.6; tipo: numérico
  - Valor Absoluto (céls./µL) — referência: (>60.000/µL: Anemia regerenativa); tipo: misto

### Cão

#### B_AVESSO_CÃO_ADULTO - Labvet

- Arquivo: `Cão 2026\B_AVESSO_CÃO_ADULTO - Labvet.xlsx`
- Tipo de animal: Cão
- Idade: ADULTO
- Analitos identificados: 23
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 2.3 - 3.1; tipo: numérico; técnica: Colorimétrico automatizado
  - ALT (U/L) — referência: 0 10 - 109; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 8.9 - 49; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 0.06 - 0.12; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0.1 - 0.5; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio iônico (mmol/L) — referência: 1.25 - 1.45; tipo: numérico; técnica: Eletrodo ion-seletivo
  - Cálcio total (mg/dL) — referência: 0 9 - 11.2; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 153 - 278; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 20 - 200; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0 0.5 - 1.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Ferro (mg/dL) — referência: 30 - 180; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 1 - 114; tipo: numérico; técnica: Cinético UV automatizado
  - Fósforo (mg/dL) — referência: 0 2.9 - 5.3; tipo: numérico; técnica: Cinético UV automatizado
  - GGT (U/L) — referência: 0 1 - 9.7; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 62 - 108; tipo: numérico; técnica: Colorimétrico automatizado
  - Potássio (mmol/L) — referência: 3.9 - 5.1; tipo: numérico; técnica: Eletrodo ion-seletivo
  - Proteínas totais (g/dL) — referência: 0 5.4 - 7.5; tipo: numérico; técnica: Colorimétrico automatizado
  - Sódio (mmol/L) — referência: 142 - 152; tipo: numérico; técnica: Eletrodo ion-seletivo
  - Triglicerídeos (mg/dL) — referência: 0 40 - 169; tipo: numérico; técnica: Colorimétrico automatizado
  - LDH (U/L) — referência: 0 45 - 233; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 15 - 40; tipo: numérico; técnica: Cinético UV automatizado
  - Relação Albumina:Globulina — referência: 0.6 - 1.1; tipo: numérico
  - Globulinas (g/dL) — referência: 2.4 - 4.4; tipo: numérico
#### B_CHECK UP + Calcio+Fósf_CÃO - Labvet 2026

- Arquivo: `Cão 2026\B_CHECK UP + Calcio+Fósf_CÃO - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 12
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 2.3 - 3.1; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 1 - 114; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 10 - 109; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 8.9 - 49; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0.5 - 1.7; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 1 - 9.7; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 5.4 - 7.5; tipo: numérico; técnica: Colorimétrico automatizado
  - Relação Albumina:Globulina — referência: 0.6 - 1.1; tipo: numérico
  - Globulinas (g/dL) — referência: 2.4 - 4.4; tipo: numérico
  - Uréia (mg/dL) — referência: 15 - 40; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 9 - 11.2; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 2.9 - 5.3; tipo: numérico; técnica: Cinético UV automatizado
#### B_CHECK UP + Fósf_CÃO - Labvet 2026

- Arquivo: `Cão 2026\B_CHECK UP + Fósf_CÃO - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 11
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 2.3 - 3.1; tipo: numérico; técnica: Colorimétrico automatizado
  - ALT (U/L) — referência: 0 10 - 109; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 8.9 - 49; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0 0.5 - 1.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 1 - 114; tipo: numérico; técnica: Cinético UV automatizado
  - Fósforo (mg/dL) — referência: 0 2.9 - 5.3; tipo: numérico; técnica: Cinético UV automatizado
  - GGT (U/L) — referência: 0 1 - 9.7; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 5.4 - 7.5; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 15 - 40; tipo: numérico; técnica: Cinético UV automatizado
  - Relação Albumina:Globulina — referência: 0.6 - 1.1; tipo: numérico
  - Globulinas (g/dL) — referência: 2.4 - 4.4; tipo: numérico
#### B_CHECK UP _CÃO - Labvet 2026

- Arquivo: `Cão 2026\B_CHECK UP _CÃO - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: 2 ano
- Analitos identificados: 11
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 2.3 - 3.1; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 1 - 114; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 10 - 109; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 8.9 - 49; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0.5 - 1.7; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 1 - 9.7; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 5.4 - 7.5; tipo: numérico; técnica: Colorimétrico automatizado
  - Relação Albumina:Globulina — referência: 0.6 - 1.1; tipo: numérico
  - Globulinas (g/dL) — referência: 2.4 - 4.4; tipo: numérico
  - Uréia (mg/dL) — referência: 15 - 40; tipo: numérico; técnica: Cinético UV automatizado
  - 1042 — referência: 2024-07-17 00:00:00 7811 Kyra Clarissa Angélica Azevedo Can 7A F SRD HVPA/Oncologia Obesidade, hiporexia, letargia. Mastocitoma há 2 anos 7, 21, 27; tipo: misto
#### B_CHECK UP+FOSF+CA+TRIG+COL+GLI_CÃO - Labvet 2026

- Arquivo: `Cão 2026\B_CHECK UP+FOSF+CA+TRIG+COL+GLI_CÃO - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: 2 ano
- Analitos identificados: 16
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 2.3 - 3.1; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 1 - 114; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 10 - 109; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 8.9 - 49; tipo: numérico; técnica: Cinético UV automatizado
  - Colesterol Total (mg/dL) — referência: 153 - 278; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0.5 - 1.7; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 1 - 9.7; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 5.4 - 7.5; tipo: numérico; técnica: Colorimétrico automatizado
  - Relação Albumina:Globulina — referência: 0.6 - 1.1; tipo: numérico
  - Globulinas (g/dL) — referência: 2.4 - 4.4; tipo: numérico
  - Triglicerídeos (mg/dL) — referência: 40 - 169; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 2.9 - 5.3; tipo: numérico; técnica: Cinético UV automatizado
  - Uréia (mg/dL) — referência: 15 - 40; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 62 - 108; tipo: numérico; técnica: Colorimétrico automatizado
  - Cálcio total (mg/dL) — referência: 0 9 - 11.2; tipo: numérico; técnica: Colorimétrico automatizado
  - 1042 — referência: 2024-07-17 00:00:00 7811 Kyra Clarissa Angélica Azevedo Can 7A F SRD HVPA/Oncologia Obesidade, hiporexia, letargia. Mastocitoma há 2 anos 7, 21, 27; tipo: misto
#### B_CHECK UP+TRIG+COL+GLIC_CÃO - Labvet 2026

- Arquivo: `Cão 2026\B_CHECK UP+TRIG+COL+GLIC_CÃO - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: 2 ano
- Analitos identificados: 14
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 2.3 - 3.1; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 1 - 114; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 10 - 109; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 8.9 - 49; tipo: numérico; técnica: Cinético UV automatizado
  - Colesterol Total (mg/dL) — referência: 153 - 278; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0.5 - 1.7; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 1 - 9.7; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 5.4 - 7.5; tipo: numérico; técnica: Colorimétrico automatizado
  - Relação Albumina:Globulina — referência: 0.6 - 1.1; tipo: numérico
  - Globulinas (g/dL) — referência: 2.4 - 4.4; tipo: numérico
  - Triglicerídeos (mg/dL) — referência: 40 - 169; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 15 - 40; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 62 - 108; tipo: numérico; técnica: Colorimétrico automatizado
  - 1042 — referência: 2024-07-17 00:00:00 7811 Kyra Clarissa Angélica Azevedo Can 7A F SRD HVPA/Oncologia Obesidade, hiporexia, letargia. Mastocitoma há 2 anos 7, 21, 27; tipo: misto
#### B_CHECK UP+TRIG+COL_CÃO - Labvet 2026

- Arquivo: `Cão 2026\B_CHECK UP+TRIG+COL_CÃO - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: 2 ano
- Analitos identificados: 13
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 2.3 - 3.1; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 1 - 114; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 10 - 109; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 8.9 - 49; tipo: numérico; técnica: Cinético UV automatizado
  - Colesterol Total (mg/dL) — referência: 0 153 - 278; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.5 - 1.7; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 0 1 - 9.7; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 5.4 - 7.5; tipo: numérico; técnica: Colorimétrico automatizado
  - Relação Albumina:Globulina — referência: 0.6 - 1.1; tipo: numérico
  - Globulinas (g/dL) — referência: 2.4 - 4.4; tipo: numérico
  - Triglicerídeos (mg/dL) — referência: 0 40 - 169; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 15 - 40; tipo: numérico; técnica: Cinético UV automatizado
  - 1042 — referência: 2024-07-17 00:00:00 7811 Kyra Clarissa Angélica Azevedo Can 7A F SRD HVPA/Oncologia Obesidade, hiporexia, letargia. Mastocitoma há 2 anos 7, 21, 27; tipo: misto
#### B_CHECK UP_CÃO_FILHOTE - Labvet 2026

- Arquivo: `Cão 2026\B_CHECK UP_CÃO_FILHOTE - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: FILHOTE
- Analitos identificados: 9
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 2.6 - 4; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 29 - 203; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 0 - 43.1; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 8.9 - 49; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0 0.2 - 1.1; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 0 1 - 9.7; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 5.4 - 7.5; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 8.8 - 26; tipo: numérico; técnica: Cinético UV automatizado
  - Globulinas (g/dL) — referência: 2.4 - 4.4; tipo: numérico
#### B_CÃO_BT_BD - Labvet 2026

- Arquivo: `Cão 2026\B_CÃO_BT_BD - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 2
- Estrutura de analitos:
  - Bilirrubina direta (mg/dL) — referência: 0 0.06 - 0.12; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0.1 - 0.5; tipo: numérico; técnica: Cinético UV automatizado
#### B_CÃO_CHECKUP+BIL - Labvet 2026

- Arquivo: `Cão 2026\B_CÃO_CHECKUP+BIL - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 12
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 2.3 - 3.1; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 1 - 114; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 10 - 109; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 8.9 - 49; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0.5 - 1.7; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 1 - 9.7; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 5.4 - 7.5; tipo: numérico; técnica: Colorimétrico automatizado
  - Relação Albumina:Globulina — referência: 0.6 - 1.1; tipo: numérico
  - Globulinas (g/dL) — referência: 2.4 - 4.4; tipo: numérico
  - Uréia (mg/dL) — referência: 15 - 40; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 0.06 - 0.12; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0.1 - 0.5; tipo: numérico; técnica: Cinético UV automatizado
#### B_CÃO_CHECKUP+BIL+CÁLCIO+FOSF - Labvet 2026

- Arquivo: `Cão 2026\B_CÃO_CHECKUP+BIL+CÁLCIO+FOSF - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 14
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 2.3 - 3.1; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 1 - 114; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 10 - 109; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 8.9 - 49; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0.5 - 1.7; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 1 - 9.7; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 5.4 - 7.5; tipo: numérico; técnica: Colorimétrico automatizado
  - Relação Albumina:Globulina — referência: 0.6 - 1.1; tipo: numérico
  - Globulinas (g/dL) — referência: 2.4 - 4.4; tipo: numérico
  - Uréia (mg/dL) — referência: 15 - 40; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 0.06 - 0.12; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0.1 - 0.5; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 9 - 11.2; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 2.9 - 5.3; tipo: numérico; técnica: Cinético UV automatizado
#### B_CÃO_CHECKUP+BIL+TRI+COL - Labvet 2026

- Arquivo: `Cão 2026\B_CÃO_CHECKUP+BIL+TRI+COL - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 14
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 2.3 - 3.1; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 1 - 114; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 10 - 109; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 8.9 - 49; tipo: numérico; técnica: Cinético UV automatizado
  - Colesterol Total (mg/dL) — referência: 153 - 278; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0.5 - 1.7; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 1 - 9.7; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 5.4 - 7.5; tipo: numérico; técnica: Colorimétrico automatizado
  - Relação Albumina:Globulina — referência: 0.6 - 1.1; tipo: numérico
  - Globulinas (g/dL) — referência: 2.4 - 4.4; tipo: numérico
  - Triglicerídeos (mg/dL) — referência: 40 - 169; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 15 - 40; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 0.06 - 0.12; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0.1 - 0.5; tipo: numérico; técnica: Cinético UV automatizado
#### B_UREIA+CREAT _CÃO - Labvet 2026

- Arquivo: `Cão 2026\B_UREIA+CREAT _CÃO - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: 2 ano
- Analitos identificados: 3
- Estrutura de analitos:
  - Creatinina (mg/dL) — referência: 0.5 - 1.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 15 - 40; tipo: numérico; técnica: Cinético UV automatizado
  - 1042 — referência: 2024-07-17 00:00:00 7811 Kyra Clarissa Angélica Azevedo Can 7A F SRD HVPA/Oncologia Obesidade, hiporexia, letargia. Mastocitoma há 2 anos 7, 21, 27; tipo: misto
#### CITOLOGIA_CÃO

- Arquivo: `Cão 2026\CITOLOGIA_CÃO.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 0
- Estrutura de analitos: não identificada automaticamente; requer revisão manual.
#### CITOLOGIA_Cão - Labvet 2026

- Arquivo: `Cão 2026\CITOLOGIA_Cão - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 0
- Estrutura de analitos: não identificada automaticamente; requer revisão manual.
#### COAGULOGRAMA_Cão - Labvet 2026

- Arquivo: `Cão 2026\COAGULOGRAMA_Cão - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 2
- Estrutura de analitos:
  - Tempo de Protrombina (TP) — referência: 12 - 17; tipo: numérico
  - Tempo de Tromboplastina Parcial Ativada (TTPa) — referência: 96 - 116; tipo: numérico
#### COMPATIBILIADE simples_CAN - Labvet 2026

- Arquivo: `Cão 2026\COMPATIBILIADE simples_CAN - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 2
- Estrutura de analitos:
  - Doador — referência: 37 - 55 6 - 8; tipo: numérico
  - Receptor — referência: 37 - 55 6 - 8; tipo: numérico
#### CORTISOL_CÃO - Labvet 2026 Layout atualizado

- Arquivo: `Cão 2026\CORTISOL_CÃO - Labvet 2026 Layout atualizado.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 0
- Estrutura de analitos: não identificada automaticamente; requer revisão manual.
#### CORTISOL_CÃO - Labvet 2026

- Arquivo: `Cão 2026\CORTISOL_CÃO - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 7
- Estrutura de analitos:
  - Nível de cortisol 4hrs — referência: Nível de cortisol 8hrs Interpretação; tipo: misto
  - - — referência: < 1 µg/dL Normal; tipo: misto
  - 1 - 1,4µg/dL — referência: 1 - 1,4µg/dL Equivocado; tipo: misto
  - > 1,4µg/dL e > 50% da linha de base — referência: > 1,4µg/dL e > 50% da linha de base Consistente com hiperadrenocorticismo; tipo: misto
  - < 1,4µg/dL ou < 50% da linha de base — referência: > 1,4µg/dL e > 50% da linha de base Consistente com PDH; tipo: misto
  - > 1,4µg/dL ou > 50% da linha de base — referência: > 1,4µg/dL e < 50% da linha de base Consistente com PDH; tipo: misto
  - < 1,4µg/dL ou < 50% da linha de base — referência: > 1,4µg/dL e < 50% da linha de base Consistente com PDH; tipo: misto
#### HEM_CÃO_ AD_ RETICULÓCITOS 2026

- Arquivo: `Cão 2026\HEM_CÃO_ AD_ RETICULÓCITOS 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 17
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 5.5 - 8.5; tipo: numérico
  - Hemoglobina (g/dL) — referência: 12 - 18; tipo: numérico
  - Hematócrito (%) — referência: 37 - 55; tipo: numérico
  - VCM (fL) — referência: 60 - 77; tipo: numérico
  - CHCM (g/dL) — referência: 32 - 36; tipo: numérico
  - Metarrubrícitos (%) — referência: 0; tipo: numérico
  - Leucócitos — referência: 6000 - 17000; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 3 0 - 300; tipo: numérico
  - Segmentados — referência: 60 70 3000 - 11400; tipo: numérico
  - Linfócitos — referência: 12 30 1000 - 4800; tipo: numérico
  - Monócitos — referência: 3 10 150 - 1350; tipo: numérico
  - Eosinófilos — referência: 2 10 100 - 750; tipo: numérico
  - Basófilos — referência: raros raros; tipo: texto
  - Proteínas (g/dL) — referência: 6 - 7.5; tipo: numérico
  - Valor Absoluto (céls./µL) — referência: (>60.000/µL: Anemia regerenativa); tipo: misto
#### HEM_CÃO_ FIB E RET 2026

- Arquivo: `Cão 2026\HEM_CÃO_ FIB E RET 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 18
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 5.5 - 8.5; tipo: numérico
  - Hemoglobina (g/dL) — referência: 12 - 18; tipo: numérico
  - Hematócrito (%) — referência: 37 - 55; tipo: numérico
  - VCM (fL) — referência: 60 - 77; tipo: numérico
  - CHCM (g/dL) — referência: 32 - 36; tipo: numérico
  - Metarrubrícitos (%) — referência: 0; tipo: numérico
  - Leucócitos — referência: 20200 6000 - 17000; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 3 0 - 300; tipo: numérico
  - Segmentados — referência: 60 70 3000 - 11400; tipo: numérico
  - Linfócitos — referência: 12 30 1000 - 4800; tipo: numérico
  - Monócitos — referência: 3 10 150 - 1350; tipo: numérico
  - Eosinófilos — referência: 2 10 100 - 750; tipo: numérico
  - Basófilos — referência: raros raros; tipo: texto
  - Proteínas (g/dL) — referência: 6 - 7.5; tipo: numérico
  - Fibrinogênio (g/dL) — referência: 0.2 - 0.4; tipo: numérico
  - Valor Absoluto (céls./µL) — referência: (>60.000/µL: Anemia regerenativa); tipo: misto
#### HEM_CÃO_FILHOTE - Labvet 2026

- Arquivo: `Cão 2026\HEM_CÃO_FILHOTE - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: FILHOTE
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 5.5 - 7; tipo: numérico
  - Hemoglobina (g/dL) — referência: 11 - 15.5; tipo: numérico
  - Hematócrito (%) — referência: 34 - 40; tipo: numérico
  - VCM (fL) — referência: 65 - 78; tipo: numérico
  - CHCM (g/dL) — referência: 30 - 35; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 9000 - 15000; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 1 0 - 150; tipo: numérico
  - Segmentados — referência: 47 69 4230 - 10350; tipo: numérico
  - Linfócitos — referência: 28 45 2520 - 6750; tipo: numérico
  - Monócitos — referência: 1 10 90 - 1500; tipo: numérico
  - Eosinófilos — referência: 1 5 90 - 750; tipo: numérico
  - Basófilos — referência: 0 zero zero; tipo: misto
  - Proteínas (g/dL) — referência: 6 - 7.5; tipo: numérico
#### HEM_CÃO_FILHOTE - MENOS 1 mês - Labvet 22026

- Arquivo: `Cão 2026\HEM_CÃO_FILHOTE - MENOS 1 mês - Labvet 22026.xlsx`
- Tipo de animal: Cão
- Idade: FILHOTE, 1 mês
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 3.5 - 6; tipo: numérico
  - Hemoglobina (g/dL) — referência: 8.5 - 13; tipo: numérico
  - Hematócrito (%) — referência: 26 - 39; tipo: numérico
  - VCM (fL) — referência: 69 - 83; tipo: numérico
  - CHCM (g/dL) — referência: 31 - 33; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 8500 - 17300; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 1 0 - 173; tipo: numérico
  - Segmentados — referência: 46 68 3910 - 11764; tipo: numérico
  - Linfócitos — referência: 30 48 2550 - 8304; tipo: numérico
  - Monócitos — referência: 1 10 85 - 1730; tipo: numérico
  - Eosinófilos — referência: 1 5 85 - 865; tipo: numérico
  - Basófilos — referência: 0 raros raros; tipo: misto
  - Proteínas (g/dL) — referência: 6 - 7.5; tipo: numérico
#### HEM_CÃO_FILHOTE - RETICULOCITOS - Labvet 2026

- Arquivo: `Cão 2026\HEM_CÃO_FILHOTE - RETICULOCITOS - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: FILHOTE
- Analitos identificados: 17
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 5.5 - 7; tipo: numérico
  - Hemoglobina (g/dL) — referência: 11 - 15.5; tipo: numérico
  - Hematócrito (%) — referência: 34 - 40; tipo: numérico
  - VCM (fL) — referência: 65 - 78; tipo: numérico
  - CHCM (g/dL) — referência: 30 - 35; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 9000 - 15000; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 1 0 - 150; tipo: numérico
  - Segmentados — referência: 47 69 4230 - 10350; tipo: numérico
  - Linfócitos — referência: 28 45 2520 - 6750; tipo: numérico
  - Monócitos — referência: 1 10 90 - 1500; tipo: numérico
  - Eosinófilos — referência: 1 5 90 - 750; tipo: numérico
  - Basófilos — referência: 0 zero zero; tipo: misto
  - Proteínas (g/dL) — referência: 6 - 7.5; tipo: numérico
  - Valor Absoluto (céls./µL) — referência: (>60.000/µL: Anemia regerenativa); tipo: misto
#### IMUNO_ KNOTT_CÃO - Labvet 2026

- Arquivo: `Cão 2026\IMUNO_ KNOTT_CÃO - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 0
- Estrutura de analitos: não identificada automaticamente; requer revisão manual.
#### IMUNO_ WOO_CÃO - Labvet 2026

- Arquivo: `Cão 2026\IMUNO_ WOO_CÃO - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 0
- Estrutura de analitos: não identificada automaticamente; requer revisão manual.
#### IMUNO_4DX- CAO - Labvet 2026

- Arquivo: `Cão 2026\IMUNO_4DX- CAO - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 1
- Estrutura de analitos:
  - Dirofilaria immitis: — referência: Negativo; tipo: texto
#### IMUNO_LEPTO CAO - Labvet 2026

- Arquivo: `Cão 2026\IMUNO_LEPTO CAO - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 0
- Estrutura de analitos: não identificada automaticamente; requer revisão manual.
#### LAVADO BRONCOALVEOLAR Labvet 2026

- Arquivo: `Cão 2026\LAVADO BRONCOALVEOLAR Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 0
- Estrutura de analitos: não identificada automaticamente; requer revisão manual.
#### LC_LIQUIDO_CAVITARIO_CÃO - Labvet 2026

- Arquivo: `Cão 2026\LC_LIQUIDO_CAVITARIO_CÃO - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 0
- Estrutura de analitos: não identificada automaticamente; requer revisão manual.
#### PONTA_ORELHA_CÃO - Labvet 2026

- Arquivo: `Cão 2026\PONTA_ORELHA_CÃO - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 0
- Estrutura de analitos: não identificada automaticamente; requer revisão manual.
#### T4_CÃO - Labvet 2026

- Arquivo: `Cão 2026\T4_CÃO - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 2
- Estrutura de analitos:
  - 1.0 - 2.0 µg/dL — referência: BAIXO NORMAL; tipo: texto
  - 1.0 - 4.0 µg/dL — referência: NORMAL; tipo: texto
#### TESTE DE HEMOAGLUTINAÇÃO EM SALINA - Labvet 2026

- Arquivo: `Cão 2026\TESTE DE HEMOAGLUTINAÇÃO EM SALINA - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 0
- Estrutura de analitos: não identificada automaticamente; requer revisão manual.
#### TSH_CÃO - Labvet 2026

- Arquivo: `Cão 2026\TSH_CÃO - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 1
- Estrutura de analitos:
  - < 0.5 ng/mL — referência: NORMAL; tipo: texto
#### U_EAS+CR+UR URI_Cão - Labvet 2026

- Arquivo: `Cão 2026\U_EAS+CR+UR URI_Cão - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 14
- Estrutura de analitos:
  - Volume — referência: > 5 mL; tipo: misto
  - pH — referência: 5.5 - 7.5; tipo: numérico
  - Glicose — referência: Ausente; tipo: texto
  - Cetonas — referência: Ausentes; tipo: texto
  - Sangue — referência: Ausente; tipo: texto
  - Proteínas — referência: Ausentes; tipo: texto
  - Nitrito — referência: Negativo; tipo: texto
  - Hemácias/campo — referência: (0-4); tipo: numérico
  - Leucócitos/campo — referência: (0-4); tipo: numérico
  - Cristais — referência: Ausentes; tipo: texto
  - Cilindros — referência: Ausentes; tipo: texto
  - Células epiteliais — referência: Ausentes; tipo: texto
  - Demais observações — referência: Ausentes; tipo: texto
  - Relação prot/creat — referência: < 0,5 (normal); tipo: misto
#### U_EAS_Cão - Labvet 2026

- Arquivo: `Cão 2026\U_EAS_Cão - Labvet 2026.xlsx`
- Tipo de animal: Cão
- Idade: Não indicada
- Analitos identificados: 14
- Estrutura de analitos:
  - Volume — referência: > 5 mL; tipo: misto
  - pH — referência: 5.5 - 7.5; tipo: numérico
  - Glicose — referência: Ausente; tipo: texto
  - Cetonas — referência: Ausentes; tipo: texto
  - Sangue — referência: Ausente; tipo: texto
  - Proteínas — referência: Ausentes; tipo: texto
  - Nitrito — referência: Negativo; tipo: texto
  - Hemácias/campo — referência: (0-4); tipo: numérico
  - Leucócitos/campo — referência: (0-4); tipo: numérico
  - Cristais — referência: Ausentes; tipo: texto
  - Cilindros — referência: Ausentes; tipo: texto
  - Células epiteliais — referência: Ausentes; tipo: texto
  - Demais observações — referência: Ausentes; tipo: texto
  - 1043 — referência: 2024-07-17 00:00:00 5736 Mel Ana Maria Vitoriano Can 13A F SRD HVPA/Oncologia; tipo: misto

### Equinos

#### 3593_26B

- Arquivo: `Equinos 2026\3593_26B.xlsx`
- Tipo de animal: Equinos
- Idade: 24 ano
- Analitos identificados: 13
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 2.6 - 4.1; tipo: numérico; técnica: Colorimétrico automatizado
  - AST (U/L) — referência: 160 - 412; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 10.2 - 13.4; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 60 - 330; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0.4 - 2.2; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 6 - 32; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 112 - 456; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 2.3 - 5.4; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 5.6 - 7.6; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 2.6 - 4; tipo: numérico
  - Uréia (mg/dL) — referência: 11 - 27; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0 - 3.2; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 0 - 0.4; tipo: numérico; técnica: Cinético UV automatizado
#### B_AVESSO_EQ - Labvet

- Arquivo: `Equinos 2026\B_AVESSO_EQ - Labvet.xlsx`
- Tipo de animal: Equinos
- Idade: Não indicada
- Analitos identificados: 26
- Estrutura de analitos:
  - ALT (U/L) — referência: 0 2.7 - 21; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 160 - 412; tipo: numérico; técnica: Cinético UV automatizado
  - Uréia (mg/dL) — referência: 0 11 - 27; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0 0.4 - 2.2; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 70 - 227; tipo: numérico; técnica: Cinético UV automatizado
  - GGT (U/L) — referência: 0 6 - 32; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 5.6 - 7.6; tipo: numérico; técnica: Colorimétrico automatizado
  - Albumina (g/dL) — referência: 0 2.6 - 4.1; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 2.6 - 4; tipo: numérico
  - Bilirrubina total (mg/dL) — referência: 0 0 - 3.2; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 0 - 0.4; tipo: numérico; técnica: Cinético UV automatizado
  - Colesterol Total (mg/dL) — referência: 0 71 - 142; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 60 - 330; tipo: numérico; técnica: Cinético UV automatizado
  - CK-MB (U/L) — referência: 0 -; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato (mg/dL) — referência: 0 -; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 112 - 456; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 2.3 - 5.4; tipo: numérico; técnica: Cinético UV automatizado
  - Triglicerídeos (mg/dL) — referência: 0 -; tipo: numérico; técnica: Colorimétrico automatizado
  - Frutosamina (µmol/L) — referência: 0 -; tipo: numérico; técnica: Colorimétrico automatizado
  - Glicose (mg/dL) — referência: 0 62 - 134; tipo: numérico; técnica: Colorimétrico automatizado
  - Magnésio (mg/dL) — referência: 0 1.4 - 2.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Cálcio total (mg/dL) — referência: 0 10.2 - 13.4; tipo: numérico; técnica: Colorimétrico automatizado
  - Cálcio iônico (mg/dL) — referência: 0 -; tipo: numérico
  - Colesterol HDL (mg/dL) — referência: 0 -; tipo: numérico; técnica: Cinético UV automatizado
  - Sódio (mEq/L) — referência: 0 128 - 142; tipo: numérico
  - Potássio (mEq/L) — referência: 0 2.9 - 4.6; tipo: numérico
#### B_CHECKUP_EQ - Labvet 2026

- Arquivo: `Equinos 2026\B_CHECKUP_EQ - Labvet 2026.xlsx`
- Tipo de animal: Equinos
- Idade: Não indicada
- Analitos identificados: 11
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 2.6 - 4.1; tipo: numérico; técnica: Colorimétrico automatizado
  - AST (U/L) — referência: 160 - 412; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 10.2 - 13.4; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 60 - 330; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0.4 - 2.2; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 6 - 32; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 112 - 456; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 2.3 - 5.4; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 5.6 - 7.6; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 2.6 - 4; tipo: numérico
  - Uréia (mg/dL) — referência: 11 - 27; tipo: numérico; técnica: Cinético UV automatizado
#### B_CHECKUP_MUAR - Labvet 2026

- Arquivo: `Equinos 2026\B_CHECKUP_MUAR - Labvet 2026.xlsx`
- Tipo de animal: Equinos
- Idade: Não indicada
- Analitos identificados: 10
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 2.8 - 3.7; tipo: numérico; técnica: Colorimétrico automatizado
  - AST (U/L) — referência: 201 - 507; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 10.2 - 13.4; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0.4 - 2.2; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 6 - 32; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 112 - 456; tipo: numérico; técnica: Colorimétrico automatizado
  - Proteínas totais (g/dL) — referência: 5.2 - 6.8; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 2.3 - 5.4; tipo: numérico; técnica: Cinético UV automatizado
  - Globulinas (g/dL) — referência: 2 - 3.4; tipo: numérico
  - Uréia (mg/dL) — referência: 11 - 27; tipo: numérico; técnica: Cinético UV automatizado
#### B_Checkup (11)__Eq 2026

- Arquivo: `Equinos 2026\B_Checkup (11)__Eq 2026.xlsx`
- Tipo de animal: Equinos
- Idade: Não indicada
- Analitos identificados: 13
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 2.6 - 4.1; tipo: numérico; técnica: Colorimétrico automatizado
  - AST (U/L) — referência: 160 - 412; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 10.2 - 13.4; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 60 - 330; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0.4 - 2.2; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 6 - 32; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 112 - 456; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 2.3 - 5.4; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 5.6 - 7.6; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 2.6 - 4; tipo: numérico
  - Uréia (mg/dL) — referência: 11 - 27; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0 - 3.2; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 0 - 0.4; tipo: numérico; técnica: Cinético UV automatizado
#### COMPATIBILIDADE_EQ - Labvet 2026

- Arquivo: `Equinos 2026\COMPATIBILIDADE_EQ - Labvet 2026.xlsx`
- Tipo de animal: Equinos
- Idade: Não indicada
- Analitos identificados: 2
- Estrutura de analitos:
  - Doador — referência: 32 - 48 6 - 8.5; tipo: numérico
  - Receptor — referência: 32 - 48 6 - 8.5; tipo: numérico
#### ESFREG_PONTA DE ORELHA_EQ - Labvet 2026

- Arquivo: `Equinos 2026\ESFREG_PONTA DE ORELHA_EQ - Labvet 2026.xlsx`
- Tipo de animal: Equinos
- Idade: Não indicada
- Analitos identificados: 0
- Estrutura de analitos: não identificada automaticamente; requer revisão manual.
#### HEM_EQUI_Ad - Labvet 2026

- Arquivo: `Equinos 2026\HEM_EQUI_Ad - Labvet 2026.xlsx`
- Tipo de animal: Equinos
- Idade: Não indicada
- Analitos identificados: 18
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 6 - 12; tipo: numérico
  - Hemoglobina (g/dL) — referência: 10 - 18; tipo: numérico
  - Hematócrito (%) — referência: 32 - 48; tipo: numérico
  - VCM (fL) — referência: 34 - 58; tipo: numérico
  - CHCM (g/dL) — referência: 31 - 37; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0 - 0; tipo: numérico
  - Leucócitos — referência: 6000 - 12000; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 1 0 - 100; tipo: numérico
  - Segmentados — referência: 30 75 3000 - 6000; tipo: numérico
  - Linfócitos — referência: 25 60 1500 - 5000; tipo: numérico
  - Monócitos — referência: 1 8 0 - 600; tipo: numérico
  - Eosinófilos — referência: 1 10 0 - 800; tipo: numérico
  - Basófilos — referência: 0 0 3 0 - 300; tipo: numérico
  - Proteínas (g/dL) — referência: 6 - 8.5; tipo: numérico
  - Fibrinogênio (g/dL) — referência: 0 0.1 - 0.4; tipo: numérico
  - 1053 — referência: 2024-07-17 00:00:00 - Esfinge FAZUR Equi 4A F Mangalarga marchador HVGA; tipo: misto
#### HEM_MUAR_Ad - Labvet 2026

- Arquivo: `Equinos 2026\HEM_MUAR_Ad - Labvet 2026.xlsx`
- Tipo de animal: Equinos
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 6 - 11.3; tipo: numérico
  - Hemoglobina (g/dL) — referência: 10.6 - 18.9; tipo: numérico
  - Hematócrito (%) — referência: 34 - 49; tipo: numérico
  - VCM (fL) — referência: 38 - 49; tipo: numérico
  - CHCM (g/dL) — referência: 37 - 40; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0 - 0; tipo: numérico
  - Leucócitos — referência: 5290 - 13750; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0; tipo: numérico
  - Segmentados — referência: 2700 - 9650; tipo: numérico
  - Linfócitos — referência: 1100 - 5690; tipo: numérico
  - Monócitos — referência: 130 - 590; tipo: numérico
  - Eosinófilos — referência: 60 - 580; tipo: numérico
  - Basófilos — referência: 0 10 - 160; tipo: numérico
  - Fibrinogênio (g/dL) — referência: 0 -; tipo: numérico
#### U_EAS_EQ - Labvet 2026

- Arquivo: `Equinos 2026\U_EAS_EQ - Labvet 2026.xlsx`
- Tipo de animal: Equinos
- Idade: Não indicada
- Analitos identificados: 7
- Estrutura de analitos:
  - pH — referência: 7.5 - 8.5; tipo: numérico
  - glicose — referência: ausente; tipo: texto
  - cetonas — referência: ausente; tipo: texto
  - sangue — referência: ausente; tipo: texto
  - proteínas — referência: ausente; tipo: texto
  - Hemácias/campo — referência: (0-5); tipo: numérico
  - Leucócitos/campo — referência: (0-5); tipo: numérico
#### U_EAS_EQ relação - Labvet 2026

- Arquivo: `Equinos 2026\U_EAS_EQ relação - Labvet 2026.xlsx`
- Tipo de animal: Equinos
- Idade: Não indicada
- Analitos identificados: 8
- Estrutura de analitos:
  - pH — referência: 7.5 - 8.5; tipo: numérico
  - Glicose — referência: Ausente; tipo: texto
  - Cetonas — referência: Ausente; tipo: texto
  - Sangue — referência: Ausente; tipo: texto
  - Proteínas — referência: Ausente; tipo: texto
  - Hemácias/campo — referência: (0-5); tipo: numérico
  - Leucócitos/campo — referência: (0-5); tipo: numérico
  - Relação prot/creat — referência: < 0,5 (normal); tipo: misto

### Gato

#### B_AVESSO_FELINOS - labvet

- Arquivo: `Gato 2026\B_AVESSO_FELINOS - labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 26
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 2.1 - 3.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 0 - 90; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 5 - 60; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 0 - 50; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 0.04 - 0.3; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0.1 - 0.7; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 8 - 10.8; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 17 - 150; tipo: numérico; técnica: Cinético UV automatizado
  - Colesterol Total (mg/dL) — referência: 0 80 - 250; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.5 - 1.9; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 0 0 - 10; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 61 - 124; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 2.6 - 5.1; tipo: numérico
  - Lactato Desidrogenase (mg/dL) — referência: 0 58 - 120; tipo: numérico; técnica: Colorimétrico automatizado
  - Magnésio (mg/dL) — referência: 0 1.7 - 2.6; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 2.5 - 6.1; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 5.4 - 7.8; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 10 - 114; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 30 - 60; tipo: numérico; técnica: Cinético UV automatizado
  - Sódio (mEq/L) — referência: 0 140 - 150; tipo: numérico; técnica: Eletrodo ion seletivo
  - Potássio (mEq/L) — referência: 0 3.5 - 5.5; tipo: numérico; técnica: Eletrodo ion seletivo
  - Cálcio iônico (mmol/L) — referência: 0 1.15 - 1.4; tipo: numérico; técnica: Eletrodo ion seletivo
  - CK-MB (U/L) — referência: 0 -; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato (mg/dL) — referência: 0 -; tipo: numérico; técnica: Cinético UV automatizado
  - Colesterol HDL (mg/dL) — referência: 0 -; tipo: numérico; técnica: Cinético UV automatizado
  - Frutosamina (µmol/L) — referência: 0 219 - 340; tipo: numérico; técnica: Colorimétrico automatizado
#### B_CHECK UP + COL + TRIG_FELINOS - labvet

- Arquivo: `Gato 2026\B_CHECK UP + COL + TRIG_FELINOS - labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 11
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 2.1 - 3.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 0 - 90; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 5 - 60; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 0 - 50; tipo: numérico; técnica: Cinético UV automatizado
  - Colesterol Total (mg/dL) — referência: 80 - 250; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0.5 - 1.9; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 0 - 10; tipo: numérico; técnica: Cinético UV automatizado
  - Globulinas (g/dL) — referência: 0 2.6 - 5.1; tipo: numérico
  - Proteínas totais (g/dL) — referência: 0 5.4 - 7.8; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 10 - 114; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 30 - 60; tipo: numérico; técnica: Cinético UV automatizado
#### B_CHECK UP + FOSF + COL + TRIG_FELINOS - labvet

- Arquivo: `Gato 2026\B_CHECK UP + FOSF + COL + TRIG_FELINOS - labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 12
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 2.1 - 3.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 0 - 90; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 5 - 60; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 - 50; tipo: numérico; técnica: Cinético UV automatizado
  - Colesterol Total (mg/dL) — referência: 0 80 - 250; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.5 - 1.9; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 0 0 - 10; tipo: numérico; técnica: Cinético UV automatizado
  - Globulinas (g/dL) — referência: 0 2.6 - 5.1; tipo: numérico
  - Proteínas totais (g/dL) — referência: 0 5.4 - 7.8; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 10 - 114; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 2.5 - 6.1; tipo: numérico; técnica: Cinético UV automatizado
  - Uréia (mg/dL) — referência: 0 30 - 60; tipo: numérico; técnica: Cinético UV automatizado
#### B_CHECK UP +GLICOSE + FOSF + COL + TRIG_FELINOS - labvet

- Arquivo: `Gato 2026\B_CHECK UP +GLICOSE + FOSF + COL + TRIG_FELINOS - labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 13
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 2.1 - 3.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 0 - 90; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 5 - 60; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 - 50; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0 0.5 - 1.9; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 0 0 - 10; tipo: numérico; técnica: Cinético UV automatizado
  - Globulinas (g/dL) — referência: 0 2.6 - 5.1; tipo: numérico
  - Proteínas totais (g/dL) — referência: 0 5.4 - 7.8; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 30 - 60; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 61 - 124; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 80 - 250; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 10 - 114; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 2.5 - 6.1; tipo: numérico; técnica: Cinético UV automatizado
#### B_CHECKUP+FOS+CA_FEL - Labvet

- Arquivo: `Gato 2026\B_CHECKUP+FOS+CA_FEL - Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 11
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 2.1 - 3.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 - 90; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 5 - 60; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 - 50; tipo: numérico; técnica: Cinético UV automatizado
  - GGT (U/L) — referência: 0 0 - 10; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 5.4 - 7.8; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 2.6 - 5.1; tipo: numérico
  - Creatinina (mg/dL) — referência: 0.5 - 1.9; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 30 - 60; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 8 - 10.8; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 2.5 - 6.1; tipo: numérico; técnica: Cinético UV automatizado
#### B_CHECKUP+FOS_FEL - Labvet

- Arquivo: `Gato 2026\B_CHECKUP+FOS_FEL - Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 10
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 2.1 - 3.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 - 90; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 5 - 60; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 - 50; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0.5 - 1.9; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 0 0 - 10; tipo: numérico; técnica: Cinético UV automatizado
  - Fósforo (mg/dL) — referência: 0 2.5 - 6.1; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 5.4 - 7.8; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 30 - 60; tipo: numérico; técnica: Cinético UV automatizado
  - Globulinas (g/dL) — referência: 2.6 - 5.1; tipo: numérico
#### B_CHECKUP_FEL - Labvet

- Arquivo: `Gato 2026\B_CHECKUP_FEL - Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 10
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 2.1 - 3.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 0 - 90; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 5 - 60; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 0 - 50; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0 0.5 - 1.9; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 0 0 - 10; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 5.4 - 7.8; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 30 - 60; tipo: numérico; técnica: Cinético UV automatizado
  - Globulinas (g/dL) — referência: 2.6 - 5.1; tipo: numérico
  - 1037 — referência: 2024-07-17 00:00:00 3026 Emilia Beatriz Soares Rodrigues Fel 2A F SRD HVPA /Felinos; tipo: misto
#### B_CHECKUP_FEL+BIL - Labvet

- Arquivo: `Gato 2026\B_CHECKUP_FEL+BIL - Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 11
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 2.1 - 3.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 - 90; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 5 - 60; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 - 50; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0.5 - 1.9; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 0 - 10; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 5.4 - 7.8; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 30 - 60; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 0.04 - 0.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0.1 - 0.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 2.6 - 5.1; tipo: numérico
#### B_HEP_FEL - Labvet

- Arquivo: `Gato 2026\B_HEP_FEL - Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 11
- Estrutura de analitos:
  - Albumina (mg/dL) — referência: 0 2.1 - 3.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 0 - 90; tipo: numérico; técnica: Cinético automatizado
  - ALT (U/L) — referência: 0 5 - 60; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 9.2 - 40; tipo: numérico; técnica: Cinético automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 0.04 - 0.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0.1 - 0.7; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 0 0 - 10; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (mg/dL) — referência: 0 5.4 - 7.8; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 80 - 250; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 30 - 60; tipo: numérico; técnica: Cinético automatizado
  - Globulinas (g/dL) — referência: 2.6 - 5.1; tipo: numérico
#### B_LIQ_CAV_FEL - Labvet

- Arquivo: `Gato 2026\B_LIQ_CAV_FEL - Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 6
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 2.1 - 3.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 80 - 250; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.5 - 1.9; tipo: numérico; técnica: Colorimétrico automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 58 - 120; tipo: numérico; técnica: Colorimétrico automatizado
  - Proteínas totais (g/dL) — referência: 0 5.4 - 7.8; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 10 - 114; tipo: numérico; técnica: Colorimétrico automatizado
#### B_POP_FEL - Labvet

- Arquivo: `Gato 2026\B_POP_FEL - Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 7
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 2.1 - 3.3; tipo: numérico; técnica: Colorimétrico automatizado
  - ALT (U/L) — referência: 0 5 - 60; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0 0.5 - 1.9; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 0 0 - 10; tipo: numérico; técnica: Cinético UV automatizado
  - Globulinas (g/dL) — referência: 0 2.6 - 5.1; tipo: numérico
  - Proteínas totais (g/dL) — referência: 0 5.4 - 7.8; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 30 - 60; tipo: numérico; técnica: Cinético UV automatizado
#### B_RENAL_FEL - Labvet

- Arquivo: `Gato 2026\B_RENAL_FEL - Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 3
- Estrutura de analitos:
  - Creatinina (mg/dL) — referência: 0.5 - 1.9; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 2.5 - 6.1; tipo: numérico; técnica: Cinético UV automatizado
  - Uréia (mg/dL) — referência: 30 - 60; tipo: numérico; técnica: Cinético UV automatizado
#### Bioquímica - Projeto Magda

- Arquivo: `Gato 2026\Bioquímica - Projeto Magda.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 8
- Estrutura de analitos:
  - Fosfatase Alcalina (U/L) — referência: 0 - 90; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 5 - 60; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0.04 - 0.3; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0.1 - 0.7; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0.5 - 1.9; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 0 - 10; tipo: numérico; técnica: Cinético UV automatizado
  - Uréia (mg/dL) — referência: 30 - 60; tipo: numérico; técnica: Cinético UV automatizado
  - 1037 — referência: 2024-07-17 00:00:00 3026 Emilia Beatriz Soares Rodrigues Fel 2A F SRD HVPA /Felinos; tipo: misto
#### CITOLOGIA_FEL - Labvet

- Arquivo: `Gato 2026\CITOLOGIA_FEL - Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 0
- Estrutura de analitos: não identificada automaticamente; requer revisão manual.
#### COAGULOGRAMA_FEL-LABVET

- Arquivo: `Gato 2026\COAGULOGRAMA_FEL-LABVET.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 2
- Estrutura de analitos:
  - Tempo de Protrombina (TP) — referência: 13 - 20; tipo: numérico
  - Tempo de Tromboplastina Parcial Ativada (TTPa) — referência: 96 - 124; tipo: numérico
#### COAGU_Fel - Labvet

- Arquivo: `Gato 2026\COAGU_Fel - Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 2
- Estrutura de analitos:
  - Tempo de Protrombina (TP) — referência: 13 - 20; tipo: numérico
  - Tempo de Tromboplastina Parcial Ativada (TTPa) — referência: 96 - 124; tipo: numérico
#### COMPATIBILIDADE_FEL - Labvet

- Arquivo: `Gato 2026\COMPATIBILIDADE_FEL - Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 2
- Estrutura de analitos:
  - Doador — referência: 24 - 45 5.5 - 8; tipo: numérico
  - Receptor — referência: 24 - 45 5.5 - 8; tipo: numérico
#### HEM_FEL_Ad - Labvet 2024

- Arquivo: `Gato 2026\HEM_FEL_Ad - Labvet 2024.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 5 - 10; tipo: numérico
  - Hemoglobina (g/dL) — referência: 8 - 15; tipo: numérico
  - Hematócrito (%) — referência: 24 - 45; tipo: numérico
  - VCM (fL) — referência: 39 - 55; tipo: numérico
  - CHCM (g/dL) — referência: 30 - 36; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 - 1; tipo: numérico
  - Leucócitos — referência: 5500 - 19500; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 3 0 - 300; tipo: numérico
  - Segmentados — referência: 35 75 2500 - 12500; tipo: numérico
  - Linfócitos — referência: 20 55 1500 - 7000; tipo: numérico
  - Monócitos — referência: 1 4 0 - 850; tipo: numérico
  - Eosinófilos — referência: 1 10 100 - 1500; tipo: numérico
  - Basófilos — referência: raros raros; tipo: texto
  - Proteínas (g/dL) — referência: 6 - 8; tipo: numérico
#### HEM_FEL_Ad - RETICULOCITOS - Labvet 2024

- Arquivo: `Gato 2026\HEM_FEL_Ad - RETICULOCITOS - Labvet 2024.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 18
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 5 - 10; tipo: numérico
  - Hemoglobina (g/dL) — referência: 8 - 15; tipo: numérico
  - Hematócrito (%) — referência: 24 - 45; tipo: numérico
  - VCM (fL) — referência: 39 - 55; tipo: numérico
  - CHCM (g/dL) — referência: 30 - 36; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0 - 1; tipo: numérico
  - Leucócitos — referência: 5500 - 19500; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 3 0 - 300; tipo: numérico
  - Segmentados — referência: 35 75 2500 - 12500; tipo: numérico
  - Linfócitos — referência: 20 55 1500 - 7000; tipo: numérico
  - Monócitos — referência: 1 4 0 - 850; tipo: numérico
  - Eosinófilos — referência: 1 10 100 - 1500; tipo: numérico
  - Basófilos — referência: raros raros; tipo: texto
  - Proteínas (g/dL) — referência: 6 - 8; tipo: numérico
  - Valor Absoluto Agregados (céls./µL) — referência: (>60.000/µL: Anemia regenerativa); tipo: misto
  - 1039 — referência: 2024-07-17 00:00:00 650 Twix Rafael Lima Renno Fel 7A M SRD HVPA/Felinos; tipo: misto
#### HEM_FEL_filhote - Labvet 2024

- Arquivo: `Gato 2026\HEM_FEL_filhote - Labvet 2024.xlsx`
- Tipo de animal: Gato
- Idade: filhote
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 3.5 - 8; tipo: numérico
  - Hemoglobina (g/dL) — referência: 7 - 14; tipo: numérico
  - Hematócrito (%) — referência: 22 - 38; tipo: numérico
  - VCM (fL) — referência: 40 - 55; tipo: numérico
  - CHCM (g/dL) — referência: 31 - 35; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0 - 1; tipo: numérico
  - Leucócitos — referência: 6000 - 17000; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 1 0 - 150; tipo: numérico
  - Segmentados — referência: 40 75 2400 - 12750; tipo: numérico
  - Linfócitos — referência: 20 50 1200 - 8500; tipo: numérico
  - Monócitos — referência: 1 4 100 - 680; tipo: numérico
  - Eosinófilos — referência: 1 10 0 - 1700; tipo: numérico
  - Basófilos — referência: 0 raros raros; tipo: misto
  - Proteínas (g/dL) — referência: 4.5 - 7.8; tipo: numérico
#### HEM_FEL_filhote - RETICULOCITOS - AMA - Labvet 2024

- Arquivo: `Gato 2026\HEM_FEL_filhote - RETICULOCITOS - AMA - Labvet 2024.xlsx`
- Tipo de animal: Gato
- Idade: filhote
- Analitos identificados: 17
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 3.5 - 8; tipo: numérico
  - Hemoglobina (g/dL) — referência: 7 - 14; tipo: numérico
  - Hematócrito (%) — referência: 22 - 38; tipo: numérico
  - VCM (fL) — referência: 40 - 55; tipo: numérico
  - CHCM (g/dL) — referência: 31 - 35; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0 - 1; tipo: numérico
  - Leucócitos — referência: 6000 - 17000; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 1 0 - 150; tipo: numérico
  - Segmentados — referência: 40 75 2400 - 12750; tipo: numérico
  - Linfócitos — referência: 20 50 1200 - 8500; tipo: numérico
  - Monócitos — referência: 1 4 100 - 680; tipo: numérico
  - Eosinófilos — referência: 1 10 0 - 1700; tipo: numérico
  - Basófilos — referência: 0 raros raros; tipo: misto
  - Proteínas (g/dL) — referência: 4.5 - 7.8; tipo: numérico
  - Valor Absoluto Pontilhados (céls./µL) — referência: (>60.000/µL: Anemia regerenativa); tipo: misto
#### HEM_FEL_filhote - RETICULOCITOS - Labvet 2024

- Arquivo: `Gato 2026\HEM_FEL_filhote - RETICULOCITOS - Labvet 2024.xlsx`
- Tipo de animal: Gato
- Idade: filhote
- Analitos identificados: 17
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 3.5 - 8; tipo: numérico
  - Hemoglobina (g/dL) — referência: 7 - 14; tipo: numérico
  - Hematócrito (%) — referência: 22 - 38; tipo: numérico
  - VCM (fL) — referência: 40 - 55; tipo: numérico
  - CHCM (g/dL) — referência: 31 - 35; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0 - 1; tipo: numérico
  - Leucócitos — referência: 6000 - 17000; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 1 0 - 150; tipo: numérico
  - Segmentados — referência: 40 75 2400 - 12750; tipo: numérico
  - Linfócitos — referência: 20 50 1200 - 8500; tipo: numérico
  - Monócitos — referência: 1 4 100 - 680; tipo: numérico
  - Eosinófilos — referência: 1 10 0 - 1700; tipo: numérico
  - Basófilos — referência: 0 raros raros; tipo: misto
  - Proteínas (g/dL) — referência: 4.5 - 7.8; tipo: numérico
  - Valor Absoluto Pontilhados (céls./µL) — referência: (>60.000/µL: Anemia regerenativa); tipo: misto
#### IMUNO_FEL- Labvet

- Arquivo: `Gato 2026\IMUNO_FEL- Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 1
- Estrutura de analitos:
  - FeLV - — referência: Negativo; tipo: texto
#### IMUNO_LIPASE- FEL- Labvet

- Arquivo: `Gato 2026\IMUNO_LIPASE- FEL- Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 0
- Estrutura de analitos: não identificada automaticamente; requer revisão manual.
#### IMUNO_PARVO_CORONA - FEL - Labvet

- Arquivo: `Gato 2026\IMUNO_PARVO_CORONA - FEL - Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 0
- Estrutura de analitos: não identificada automaticamente; requer revisão manual.
#### LC_LIQUIDO_CAVITARIO_FELINO - Labvet

- Arquivo: `Gato 2026\LC_LIQUIDO_CAVITARIO_FELINO - Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 6
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0; tipo: numérico; técnica: Colorimétrico automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0; tipo: numérico; técnica: Colorimétrico automatizado
  - Proteínas totais (g/dL) — referência: 0; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0; tipo: numérico; técnica: Colorimétrico automatizado
#### T4_FEL - Labvet

- Arquivo: `Gato 2026\T4_FEL - Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 2
- Estrutura de analitos:
  - 0.8 - 2.3 µg/dL — referência: NORMAL; tipo: texto
  - 2.3 - 4.7 µg/dL — referência: NORMAL (ZONA CINZA); tipo: texto
#### Teste de Hemoaglutinação em Salina - Labvet

- Arquivo: `Gato 2026\Teste de Hemoaglutinação em Salina - Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 0
- Estrutura de analitos: não identificada automaticamente; requer revisão manual.
#### U_EAS_Felino - Labvet

- Arquivo: `Gato 2026\U_EAS_Felino - Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 13
- Estrutura de analitos:
  - Volume — referência: > 5mL; tipo: misto
  - pH — referência: 6 - 7; tipo: numérico
  - Glicose — referência: Ausente; tipo: texto
  - Cetonas — referência: Ausentes; tipo: texto
  - Sangue — referência: Ausente; tipo: texto
  - Proteínas — referência: Ausentes; tipo: texto
  - Nitrito — referência: Negativo; tipo: texto
  - Hemácias/campo — referência: (0-4); tipo: numérico
  - Leucócitos/campo — referência: (0-4); tipo: numérico
  - Cristais — referência: Ausentes; tipo: texto
  - Cilindros — referência: Ausentes; tipo: texto
  - Células epiteliais — referência: Ausentes; tipo: texto
  - Demais observações — referência: Ausentes; tipo: texto
#### U_EAS_RPC_Felino - Labvet

- Arquivo: `Gato 2026\U_EAS_RPC_Felino - Labvet.xlsx`
- Tipo de animal: Gato
- Idade: Não indicada
- Analitos identificados: 14
- Estrutura de analitos:
  - Volume — referência: > 5mL; tipo: misto
  - pH — referência: 6 - 7; tipo: numérico
  - Glicose — referência: Ausente; tipo: texto
  - Cetonas — referência: Ausentes; tipo: texto
  - Sangue — referência: Ausente; tipo: texto
  - Proteínas — referência: Ausentes; tipo: texto
  - Nitrito — referência: Negativo; tipo: texto
  - Hemácias/campo — referência: (0-4); tipo: numérico
  - Leucócitos/campo — referência: (0-4); tipo: numérico
  - Cristais — referência: Ausentes; tipo: texto
  - Cilindros — referência: Ausentes; tipo: texto
  - Células epiteliais — referência: Ausentes; tipo: texto
  - Demais observações — referência: Ausentes; tipo: texto
  - Relação prot/creat — referência: < 0,5 (normal); tipo: misto

### Ovino

#### B_AVESSO_BIOQUÍMICA_OVINO - Labvet 2026

- Arquivo: `Ovino 2026\B_AVESSO_BIOQUÍMICA_OVINO - Labvet 2026.xlsx`
- Tipo de animal: Ovino
- Idade: Não indicada
- Analitos identificados: 18
- Estrutura de analitos:
  - ALT (U/L) — referência: 0 15 - 44; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 49 - 123; tipo: numérico; técnica: Cinético UV automatizado
  - Uréia (mg/dL) — referência: 0 10 - 26; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0 0.9 - 2; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 27 - 156; tipo: numérico; técnica: Cinético UV automatizado
  - GGT (U/L) — referência: 0 20 - 44; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 5.9 - 7.8; tipo: numérico; técnica: Colorimétrico automatizado
  - Albumina (g/dL) — referência: 0 2.7 - 3.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 3.2 - 5; tipo: numérico
  - Bilirrubina total (mg/dL) — referência: 0 0 - 0.5; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 -; tipo: numérico; técnica: Cinético UV automatizado
  - Colesterol Total (mg/dL) — referência: 0 44 - 90; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 7.7 - 101; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 83 - 476; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 4 - 7.3; tipo: numérico; técnica: Cinético UV automatizado
  - Triglicerídeos (mg/dL) — referência: 0 -; tipo: numérico; técnica: Colorimétrico automatizado
  - Glicose (mg/dL) — referência: 0 44 - 81; tipo: numérico; técnica: Colorimétrico automatizado
  - Cálcio total (mg/dL) — referência: 0 9.3 - 11.7; tipo: numérico; técnica: Colorimétrico automatizado
#### B_CHECKUP_OVI - Labvet 2026

- Arquivo: `Ovino 2026\B_CHECKUP_OVI - Labvet 2026.xlsx`
- Tipo de animal: Ovino
- Idade: Não indicada
- Analitos identificados: 11
- Estrutura de analitos:
  - AST (U/L) — referência: 49 - 123; tipo: numérico; técnica: Cinético UV automatizado
  - CK (U/L) — referência: 28 - 130; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0.9 - 2; tipo: numérico; técnica: Colorimétrico automatizado
  - LDH (U/L) — referência: 811 - 1250; tipo: numérico; técnica: Cinético UV automatizado
  - Fósforo (mg/dL) — referência: 4 - 7.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 10 - 26; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 5.9 - 7.8; tipo: numérico; técnica: Colorimétrico automatizado
  - Albumina (g/dL) — referência: 2.7 - 3.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 3.2 - 5; tipo: numérico
  - Cálcio total (mg/dL) — referência: 0 9.3 - 11.7; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 0 20 - 44; tipo: numérico; técnica: Cinético UV automatizado
#### HEM_OVI_Ad - Labvet 2026

- Arquivo: `Ovino 2026\HEM_OVI_Ad - Labvet 2026.xlsx`
- Tipo de animal: Ovino
- Idade: Não indicada
- Analitos identificados: 17
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 9 - 15; tipo: numérico
  - Hemoglobina (g/dL) — referência: 9 - 15; tipo: numérico
  - Hematócrito (%) — referência: 27 - 45; tipo: numérico
  - VCM (fL) — referência: 28 - 40; tipo: numérico
  - CHCM (g/dL) — referência: 31 - 34; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0 - 0; tipo: numérico
  - Leucócitos — referência: 4000 - 12000; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 raros raros; tipo: misto
  - Segmentados — referência: 10 50 700 - 6000; tipo: numérico
  - Linfócitos — referência: 40 75 2000 - 9000; tipo: numérico
  - Monócitos — referência: 0 6 0 - 750; tipo: numérico
  - Eosinófilos — referência: 0 10 0 - 1000; tipo: numérico
  - Basófilos — referência: 0 0 3 0 - 300; tipo: numérico
  - Proteínas (g/dL) — referência: 6 - 7.5; tipo: numérico
  - Fibrinogênio (g/dL) — referência: 0.1 - 0.5; tipo: numérico
#### U_EAS_OVINO - Labvet 2026

- Arquivo: `Ovino 2026\U_EAS_OVINO - Labvet 2026.xlsx`
- Tipo de animal: Ovino
- Idade: Não indicada
- Analitos identificados: 14
- Estrutura de analitos:
  - Volume — referência: > 5 ml; tipo: misto
  - pH — referência: 7.5 - 8.5; tipo: numérico
  - Glicose — referência: Ausente; tipo: texto
  - Cetonas — referência: Ausente; tipo: texto
  - Sangue — referência: Ausente; tipo: texto
  - Proteínas — referência: Ausente; tipo: texto
  - Leucócitos — referência: Ausente; tipo: texto
  - Nitrito — referência: Negativo; tipo: texto
  - Hemácias/campo — referência: (0-4); tipo: numérico
  - Leucócitos/campo — referência: (0-4); tipo: numérico
  - Cristais — referência: Ausente; tipo: texto
  - Cilindros — referência: Ausente; tipo: texto
  - Células epiteliais — referência: Ausente; tipo: texto
  - Demais observações — referência: Ausente; tipo: texto

### Sem agrupamento

#### MODELO DE COMPATIBILIDADE COM 2 DOADORES PARA QUALQUER ESPECIE

- Arquivo: `MODELO DE COMPATIBILIDADE COM 2 DOADORES PARA QUALQUER ESPECIE.xlsx`
- Tipo de animal: Sem agrupamento
- Idade: Não indicada
- Analitos identificados: 4
- Estrutura de analitos:
  - Doador 1 — referência: 0 - 0 0 - 0; tipo: numérico
  - Doador 2 — referência: 0 - 0 0 - 0; tipo: numérico
  - Receptor — referência: 0 - 0 0 - 0; tipo: numérico
  - Doador 1 — referência: Doador 2; tipo: misto

### Silvestres > Aves

#### Agapornis - HEMOGRAMA 2026

- Arquivo: `Silvestres 2026\Aves\Agapornis - HEMOGRAMA 2026.xlsx`
- Tipo de animal: Silvestres > Aves
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 3 - 5.1; tipo: numérico
  - Hemoglobina (g/dL) — referência: 13 - 18; tipo: numérico
  - Hematócrito (%) — referência: 44 - 57; tipo: numérico
  - VCM (fL) — referência: 90 - 190; tipo: numérico
  - CHCM (g/dL) — referência: 22 - 32; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 3000 - 16000; tipo: numérico
  - Mielócitos — referência: 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0; tipo: numérico
  - Bastões — referência: 0 0; tipo: numérico
  - Heterófilos — referência: 1200 - 12000; tipo: numérico
  - Linfócitos — referência: 600 - 8800; tipo: numérico
  - Monócitos — referência: 0 - 320; tipo: numérico
  - Eosinófilos — referência: 0 - 160; tipo: numérico
  - Basófilos — referência: 0 0 - 960; tipo: numérico
  - Fonte: — referência: Cubas et al. Tratado de animais selvagens: medicina veterinária, 2.ed. 2014.; tipo: misto
#### CALOPSITA - BIOQ Labvet 2026

- Arquivo: `Silvestres 2026\Aves\CALOPSITA - BIOQ Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Aves
- Idade: Não indicada
- Analitos identificados: 20
- Estrutura de analitos:
  - Ácido Úrico (mg/dL) — referência: 0 3.5 - 11; tipo: numérico
  - Albumina (g/dL) — referência: 0 0.7 - 1.8; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 0 - 346; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 0 - 9; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 100 - 396; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 -; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0.1 - 0.8; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 8.5 - 13; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 140 - 360; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.1 - 0.4; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 30 - 245; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 200 - 450; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 0.3 - 1.9; tipo: numérico
  - GGT (U/L) — referência: 0 0 - 5; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 125 - 450; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 3.2 - 4.8; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 2.4 - 4.1; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 77 - 380; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 1 - 5; tipo: numérico; técnica: Cinético UV automatizado
  - Fonte: — referência: Cubas et al. Tratado de animais selvagens: medicina veterinária, 2.ed. 2014 & ISIS, 2002.; tipo: misto
#### CALOPSITA - HEM Labvet 2026

- Arquivo: `Silvestres 2026\Aves\CALOPSITA - HEM Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Aves
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 2.54 - 4.7; tipo: numérico
  - Hemoglobina (g/dL) — referência: 11 - 16; tipo: numérico
  - Hematócrito (%) — referência: 45 - 54; tipo: numérico
  - VCM (fL) — referência: 90 - 200; tipo: numérico
  - CHCM (g/dL) — referência: 22 - 33; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 5000 - 13000; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0; tipo: numérico
  - Segmentados — referência: 4000 - 7000; tipo: numérico
  - Linfócitos — referência: 2500 - 5500; tipo: numérico
  - Monócitos — referência: 0 - 200; tipo: numérico
  - Eosinófilos — referência: 0 - 200; tipo: numérico
  - Basófilos — referência: 0 0 - 600; tipo: numérico
  - Fonte: — referência: Cubas et al. Tratado de animais selvagens: medicina veterinária, 2.ed. 2014; tipo: misto
#### CISNE NEGRO - BIOQ Labvet 2026

- Arquivo: `Silvestres 2026\Aves\CISNE NEGRO - BIOQ Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Aves
- Idade: Não indicada
- Analitos identificados: 18
- Estrutura de analitos:
  - Ácido Úrico (mg/dL) — referência: 0 2.5 - 7.6; tipo: numérico
  - Albumina (g/dL) — referência: 0 1.6 - 2.4; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 0 - 396; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 0 - 74; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0 - 0.4; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 0 - 21; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 105 - 293; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.1 - 0.5; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 0 - 518; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 104 - 188; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 2.1 - 4.5; tipo: numérico
  - GGT (U/L) — referência: 0 0 - 18; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 0 - 1139; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 0 - 9.4; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 3.9 - 6.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 0 - 489; tipo: numérico; técnica: Colorimétrico automatizado
  - Relação Albumina:Globulina — referência: 0 - - -; tipo: numérico
  - Fonte: — referência: I.S.I.S., 1999.; tipo: misto
#### CISNE NEGRO - HEM Labvet 2026

- Arquivo: `Silvestres 2026\Aves\CISNE NEGRO - HEM Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Aves
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 1.11 - 4.23; tipo: numérico
  - Hemoglobina (g/dL) — referência: 6.9 - 21.7; tipo: numérico
  - Hematócrito (%) — referência: 31 - 53; tipo: numérico
  - VCM (fL) — referência: 60 - 283; tipo: numérico
  - CHCM (g/dL) — referência: 21.2 - 44.4; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 5100 - 24400; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0; tipo: numérico
  - Heterófilos — referência: 0 - 15000; tipo: numérico
  - Linfócitos — referência: 2600 - 9800; tipo: numérico
  - Monócitos — referência: 0 - 1500; tipo: numérico
  - Eosinófilos — referência: 0 - 2400; tipo: numérico
  - Basófilos — referência: 0 80 - 420; tipo: numérico
  - Fonte: — referência: I.S.I.S., 1999.; tipo: misto
#### Coruja Orelhuda - HEMOGRAMA 2026

- Arquivo: `Silvestres 2026\Aves\Coruja Orelhuda - HEMOGRAMA 2026.xlsx`
- Tipo de animal: Silvestres > Aves
- Idade: Não indicada
- Analitos identificados: 18
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 1.1 - 2.3; tipo: numérico
  - Hemoglobina (g/dL) — referência: 6.7 - 15.3; tipo: numérico
  - Hematócrito (%) — referência: 30 - 50; tipo: numérico
  - VCM (fL) — referência: 123.8 - 355.2; tipo: numérico
  - CHCM (g/dL) — referência: 17.1 - 38.6; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 1200 - 23600; tipo: numérico
  - Mielócitos — referência: 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0; tipo: numérico
  - Bastões — referência: 0 0; tipo: numérico
  - Heterófilos — referência: 600 - 16600; tipo: numérico
  - Linfócitos — referência: 600 - 10200; tipo: numérico
  - Monócitos — referência: 0 - 210; tipo: numérico
  - Eosinófilos — referência: 0 - 1900; tipo: numérico
  - Basófilos — referência: 0 0 - 1000; tipo: numérico
  - Trombócitos (céls/µL) — referência: 10800 - 56600; tipo: numérico
  - Proteínas (g/dL) — referência: 3.1 - 4.7; tipo: numérico
  - Fonte: — referência: GOULART, Miúriel de Aquino et al. Hematological parameters and total plasma protein values of captive strigiformes occurring in Brazil. Semina: Ciências Agrárias, p. 2129–2142, 7 ago. 2020.; tipo: misto
#### GALO DOMÉSTICO - BIOQ Labvet 2026

- Arquivo: `Silvestres 2026\Aves\GALO DOMÉSTICO - BIOQ Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Aves
- Idade: Não indicada
- Analitos identificados: 18
- Estrutura de analitos:
  - Ácido Úrico (mg/dL) — referência: 0 1.6 - 11.8; tipo: numérico
  - Albumina (g/dL) — referência: 0 1.2 - 2.4; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 55 - 2345; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 98 - 294; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0 - 0.5; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 8.4 - 26; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 42 - 218; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.1 - 0.5; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 200 - 3589; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 187 - 319; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 1.1 - 4.7; tipo: numérico
  - GGT (U/L) — referência: 0 8 - 48; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 92 - 912; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 1.9 - 9; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 2.3 - 6.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 51 - 1365; tipo: numérico; técnica: Colorimétrico automatizado
  - Relação Albumina:Globulina — referência: 0 -; tipo: numérico
  - Fonte: — referência: I.S.I.S., 2002.; tipo: misto
#### GALO DOMÉSTICO - HEM Labvet 2026

- Arquivo: `Silvestres 2026\Aves\GALO DOMÉSTICO - HEM Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Aves
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 1.35 - 4.59; tipo: numérico
  - Hemoglobina (g/dL) — referência: 6.2 - 15.4; tipo: numérico
  - Hematócrito (%) — referência: 22.8 - 44.4; tipo: numérico
  - VCM (fL) — referência: 71.7 - 170.9; tipo: numérico
  - CHCM (g/dL) — referência: 20.1 - 40.6; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 5970 - 26950; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0; tipo: numérico
  - Segmentados — referência: 1755 - 8589; tipo: numérico
  - Linfócitos — referência: 864 - 8579; tipo: numérico
  - Monócitos — referência: 0 - 2682; tipo: numérico
  - Eosinófilos — referência: 43 - 1672; tipo: numérico
  - Basófilos — referência: 0 0 - 1304; tipo: numérico
  - Fonte: — referência: I.S.I.S., 2002.; tipo: misto
#### GANSO BRAVO - BIOQ Labvet 2026

- Arquivo: `Silvestres 2026\Aves\GANSO BRAVO - BIOQ Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Aves
- Idade: Não indicada
- Analitos identificados: 17
- Estrutura de analitos:
  - Ácido Úrico (mg/dL) — referência: 0 1.4 - 14.4; tipo: numérico
  - Albumina (g/dL) — referência: 0 1.1 - 2.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 44 - 830; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 4 - 23; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 8 - 121; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 3.2 - 19.2; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 161 - 233; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.2 - 0.6; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 76 - 571; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 19 - 319; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 1.6 - 4.8; tipo: numérico
  - GGT (U/L) — referência: 0 0 - 4; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 108 - 1209; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 1.8 - 5.8; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 1.8 - 7; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 99 - 407; tipo: numérico; técnica: Colorimétrico automatizado
  - Fonte: — referência: I.S.I.S., 2002.; tipo: misto
#### GANSO BRAVO - HEM Labvet 2026

- Arquivo: `Silvestres 2026\Aves\GANSO BRAVO - HEM Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Aves
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 1.4 - 3.88; tipo: numérico
  - Hemoglobina (g/dL) — referência: 12.7 - 15.5; tipo: numérico
  - Hematócrito (%) — referência: 24.1 - 54.9; tipo: numérico
  - VCM (fL) — referência: 100 - 224.8; tipo: numérico
  - CHCM (g/dL) — referência: 29.7 - 36.1; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 5220 - 25760; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0; tipo: numérico
  - Heterófilos — referência: 1512 - 14762; tipo: numérico
  - Linfócitos — referência: 1120 - 13545; tipo: numérico
  - Monócitos — referência: 40 - 5144; tipo: numérico
  - Eosinófilos — referência: 138 - 1024; tipo: numérico
  - Basófilos — referência: 0 102 - 1112; tipo: numérico
  - Fonte: — referência: I.S.I.S., 2002.; tipo: misto
#### GARÇA BRANCA - BIOQ Labvet 2026

- Arquivo: `Silvestres 2026\Aves\GARÇA BRANCA - BIOQ Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Aves
- Idade: Não indicada
- Analitos identificados: 17
- Estrutura de analitos:
  - Ácido Úrico (mg/dL) — referência: 0 1.9 - 7.5; tipo: numérico
  - Albumina (g/dL) — referência: 0 1.3 - 2.1; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 54 - 186; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 0 - 110; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 94 - 184; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 7.8 - 9.6; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 140 - 226; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.1 - 0.7; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 2 - 626; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 241 - 321; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 1.3 - 2.3; tipo: numérico
  - GGT (U/L) — referência: 0 0 - 15; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 41 - 325; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 1.3 - 5.3; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 3 - 4; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 18 - 260; tipo: numérico; técnica: Colorimétrico automatizado
  - Fonte: — referência: I.S.I.S., 1999.; tipo: misto
#### GARÇA BRANCA - Hem Labvet 2026

- Arquivo: `Silvestres 2026\Aves\GARÇA BRANCA - Hem Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Aves
- Idade: Não indicada
- Analitos identificados: 9
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 2 - 3.48; tipo: numérico
  - Hemoglobina (g/dL) — referência: 7.9 - 14.9; tipo: numérico
  - Hematócrito (%) — referência: 38.4 - 51.8; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0; tipo: numérico
  - Basófilos — referência: 0 -; tipo: numérico
  - Fonte: — referência: I.S.I.S., 1999.; tipo: misto
#### GARÇA VAQUEIRA - BIOQ Labvet 2026

- Arquivo: `Silvestres 2026\Aves\GARÇA VAQUEIRA - BIOQ Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Aves
- Idade: Não indicada
- Analitos identificados: 17
- Estrutura de analitos:
  - Ácido Úrico (mg/dL) — referência: 0 0.8 - 13.4; tipo: numérico
  - Albumina (g/dL) — referência: 0 1.1 - 2.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 7 - 266; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 -; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 21 - 316; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 -; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 -; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 -; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 644 - 4195; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 -; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 -; tipo: numérico
  - GGT (U/L) — referência: 0 -; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 -; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 -; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 2 - 5.2; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 -; tipo: numérico; técnica: Colorimétrico automatizado
  - Fonte: — referência: Cubas, Silva e Catão-Dias. Tratado de animais selvagens: medicina veterinária, 2. ed. São Paulo: Roca, 2014.; tipo: misto
#### GARÇA VAQUEIRA - HEM Labvet 2026

- Arquivo: `Silvestres 2026\Aves\GARÇA VAQUEIRA - HEM Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Aves
- Idade: Não indicada
- Analitos identificados: 14
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 2.03 - 4.35; tipo: numérico
  - Hemoglobina (g/dL) — referência: 10.5 - 18.9; tipo: numérico
  - Hematócrito (%) — referência: 39 - 63; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 1200 - 17050; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0; tipo: numérico
  - Heterófilos — referência: 350 - 11420; tipo: numérico
  - Linfócitos — referência: 190 - 7500; tipo: numérico
  - Monócitos — referência: 410 - 1350; tipo: numérico
  - Eosinófilos — referência: 20 - 1790; tipo: numérico
  - Basófilos — referência: 0 20 - 850; tipo: numérico
  - Fonte: — referência: Cubas, Silva e Catão-Dias. Tratado de animais selvagens: medicina veterinária, 2. ed. São Paulo: Roca, 2014.; tipo: misto
#### POMBO COMUM - BIOQ Labvet 2026

- Arquivo: `Silvestres 2026\Aves\POMBO COMUM - BIOQ Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Aves
- Idade: Não indicada
- Analitos identificados: 17
- Estrutura de analitos:
  - Ácido Úrico (mg/dL) — referência: 0 0.4 - 11.2; tipo: numérico
  - Albumina (g/dL) — referência: 0 1.1 - 1.54; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 0 - 942; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 10 - 46; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 21 - 201; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 4.1 - 13.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 181 - 381; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0 - 0.4; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 266 - 1523; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 151 - 519; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 0.5 - 2.1; tipo: numérico
  - GGT (U/L) — referência: 0 0 - 21; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 40 - 376; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 1.1 - 6.2; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 2 - 3.6; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 81 - 393; tipo: numérico; técnica: Colorimétrico automatizado
  - Fonte: — referência: I.S.I.S., 1999.; tipo: misto
#### POMBO COMUM - HEM Labvet 2026

- Arquivo: `Silvestres 2026\Aves\POMBO COMUM - HEM Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Aves
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 2.67 - 4.43; tipo: numérico
  - Hemoglobina (g/dL) — referência: 11.3 - 18.5; tipo: numérico
  - Hematócrito (%) — referência: 38.8 - 59.2; tipo: numérico
  - VCM (fL) — referência: 103.3 - 185.3; tipo: numérico
  - CHCM (g/dL) — referência: 16.5 - 42.9; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 5840 - 26960; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0; tipo: numérico
  - Segmentados — referência: 576 - 13400; tipo: numérico
  - Linfócitos — referência: 2338 - 15510; tipo: numérico
  - Monócitos — referência: 192 - 2562; tipo: numérico
  - Eosinófilos — referência: 0 - 74; tipo: numérico
  - Basófilos — referência: 0 0 - 0; tipo: numérico
  - Fonte: — referência: I.S.I.S, 1999; tipo: misto
#### TUCANO TOCO - BIOQ Labvet 2026

- Arquivo: `Silvestres 2026\Aves\TUCANO TOCO - BIOQ Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Aves
- Idade: Não indicada
- Analitos identificados: 17
- Estrutura de analitos:
  - Ácido Úrico (mg/dL) — referência: 0 4.3 - 15.7; tipo: numérico
  - Albumina (g/dL) — referência: 0 1.3 - 1.9; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 69 - 381; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 0 - 55; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 132 - 350; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 8 - 10.2; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 117 - 179; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.1 - 0.5; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 0 - 3384; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 257 - 401; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 1.5 - 2.9; tipo: numérico
  - GGT (U/L) — referência: 0 5 - 17; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 123 - 871; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 2.7 - 6.3; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 2.8 - 4.8; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 67 - 205; tipo: numérico; técnica: Colorimétrico automatizado
  - Fonte: — referência: I.S.I.S., 1999.; tipo: misto
#### TUCANO TOCO - HEM Labvet 2026

- Arquivo: `Silvestres 2026\Aves\TUCANO TOCO - HEM Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Aves
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 2.45 - 2.97; tipo: numérico
  - Hemoglobina (g/dL) — referência: 13.8 - 18; tipo: numérico
  - Hematócrito (%) — referência: 43.6 - 55; tipo: numérico
  - VCM (fL) — referência: 161 - 200.2; tipo: numérico
  - CHCM (g/dL) — referência: 26.2 - 34.8; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 3977 - 15811; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0; tipo: numérico
  - Heterófilos — referência: 969 - 5985; tipo: numérico
  - Linfócitos — referência: 1513 - 9181; tipo: numérico
  - Monócitos — referência: 0 - 2019; tipo: numérico
  - Eosinófilos — referência: 0 - 633; tipo: numérico
  - Basófilos — referência: 0 23 - 427; tipo: numérico
  - Fonte: — referência: I.S.I.S., 1999.; tipo: misto

### Silvestres > Mamíferos

#### ANTA_B

- Arquivo: `Silvestres 2026\Mamíferos\ANTA_B.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: 2 ano
- Analitos identificados: 13
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 1.8 - 4.2; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 2 - 101; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 2 - 33; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 28 - 257; tipo: numérico; técnica: Cinético UV automatizado
  - Colesterol Total (mg/dL) — referência: 83 - 392; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0.6 - 2; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 28 - 257; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 5 - 8.6; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 2.3 - 5.4; tipo: numérico
  - Triglicerídeos (mg/dL) — referência: 16 - 106; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 3 - 19; tipo: numérico; técnica: Cinético UV automatizado
  - CK (U/L) — referência: 55 - 418; tipo: numérico; técnica: Colorimétrico automatizado
  - 1042 — referência: 2024-07-17 00:00:00 7811 Kyra Clarissa Angélica Azevedo Can 7A F SRD HVPA/Oncologia Obesidade, hiporexia, letargia. Mastocitoma há 2 anos 7, 21, 27; tipo: misto
#### ANTA_H

- Arquivo: `Silvestres 2026\Mamíferos\ANTA_H.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 5.16 - 12.8; tipo: numérico
  - Hemoglobina (g/dL) — referência: 9.5 - 17.9; tipo: numérico
  - Hematócrito (%) — referência: 27 - 63; tipo: numérico
  - VCM (fL) — referência: 30.9 - 94.1; tipo: numérico
  - CHCM (g/dL) — referência: 19.4 - 60.8; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 3600 - 20000; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 -; tipo: numérico
  - Segmentados — referência: 60 70 2100 - 13900; tipo: numérico
  - Linfócitos — referência: 12 30 5600 - 7700; tipo: numérico
  - Monócitos — referência: 3 10 36 - 1400; tipo: numérico
  - Eosinófilos — referência: 2 10 55 - 3100; tipo: numérico
  - Basófilos — referência: 0 raros raros; tipo: misto
  - Valor Absoluto (céls./µL) — referência: (>60.000/µL: Anemia regererativa); tipo: misto
#### BUGIO (Alouata guariba) BIOQ - Labvet 2025

- Arquivo: `Silvestres 2026\Mamíferos\BUGIO (Alouata guariba) BIOQ - Labvet 2025.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 2.3 - 5.5; tipo: numérico; técnica: Colorimétrico automatizado
  - ALT (U/L) — referência: 0 15.7 - 37; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 69.8 - 130.1; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 - - -; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 - - -; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 - - -; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 133.6 - 194.4; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.7 - 1.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 183.8 - 580.45; tipo: numérico; técnica: Cinético UV automatizado
  - Fósforo (mg/dL) — referência: 0 - - -; tipo: numérico; técnica: Cinético UV automatizado
  - GGT (U/L) — referência: 0 22.8 - 75.65; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 41.25 - 86.5; tipo: numérico; técnica: Colorimétrico automatizado
  - Proteínas totais (g/dL) — referência: 0 4.1 - 7.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 - - -; tipo: numérico; técnica: Colorimétrico automatizado
  - LDH (U/L) — referência: 0 - - -; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 23.8 - 38; tipo: numérico; técnica: Cinético UV automatizado
#### BUGIO (Alouata guariba) HEM - Labvet 2025

- Arquivo: `Silvestres 2026\Mamíferos\BUGIO (Alouata guariba) HEM - Labvet 2025.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 15
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 3.56 - 4.82; tipo: numérico
  - Hemoglobina (g/dL) — referência: 9.5 - 12; tipo: numérico
  - Hematócrito (%) — referência: 30 - 38; tipo: numérico
  - VCM (fL) — referência: 74.8 - 84.6; tipo: numérico
  - CHCM (g/dL) — referência: 30.8 - 33.3; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 5300 - 13300; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 - 0 - 200; tipo: numérico
  - Segmentados — referência: - - 3200 - 10200; tipo: numérico
  - Linfócitos — referência: - - 1100 -; tipo: numérico
  - Monócitos — referência: - - 200 - 1300; tipo: numérico
  - Eosinófilos — referência: - - 0 - 300; tipo: numérico
  - Basófilos — referência: 0 raros raros; tipo: misto
#### CACHORRO-DO-MATO - HEM Labvet 2026

- Arquivo: `Silvestres 2026\Mamíferos\CACHORRO-DO-MATO - HEM Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 2.89 - 5.81; tipo: numérico
  - Hemoglobina (g/dL) — referência: 9.19 - 17.11; tipo: numérico
  - Hematócrito (%) — referência: 27.7 - 50; tipo: numérico
  - VCM (fL) — referência: 79.38 - 101.26; tipo: numérico
  - CHCM (g/dL) — referência: 29.6 - 37.8; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 4060 - 15040; tipo: numérico
  - Mielócitos — referência: 0 0 0 zxxkk; tipo: misto
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0; tipo: numérico
  - Segmentados — referência: 1910 - 10040; tipo: numérico
  - Linfócitos — referência: 570 - 3000; tipo: numérico
  - Monócitos — referência: 80 - 1190; tipo: numérico
  - Eosinófilos — referência: 28 - 3100; tipo: numérico
  - Basófilos — referência: 0 0 - 180; tipo: numérico
  - Fonte: — referência: Mattoso et al. Hematologic, serum biochemistry and urinary values for captive Crab-eating Fox (Cerdocyon thous) in São Paulo state, Brazil, 2012.; tipo: misto
#### CACHORRO-DO-MATO- BIOQ 2026

- Arquivo: `Silvestres 2026\Mamíferos\CACHORRO-DO-MATO- BIOQ 2026.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 1.58 - 4.38; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 0 - 229; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 2.6 - 117; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 -; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 -; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 -; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.55 - 1.5; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 -; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 -; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 1.36 - 5.68; tipo: numérico
  - GGT (U/L) — referência: 0 0.6 - 4.83; tipo: numérico; técnica: Cinético UV automatizado
  - Fósforo (mg/dL) — referência: 0 -; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 4.4 - 8.58; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 -; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 14.5 - 71.6; tipo: numérico; técnica: Cinético UV automatizado
  - Fonte: — referência: Mattoso et al. Hematologic, serum biochemistry and urinary values for captive Crab-eating Fox (Cerdocyon thous) in São Paulo state, Brazil, 2012.; tipo: misto
#### CATETO BIOQUIMICA

- Arquivo: `Silvestres 2026\Mamíferos\CATETO BIOQUIMICA.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: 1 ano
- Analitos identificados: 17
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 3.1 - 4.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 11 - 339; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 5 - 68; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 22 - 82; tipo: numérico; técnica: Cinético UV automatizado
  - Colesterol Total (mg/dL) — referência: 52 - 166; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 1.2 - 2; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 1 - 21; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 5.8 - 8.9; tipo: numérico; técnica: Colorimétrico automatizado
  - Relação Albumina:Globulina — referência: 0.6 - 1.1; tipo: numérico
  - Globulinas (g/dL) — referência: 2.4 - 4.4; tipo: numérico
  - Triglicerídeos (mg/dL) — referência: 40 - 169; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 5 - 20; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 - - -; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 - - -; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 8 - 12; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 4 - 10.5; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 76 - 258; tipo: numérico; técnica: Colorimétrico automatizado
#### CATETO HEMOGRAMA

- Arquivo: `Silvestres 2026\Mamíferos\CATETO HEMOGRAMA.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 15
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 4.85 - 9.76; tipo: numérico
  - Hemoglobina (g/dL) — referência: 8 - 14; tipo: numérico
  - Hematócrito (%) — referência: 24 - 41; tipo: numérico
  - VCM (fL) — referência: 37 - 54; tipo: numérico
  - CHCM (g/dL) — referência: 30 - 42; tipo: numérico
  - Metarrubrícitos (%) — referência: 0; tipo: numérico
  - Leucócitos — referência: 3700 - 33100; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 0 0 -; tipo: numérico
  - Segmentados — referência: 28 71 1664 - 11585; tipo: numérico
  - Linfócitos — referência: 24 65 1248 - 18205; tipo: numérico
  - Monócitos — referência: 0 4 0 - 662; tipo: numérico
  - Eosinófilos — referência: 1 14 60 2648; tipo: numérico
  - Basófilos — referência: 0 2 0 - 178; tipo: numérico
#### COELHO - BIOQ Labvet 2026

- Arquivo: `Silvestres 2026\Mamíferos\COELHO - BIOQ Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 15
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 3.5 - 4.5; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 0 - 122; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 21 - 65; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 13 - 43; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 11.9 - 14.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 23 - 69; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.9 - 1.7; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 0 - 1443; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 97 - 191; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 1.7 - 2.7; tipo: numérico
  - GGT (U/L) — referência: 0 5 - 15; tipo: numérico; técnica: Cinético UV automatizado
  - Fósforo (mg/dL) — referência: 0 3 - 6; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 5.4 - 6.8; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 49 - 99; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 13 - 27; tipo: numérico; técnica: Cinético UV automatizado
#### COELHO - HEM Labvet 2026

- Arquivo: `Silvestres 2026\Mamíferos\COELHO - HEM Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 17
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 4 - 8; tipo: numérico
  - Hemoglobina (g/dL) — referência: 8 - 17.5; tipo: numérico
  - Hematócrito (%) — referência: 30 - 50; tipo: numérico
  - VCM (fL) — referência: 58 - 75; tipo: numérico
  - CHCM (g/dL) — referência: 29 - 37; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 5000 - 12000; tipo: numérico
  - Mielócitos — referência: 0 0 0 zxxkk; tipo: misto
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0; tipo: numérico
  - Heterófilos — referência: 1750 - 6600; tipo: numérico
  - Linfócitos — referência: 1250 - 7200; tipo: numérico
  - Monócitos — referência: 100 - 1200; tipo: numérico
  - Eosinófilos — referência: 0 - 600; tipo: numérico
  - Basófilos — referência: 0 100 - 960; tipo: numérico
  - Fibrinogênio (g/dL) — referência: 0.12 - 0.3; tipo: numérico
  - Fonte: — referência: Carpenter, 2010.; tipo: misto
#### COELHO - URI+REL Labvet

- Arquivo: `Silvestres 2026\Mamíferos\COELHO - URI+REL Labvet.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 13
- Estrutura de analitos:
  - pH — referência: 8 - 9; tipo: numérico
  - Glicose — referência: Ausente; tipo: texto
  - Cetonas — referência: Ausente à (+); tipo: texto
  - Sangue — referência: Ausente; tipo: texto
  - Proteínas — referência: Ausente à (+); tipo: texto
  - Bilirrubina — referência: Negativo; tipo: texto
  - Hemácias/campo — referência: Ausente; tipo: texto
  - Leucócitos/campo — referência: (0-25); tipo: numérico
  - Cristais — referência: Ausente; tipo: texto
  - Cilindros — referência: Ausente; tipo: texto
  - Células epiteliais — referência: Ausentes/Raras; tipo: texto
  - Bactérias — referência: Ausentes/Raras; tipo: texto
  - Relação prot/creat — referência: 0.11 - 0.47; tipo: numérico
#### GAMBÁ - BIOQ Labvet 2024

- Arquivo: `Silvestres 2026\Mamíferos\GAMBÁ - BIOQ Labvet 2024.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 18
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 2 - 3; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 55 - 883; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 13 - 73; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 81 - 237; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 0 - 0.2; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0.1 - 0.7; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 9.3 - 11.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 90 - 184; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.3 - 0.9; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 567 - 2757; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 63 - 125; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 2.7 - 4.3; tipo: numérico
  - GGT (U/L) — referência: 0 3 - 23; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 59 - 205; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 5 - 10; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 5.1 - 6.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 58 - 214; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 27 - 43; tipo: numérico; técnica: Cinético UV automatizado
#### GAMBÁ - HEM Labvet 2024

- Arquivo: `Silvestres 2026\Mamíferos\GAMBÁ - HEM Labvet 2024.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 2.75 - 5.85; tipo: numérico
  - Hemoglobina (g/dL) — referência: 7.5 - 14.4; tipo: numérico
  - Hematócrito (%) — referência: 23.8 - 39.8; tipo: numérico
  - VCM (fL) — referência: 60 - 96.2; tipo: numérico
  - CHCM (g/dL) — referência: 23.6 - 37.4; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 3200 - 13100; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 3 0 - 5727; tipo: numérico
  - Segmentados — referência: 60 70 1222 - 6084; tipo: numérico
  - Linfócitos — referência: 12 54 1000 - 672; tipo: numérico
  - Monócitos — referência: 3 10 54 - 672; tipo: numérico
  - Eosinófilos — referência: 2 10 248 - 2476; tipo: numérico
  - Basófilos — referência: 0 raros 0 - 193; tipo: misto
  - Proteínas (g/dL) — referência: 7.4 - 9.5; tipo: numérico
#### HEDGEHOG - HEM Labvet 2025

- Arquivo: `Silvestres 2026\Mamíferos\HEDGEHOG - HEM Labvet 2025.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 4.3 - 6; tipo: numérico
  - Hemoglobina (g/dL) — referência: 10.7 - 14.9; tipo: numérico
  - Hematócrito (%) — referência: 34 - 47; tipo: numérico
  - VCM (fL) — referência: 76.3 - 99.8; tipo: numérico
  - CHCM (g/dL) — referência: 22.5 - 31.4; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 - - -; tipo: numérico
  - Leucócitos — referência: 11500 - 21700; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 - 700; tipo: numérico
  - Segmentados — referência: 6100 - 14600; tipo: numérico
  - Linfócitos — referência: 3300 - 8900; tipo: numérico
  - Monócitos — referência: 0 - 800; tipo: numérico
  - Eosinófilos — referência: 0 - 300; tipo: numérico
  - Basófilos — referência: raros 0 - 200; tipo: misto
  - Fonte: — referência: Okorie-Kanu CO, Onoja RI, Achegbulu EE, et al. Normal haematological and serum biochemistry values of African hedgehog (Atelerix albiventris). Comp Clin Path. 2015;24:127–132. I.S.I.S 1999; tipo: misto
#### HEM_RATO_TWISTER - Labvet 2024

- Arquivo: `Silvestres 2026\Mamíferos\HEM_RATO_TWISTER - Labvet 2024.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 14
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 5.11 - 8.07; tipo: numérico
  - Hemoglobina (g/dL) — referência: 9.8 - 16.6; tipo: numérico
  - Hematócrito (%) — referência: 31.9 - 46.7; tipo: numérico
  - VCM (fL) — referência: 50 - 62; tipo: numérico
  - CHCM (g/dL) — referência: 33.3 - 40.3; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 6971 - 14469; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 -; tipo: numérico
  - Segmentados — referência: 503 - 2185; tipo: numérico
  - Linfócitos — referência: 5444 - 11114; tipo: numérico
  - Monócitos — referência: 0 - 2208; tipo: numérico
  - Eosinófilos — referência: 83 - 297; tipo: numérico
#### IRARA_BIOQ - Labvet

- Arquivo: `Silvestres 2026\Mamíferos\IRARA_BIOQ - Labvet.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 18
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 2.7 - 4.3; tipo: numérico; técnica: Colorimétrico automatizado
  - ALT (U/L) — referência: 0 0 - 162; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 39 - 179; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 - - -; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0 - 0.6; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 8.5 - 11.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 78 - 290; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 - 1709; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0 0.3 - 1.1; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 8 - 56; tipo: numérico; técnica: Cinético UV automatizado
  - Fósforo (mg/dL) — referência: 0 2.7 - 9.1; tipo: numérico; técnica: Cinético UV automatizado
  - GGT (U/L) — referência: 0 -; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 64 - 140; tipo: numérico; técnica: Colorimétrico automatizado
  - Proteínas totais (g/dL) — referência: 0 6.3 - 8.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 1 - 53; tipo: numérico; técnica: Colorimétrico automatizado
  - LDH (U/L) — referência: 0 0 - 1770; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 2 - 30; tipo: numérico; técnica: Cinético UV automatizado
  - Globulinas (g/dL) — referência: 3 - 436; tipo: numérico
#### IRARA_HEM - Labvet

- Arquivo: `Silvestres 2026\Mamíferos\IRARA_HEM - Labvet.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 15
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 6 - 9.24; tipo: numérico
  - Hemoglobina (g/dL) — referência: 11.4 - 17.4; tipo: numérico
  - Hematócrito (%) — referência: 34 - 54; tipo: numérico
  - VCM (fL) — referência: 47 - 67.8; tipo: numérico
  - CHCM (g/dL) — referência: 29.6 - 36.8; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 -; tipo: numérico
  - Leucócitos — referência: 2700 - 10300; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 - - 0 - 1800; tipo: numérico
  - Segmentados — referência: - - 1600 - 8400; tipo: numérico
  - Linfócitos — referência: - - 0 - 2800; tipo: numérico
  - Monócitos — referência: - - 0 - 200; tipo: numérico
  - Eosinófilos — referência: - - 0 - 400; tipo: numérico
  - Basófilos — referência: 0 - Raros; tipo: misto
#### MACACO JAPONÊS - BIOQ Labvet 2025

- Arquivo: `Silvestres 2026\Mamíferos\MACACO JAPONÊS - BIOQ Labvet 2025.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 19
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 2.4 - 4.8; tipo: numérico; técnica: Colorimétrico automatizado
  - ALT (U/L) — referência: 0 2.3 - 73.1; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 7.4 - 57; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 - - -; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0 - 0.4; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 5.5 - 11.5; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 40.9 - 237.3; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 - 841.8; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0 0 - 1.6; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 0 - 1538; tipo: numérico; técnica: Cinético UV automatizado
  - Fósforo (mg/dL) — referência: 0 1.6 - 5.2; tipo: numérico; técnica: Cinético UV automatizado
  - GGT (U/L) — referência: 0 50.1 - 132.9; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 22.9 - 152.1; tipo: numérico; técnica: Colorimétrico automatizado
  - Potássio (mmol/L) — referência: 1.6 - 6; tipo: numérico; técnica: Eletrodo ion-seletivo
  - Proteínas totais (g/dL) — referência: 0 5.3 - 9.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Sódio (mmol/L) — referência: 133.3 - 165.7; tipo: numérico; técnica: Eletrodo ion-seletivo
  - Triglicerídeos (mg/dL) — referência: 0 0 - 154.2; tipo: numérico; técnica: Colorimétrico automatizado
  - LDH (U/L) — referência: 0 82.1 - 480.9; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 0 - 73.9; tipo: numérico; técnica: Cinético UV automatizado
#### MACACO JAPONÊS - HEMOG Labvet 2025

- Arquivo: `Silvestres 2026\Mamíferos\MACACO JAPONÊS - HEMOG Labvet 2025.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 15
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 3.96 - 6.84; tipo: numérico
  - Hemoglobina (g/dL) — referência: 10.4 - 17.6; tipo: numérico
  - Hematócrito (%) — referência: 34 - 57; tipo: numérico
  - VCM (fL) — referência: 78 - 94; tipo: numérico
  - CHCM (g/dL) — referência: 28 - 32.2; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 4000 - 21500; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 3 -; tipo: numérico
  - Segmentados — referência: 60 70 -; tipo: numérico
  - Linfócitos — referência: 12 30 -; tipo: numérico
  - Monócitos — referência: 3 10 -; tipo: numérico
  - Eosinófilos — referência: 2 10 -; tipo: numérico
  - Basófilos — referência: 0 raros raros; tipo: misto
#### MACACO PREGO - HEM Labvet 2026 (atualizado)

- Arquivo: `Silvestres 2026\Mamíferos\MACACO PREGO - HEM Labvet 2026 (atualizado).xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 4.18 - 7.7; tipo: numérico
  - Hemoglobina (g/dL) — referência: 11.81 - 17.57; tipo: numérico
  - Hematócrito (%) — referência: 36.1 - 53.9; tipo: numérico
  - VCM (fL) — referência: 60.56 - 90.64; tipo: numérico
  - CHCM (g/dL) — referência: 31.15 - 34.31; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 -; tipo: numérico
  - Leucócitos — referência: 5770 - 16330; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 11 - 234; tipo: numérico
  - Segmentados — referência: 1569 - 10254; tipo: numérico
  - Linfócitos — referência: 1217 - 10085; tipo: numérico
  - Monócitos — referência: 41 - 830; tipo: numérico
  - Eosinófilos — referência: 0 - 701; tipo: numérico
  - Basófilos — referência: 0 0 - 239; tipo: numérico
  - Fonte: — referência: Naves et al. Valores hematológicos de macaco prego (Cebus apella - Línnaeus, 1758) em cativeiro, 2006 & ISIS, 2002.; tipo: misto
#### MACACO-PREGO- BIOQ Labvet 2026

- Arquivo: `Silvestres 2026\Mamíferos\MACACO-PREGO- BIOQ Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 14
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 2.1 - 3.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 65 - 213; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 19 - 65; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 30 - 117; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 4.1 - 10.1; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 190 - 549; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0 0.1 - 2; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 0 31 - 190; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 15 - 124; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 -; tipo: numérico
  - Lactato Desidrogenase (mg/dL) — referência: 0 278 - 451; tipo: numérico; técnica: Colorimétrico automatizado
  - Proteínas totais (g/dL) — referência: 0 5.4 - 7.1; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 26 - 169; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 14 - 70; tipo: numérico; técnica: Cinético UV automatizado
#### MÃO PELADA - BIOQ Labvet 2024

- Arquivo: `Silvestres 2026\Mamíferos\MÃO PELADA - BIOQ Labvet 2024.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 19
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 3.1 - 3.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 29 - 91; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 85 - 157; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 59 - 111; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 0 - 0.1; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0.1 - 0.3; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 8.3 - 9.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 148 - 274; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.7 - 1.1; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 108 - 504; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 43 - 87; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 3 - 4.4; tipo: numérico
  - GGT (U/L) — referência: 0 2 - 6; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 626 - 1972; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 3.5 - 5.9; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 6.5 - 7.9; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 16 - 50; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 13 - 27; tipo: numérico; técnica: Cinético UV automatizado
  - Fonte: — referência: I.S.I.S., 1999. - Procyon lotor. (OBS: O valor de referência da espécie Procyon cancrivorus - mão pelada não foi encontrado na literatura, sendo assim, foi utilizado a espécie mais próxima).; tipo: misto
#### MÃO PELADA - HEM Labvet 2024

- Arquivo: `Silvestres 2026\Mamíferos\MÃO PELADA - HEM Labvet 2024.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: 2 ano
- Analitos identificados: 17
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 10.7 7.54 - 9.94; tipo: numérico
  - Hemoglobina (g/dL) — referência: 16.4 10.7 - 13.7; tipo: numérico
  - Hematócrito (%) — referência: 47 31.4 - 42.2; tipo: numérico
  - VCM (fL) — referência: 37.6 - 48; tipo: numérico
  - CHCM (g/dL) — referência: 30.7 - 35.1; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 -; tipo: numérico
  - Leucócitos — referência: 13400 5750 - 13937; tipo: numérico
  - Mielócitos — referência: 0; tipo: numérico
  - Metamielócitos — referência: 0; tipo: numérico
  - Bastões — referência: 0 0 - 1110; tipo: numérico
  - Segmentados — referência: 35 1194 - 8494; tipo: numérico
  - Linfócitos — referência: 40 1960 - 5924; tipo: numérico
  - Monócitos — referência: 4 79 - 587; tipo: numérico
  - Eosinófilos — referência: 20 249 - 1319; tipo: numérico
  - Basófilos — referência: 1 17 - 99; tipo: numérico
  - Proteínas (g/dL) — referência: 7.4 -; tipo: numérico
  - Fonte: — referência: I.S.I.S., 1999. - Procyon lotor. (OBS: O valor de referência da espécie Procyon cancrivorus - mão pelada não foi encontrado na literatura, sendo assim, foi utilizado a espécie mais próxima).; tipo: misto
#### OURIÇO CACHEIRO - BIOQ Labvet 2026

- Arquivo: `Silvestres 2026\Mamíferos\OURIÇO CACHEIRO - BIOQ Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 22
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 3.1 - 5.9; tipo: numérico; técnica: Colorimétrico automatizado
  - ALT (U/L) — referência: 0 0 - 21; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 31 - 215; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 0 - 0; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0 - 0.6; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio iônico (mmol/L) — referência: 1.25 - 1.45; tipo: numérico; técnica: Eletrodo ion-seletivo
  - Cálcio total (mg/dL) — referência: 0 8 - 12; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 70 - 294; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 - 1587; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0 0.1 - 1.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Ferro (mg/dL) — referência: 169 - 281; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 0 - 706; tipo: numérico; técnica: Cinético UV automatizado
  - Fósforo (mg/dL) — referência: 0 1.8 - 7.8; tipo: numérico; técnica: Cinético UV automatizado
  - GGT (U/L) — referência: 0 1 - 21; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 78 - 222; tipo: numérico; técnica: Colorimétrico automatizado
  - Potássio (mmol/L) — referência: 2.8 - 6.4; tipo: numérico; técnica: Eletrodo ion-seletivo
  - Proteínas totais (g/dL) — referência: 0 5.4 - 8.2; tipo: numérico; técnica: Colorimétrico automatizado
  - Sódio (mmol/L) — referência: 129 - 149; tipo: numérico; técnica: Eletrodo ion-seletivo
  - Triglicerídeos (mg/dL) — referência: 0 3 - 307; tipo: numérico; técnica: Colorimétrico automatizado
  - LDH (U/L) — referência: 0 0 - 1596; tipo: numérico; técnica: Colorimétrico automatizado
  - Ácido Úrico (mg/dL) — referência: 0 0 - 3.3; tipo: numérico; técnica: Cinético UV automatizado
  - Globulinas (g/dL) — referência: 0.9 - 3.7; tipo: numérico
#### OURIÇO CACHEIRO - HEM Labvet 2026

- Arquivo: `Silvestres 2026\Mamíferos\OURIÇO CACHEIRO - HEM Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 3.12 - 5.28; tipo: numérico
  - Hemoglobina (g/dL) — referência: 10.4 - 16.8; tipo: numérico
  - Hematócrito (%) — referência: 32.1 - 51.7; tipo: numérico
  - VCM (fL) — referência: 81.1 - 113.1; tipo: numérico
  - CHCM (g/dL) — referência: 29.3 - 37.7; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 -; tipo: numérico
  - Leucócitos — referência: 3300 - 24404; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 - 164; tipo: numérico
  - Segmentados — referência: 850 - 9571; tipo: numérico
  - Linfócitos — referência: 1500 - 9907; tipo: numérico
  - Monócitos — referência: 0 - 986; tipo: numérico
  - Eosinófilos — referência: 0 - 1458; tipo: numérico
  - Basófilos — referência: 0 raros 0 - 0; tipo: misto
  - Fonte: — referência: I.S.I.S., 2002.; tipo: misto
#### PACA BIOQ - Labvet 2026

- Arquivo: `Silvestres 2026\Mamíferos\PACA BIOQ - Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 19
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 3.9 - 5.9; tipo: numérico; técnica: Colorimétrico automatizado
  - ALT (U/L) — referência: 0 3 - 25; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 13 - 102; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 0 - 0.3; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0.2 - 0.8; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 3.7 - 14.9; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 17 - 85; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 108 - 877; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0 0.6 - 2.6; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 63 - 223; tipo: numérico; técnica: Cinético UV automatizado
  - Fósforo (mg/dL) — referência: 0 3.2 - 14.8; tipo: numérico; técnica: Cinético UV automatizado
  - GGT (U/L) — referência: 0 0 - 7; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 88 - 270; tipo: numérico; técnica: Colorimétrico automatizado
  - Proteínas totais (g/dL) — referência: 0 5.9 - 8.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 40 - 159; tipo: numérico; técnica: Colorimétrico automatizado
  - LDH (U/L) — referência: 0 604 - 1664; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 7 - 36; tipo: numérico; técnica: Cinético UV automatizado
  - Globulinas (g/dL) — referência: 0.6 - 3.8; tipo: numérico
  - Fonte — referência: ISIS, 2002.; tipo: misto
#### PACA HEMOGRAMA - Labvet 2026

- Arquivo: `Silvestres 2026\Mamíferos\PACA HEMOGRAMA - Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 17
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 3.56 - 6.16; tipo: numérico
  - Hemoglobina (g/dL) — referência: 12.38 - 17.86; tipo: numérico
  - Hematócrito (%) — referência: 36.8 - 46.75; tipo: numérico
  - VCM (fL) — referência: 67 - 108.6; tipo: numérico
  - CHCM (g/dL) — referência: 30.72 - 43.2; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 6800 - 12800; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0; tipo: numérico
  - Segmentados — referência: 1850 - 4900; tipo: numérico
  - Linfócitos — referência: 4080 - 7800; tipo: numérico
  - Monócitos — referência: 34 - 286; tipo: numérico
  - Eosinófilos — referência: 70 - 590; tipo: numérico
  - Basófilos — referência: 0 Raros; tipo: misto
  - Proteínas (g/dL) — referência: 5.8 - 7.2; tipo: numérico
  - Fonte: — referência: Pachaly, J.R., Acco, A., Lange, R.R., Nogueira, T.M.R., Nogueira, M.F. and Ciffoni, E.M.G. (2001). Order Rodentia (Rodents). In Biology, Medicine, and Surgery of South American Wild Animals, M.E. Fowler (Ed.). https://doi.org/10.1002/9780470376980.ch23 & ISIS, 2002.; tipo: misto
#### PORQUINHO-INDIA BIOQ Labvet 2024

- Arquivo: `Silvestres 2026\Mamíferos\PORQUINHO-INDIA BIOQ Labvet 2024.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 19
- Estrutura de analitos:
  - Ácido Úrico (mg/dL) — referência: 0 0.5 - 3.3; tipo: numérico
  - Albumina (g/dL) — referência: 0 2.2 - 3.4; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 40 - 56; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 19 - 43; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 37 - 117; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0 - 0.2; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 8.4 - 12; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 20 - 72; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.3 - 2.1; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 668 - 2674; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 59 - 215; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 2 - 2.8; tipo: numérico
  - GGT (U/L) — referência: 0 0 - 7; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 213 - 901; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 2.7 - 7.3; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 4.8 - 6; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 0 - 45; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 8 - 36; tipo: numérico; técnica: Cinético UV automatizado
  - Relação Albumina:Globulina — referência: 0 -; tipo: numérico
#### PORQUINHO-INDIA-HEM Labvet 2024

- Arquivo: `Silvestres 2026\Mamíferos\PORQUINHO-INDIA-HEM Labvet 2024.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 14
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 4 - 7; tipo: numérico
  - Hemoglobina (g/dL) — referência: 11 - 17; tipo: numérico
  - Hematócrito (%) — referência: 39 - 55; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 -; tipo: numérico
  - Leucócitos — referência: 2900 - 14400; tipo: numérico
  - Mielócitos — referência: 0 0 0 zxxkk; tipo: misto
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 0; tipo: numérico
  - Neutrófilos — referência: 35 55 1750 - 6600 Neutropenia absoluta; tipo: misto
  - Linfócitos — referência: 25 60 1250 - 7200; tipo: numérico
  - Monócitos — referência: 2 10 100 - 1200; tipo: numérico
  - Eosinófilos — referência: 0 5 0 - 600; tipo: numérico
  - Basófilos — referência: 0 2 8 100 - 960; tipo: numérico
  - Fonte: — referência: Carpenter, 2023; tipo: misto
#### PREGUIÇA COMUM - BIOQUIMICA

- Arquivo: `Silvestres 2026\Mamíferos\PREGUIÇA COMUM - BIOQUIMICA.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: 5 ano
- Analitos identificados: 15
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 2.3 - 4.3; tipo: numérico; técnica: Colorimétrico automatizado
  - ALT (U/L) — referência: 0 2 - 16.2; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 144.2 - 540.6; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0 0.1 - 0.9; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 23.7 - 527.3; tipo: numérico; técnica: Cinético UV automatizado
  - Fósforo (mg/dL) — referência: 0 1.3 - 5.7; tipo: numérico; técnica: Cinético UV automatizado
  - GGT (U/L) — referência: 0 0 - 123; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 6.1 - 8.9; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 20.6 - 55.8; tipo: numérico; técnica: Cinético UV automatizado
  - Globulinas (g/dL) — referência: 2.3 - 5.9; tipo: numérico
  - Cálcio total (mg/dL) — referência: 0 9.1 - 12.3; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 - 591.6; tipo: numérico; técnica: Cinético UV automatizado
  - LDH (U/L) — referência: 0 - - -; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 25.1 - 168.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Glicose (mg/dL) — referência: 58.6 - 123.4; tipo: numérico; técnica: Colorimétrico automatizado
#### PREGUIÇA COMUM - HEMOGRAMA

- Arquivo: `Silvestres 2026\Mamíferos\PREGUIÇA COMUM - HEMOGRAMA.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: 5 ano
- Analitos identificados: 15
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 1.8 - 4.2; tipo: numérico
  - Hemoglobina (g/dL) — referência: 7 - 13; tipo: numérico
  - Hematócrito (%) — referência: 24 - 46; tipo: numérico
  - VCM (fL) — referência: 97.6 - 142.4; tipo: numérico
  - CHCM (g/dL) — referência: 24 - 35.2; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 3100 - 14300; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 - - - - -; tipo: numérico
  - Segmentados — referência: 3 77 1400 - 7200; tipo: numérico
  - Linfócitos — referência: 15 87 1400 - 7900; tipo: numérico
  - Monócitos — referência: 0 10 0 - 630; tipo: numérico
  - Eosinófilos — referência: 0 10 0 - 690; tipo: numérico
  - Basófilos — referência: 0 - -; tipo: numérico
#### QUATI - BIOQ Labvet 2026

- Arquivo: `Silvestres 2026\Mamíferos\QUATI - BIOQ Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 19
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 2.5 - 3.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 2 - 50; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 28 - 477; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 46 - 402; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 0 - 0; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0.2 - 0.6; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 7.4 - 10.2; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 108 - 336; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.8 - 1.6; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 582 - 3166; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 62 - 138; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 2.8 - 4.8; tipo: numérico
  - GGT (U/L) — referência: 0 10 - 38; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 240 - 928; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 0.8 - 7.2; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 5.5 - 8.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 16 - 52; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 4 - 24; tipo: numérico; técnica: Cinético UV automatizado
  - Fonte: — referência: I.S.I.S., 2002.; tipo: misto
#### QUATI - HEM Labvet 2026

- Arquivo: `Silvestres 2026\Mamíferos\QUATI - HEM Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 4.99 - 9.19; tipo: numérico
  - Hemoglobina (g/dL) — referência: 8.5 - 15.7; tipo: numérico
  - Hematócrito (%) — referência: 26.4 - 48.8; tipo: numérico
  - VCM (fL) — referência: 38.8 - 54.64; tipo: numérico
  - CHCM (g/dL) — referência: 26.5 - 38.5; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 3400 - 19700; tipo: numérico
  - Mielócitos — referência: 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0; tipo: numérico
  - Bastões — referência: 0 0 - 1003; tipo: numérico
  - Segmentados — referência: 2030 - 15980; tipo: numérico
  - Linfócitos — referência: 238 - 4680; tipo: numérico
  - Monócitos — referência: 34 - 1081; tipo: numérico
  - Eosinófilos — referência: 61 - 981; tipo: numérico
  - Basófilos — referência: 0 0 - 491; tipo: numérico
  - Fonte: — referência: I.S.I.S., 2002.; tipo: misto
#### TAMANDUA-MIRIM - BIOQ Labvet 2024

- Arquivo: `Silvestres 2026\Mamíferos\TAMANDUA-MIRIM - BIOQ Labvet 2024.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 20
- Estrutura de analitos:
  - Ácido Úrico (mg/dL) — referência: 0 0.1 - 0.5; tipo: numérico
  - Albumina (g/dL) — referência: 0 2 - 2.6; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 0 - 23; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 53 - 97; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 20 - 64; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 0 - 0; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0.1 - 0.3; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 8.1 - 12.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 80 - 308; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.4 - 1; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 94 - 1156; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 42 - 108; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 4.1 - 5.3; tipo: numérico
  - GGT (U/L) — referência: 0 0 - 332; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 18 - 328; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 3 - 6.6; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 6.7 - 7.9; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 0 - 120; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 15 - 31; tipo: numérico; técnica: Cinético UV automatizado
  - Fonte: — referência: I.S.I.S., 1999.; tipo: misto
#### TAMANDUA-MIRIM - HEM Labvet 2024

- Arquivo: `Silvestres 2026\Mamíferos\TAMANDUA-MIRIM - HEM Labvet 2024.xlsx`
- Tipo de animal: Silvestres > Mamíferos
- Idade: Não indicada
- Analitos identificados: 17
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 2.71 - 3.81; tipo: numérico
  - Hemoglobina (g/dL) — referência: 12 - 16.8; tipo: numérico
  - Hematócrito (%) — referência: 34.1 - 47.3; tipo: numérico
  - VCM (fL) — referência: 113.6 - 137.4; tipo: numérico
  - CHCM (g/dL) — referência: 33.8 - 36.8; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 7300 - 14600; tipo: numérico
  - Mielócitos — referência: 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0; tipo: numérico
  - Bastões — referência: 0 0 - 734; tipo: numérico
  - Segmentados — referência: 3000 - 7000; tipo: numérico
  - Linfócitos — referência: 2500 - 7500; tipo: numérico
  - Monócitos — referência: 38 - 648; tipo: numérico
  - Eosinófilos — referência: 117 - 1200; tipo: numérico
  - Basófilos — referência: 0 202 - 264; tipo: numérico
  - Proteínas (g/dL) — referência: ** 8.4 - 9.2; tipo: numérico
  - Fonte: — referência: I.S.I.S., 1999. / ** Tratado de Animais Selvagens 2º Ed. (2014); tipo: misto

### Silvestres > Peixes

#### L. Caeruleus - HEM Labvet 2026

- Arquivo: `Silvestres 2026\Peixes\L. Caeruleus - HEM Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Peixes
- Idade: Não indicada
- Analitos identificados: 13
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 0.2 - 1.72; tipo: numérico
  - Hemoglobina (g/dL) — referência: 3.75 - 9.59; tipo: numérico
  - Hematócrito (%) — referência: 16.6 - 37.2; tipo: numérico
  - VCM (fL) — referência: 71.06 - 543.42; tipo: numérico
  - CHCM (g/dL) — referência: 25.88 - 26.12; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 250 - 19850; tipo: numérico
  - Mielócitos — referência: 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0; tipo: numérico
  - Bastões — referência: 0 -; tipo: numérico
  - Basófilos — referência: 0; tipo: numérico
  - Valor Absoluto (céls./µL) — referência: (>60.000/µL: Anemia regenerativa); tipo: misto
  - Fonte: — referência: Daneshvar, 2012. (Não foram encontrados parâmetros para a espécie, por isso foram utilizadas referências da espécie Iranocichla hormuzensis, da mesma família).; tipo: misto
#### Labidochromis Caeruleus

- Arquivo: `Silvestres 2026\Peixes\Labidochromis Caeruleus.xlsx`
- Tipo de animal: Silvestres > Peixes
- Idade: Não indicada
- Analitos identificados: 13
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 0.2 - 1.72; tipo: numérico
  - Hemoglobina (g/dL) — referência: 3.75 - 9.59; tipo: numérico
  - Hematócrito (%) — referência: 16.6 - 37.2; tipo: numérico
  - VCM (fL) — referência: 71.06 - 543.42; tipo: numérico
  - CHCM (g/dL) — referência: 25.88 - 26.12; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 250 - 19850; tipo: numérico
  - Mielócitos — referência: 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0; tipo: numérico
  - Bastões — referência: 0 -; tipo: numérico
  - Basófilos — referência: 0; tipo: numérico
  - Valor Absoluto (céls./µL) — referência: (>60.000/µL: Anemia regenerativa); tipo: misto
  - Fonte: — referência: Daneshvar, 2012. (Não foram encontrados parâmetros para a espécie, por isso foram utilizadas referências da espécie Iranocichla hormuzensis, da mesma família).; tipo: misto

### Silvestres > Répteis

#### CORN SNAKE - BIOQ Labvet 2026

- Arquivo: `Silvestres 2026\Répteis\CORN SNAKE - BIOQ Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Répteis
- Idade: Não indicada
- Analitos identificados: 20
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 1.9 - 5.3; tipo: numérico; técnica: Colorimétrico automatizado
  - ALT (U/L) — referência: 0 6 - 62; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 0 - 101; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 - - -; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 - - -; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 14.3 - 17.9; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 - - -; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 - 1643; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0 0 - 1.2; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 35 - 73; tipo: numérico; técnica: Cinético UV automatizado
  - Fósforo (mg/dL) — referência: 0 3.5 - 5.5; tipo: numérico; técnica: Cinético UV automatizado
  - GGT (U/L) — referência: 0 0 - 10; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 35 - 77; tipo: numérico; técnica: Colorimétrico automatizado
  - Potássio (mmol/L) — referência: 2.4 - 11; tipo: numérico; técnica: Eletrodo ion-seletivo
  - Proteínas totais (g/dL) — referência: 0 5.3 - 8.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Sódio (mmol/L) — referência: 159 - 169; tipo: numérico; técnica: Eletrodo ion-seletivo
  - Triglicerídeos (mg/dL) — referência: 0 0 - 780; tipo: numérico; técnica: Colorimétrico automatizado
  - LDH (U/L) — referência: 0 42 - 322; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 - - -; tipo: numérico; técnica: Cinético UV automatizado
  - Globulinas (g/dL) — referência: 3.3 - 4.5; tipo: numérico
#### CORN SNAKE - HEM Labvet 2026

- Arquivo: `Silvestres 2026\Répteis\CORN SNAKE - HEM Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Répteis
- Idade: Não indicada
- Analitos identificados: 17
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 0.4 - 1.69; tipo: numérico
  - Hemoglobina (g/dL) — referência: 4 - 12.6; tipo: numérico
  - Hematócrito (%) — referência: 24.5 - 39.5; tipo: numérico
  - VCM (fL) — referência: 223.2 - 407.6; tipo: numérico
  - CHCM (g/dL) — referência: 23.7 - 40.7; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 1120 - 16900; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0; tipo: numérico
  - Segmentados — referência: 230 - 5080; tipo: numérico
  - Linfócitos — referência: 290 - 11800; tipo: numérico
  - Monócitos — referência: 30 - 1780; tipo: numérico
  - Azurófilos — referência: 10 - 3290; tipo: numérico
  - Eosinófilos — referência: 30 - 480; tipo: numérico
  - Basófilos — referência: 0 40 - 1040; tipo: numérico
  - Fonte: — referência: Carpenter, 2023 & I.S.I.S, 1999.; tipo: misto
#### JABUTI PIRANGA - BIOQ Labvet 2026

- Arquivo: `Silvestres 2026\Répteis\JABUTI PIRANGA - BIOQ Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Répteis
- Idade: Não indicada
- Analitos identificados: 19
- Estrutura de analitos:
  - Ácido Úrico (mg/dL) — referência: 0 0.5 - 1.1; tipo: numérico
  - Albumina (g/dL) — referência: 0 1.2 - 2.6; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 40 - 128; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 0 - 37; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 80 - 396; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0.2 - 0.8; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 10.2 - 15.2; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 80 - 212; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0 - 0.8; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 0 - 798; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 50 - 138; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 1.9 - 4.3; tipo: numérico
  - GGT (U/L) — referência: 0 0 - 78; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 300 - 502; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 2.5 - 5.1; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 3.8 - 6.6; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 85 - 407; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 3 - 31; tipo: numérico; técnica: Cinético UV automatizado
  - Fonte: — referência: I.S.I.S., 1999.; tipo: misto
#### JABUTI PIRANGA - HEM Labvet 2026

- Arquivo: `Silvestres 2026\Répteis\JABUTI PIRANGA - HEM Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Répteis
- Idade: Não indicada
- Analitos identificados: 19
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 0.43 - 0.62; tipo: numérico
  - Hemoglobina (g/dL) — referência: 4.88 - 7.29; tipo: numérico
  - Hematócrito (%) — referência: 21 - 30; tipo: numérico
  - VCM (fL) — referência: 445.7 - 538.8; tipo: numérico
  - CHCM (g/dL) — referência: 22 - 26.1; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 3668 - 10614; tipo: numérico
  - Mielócitos — referência: 0 0 -; tipo: numérico
  - Metamielócitos — referência: 0 0 -; tipo: numérico
  - Bastões — referência: 0 -; tipo: numérico
  - Segmentados — referência: 147 - 3371; tipo: numérico
  - Linfócitos — referência: 1548 - 5108; tipo: numérico
  - Monócitos — referência: 0 - 376; tipo: numérico
  - Azurófilos — referência: 219 - 1733; tipo: numérico
  - Eosinófilos — referência: 0 0 - 1321; tipo: numérico
  - Basófilos — referência: 0 0 - 3158; tipo: numérico
  - Trombócitos (céls/µL) — referência: 4448 - 13670; tipo: numérico
  - Proteínas (g/dL) — referência: 3.8 - 5.8; tipo: numérico
  - Fonte: — referência: Bergamini, 2016 & I.S.I.S., 1999.; tipo: misto
#### JIBOIA - BIOQ Labvet 2026

- Arquivo: `Silvestres 2026\Répteis\JIBOIA - BIOQ Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Répteis
- Idade: Não indicada
- Analitos identificados: 10
- Estrutura de analitos:
  - Ácido Úrico (mg/dL) — referência: 0 1.9 - 7.5; tipo: numérico
  - Albumina (g/dL) — referência: 0 2.6 - 3.6; tipo: numérico; técnica: Colorimétrico automatizado
  - AST (U/L) — referência: 0 0 - 85; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 12.7 - 19.1; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 165 - 887; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 23 - 51; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 2.8 - 5.2; tipo: numérico
  - Fósforo (mg/dL) — referência: 0 3 - 6.4; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 5.7 - 8.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Fonte: — referência: I.S.I.S., 1999.; tipo: misto
#### JIBOIA - HEM Labvet 2026

- Arquivo: `Silvestres 2026\Répteis\JIBOIA - HEM Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Répteis
- Idade: Não indicada
- Analitos identificados: 17
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 0.33 - 1.13; tipo: numérico
  - Hemoglobina (g/dL) — referência: 6 - 12; tipo: numérico
  - Hematócrito (%) — referência: 22.6 - 36; tipo: numérico
  - VCM (fL) — referência: 272.5 - 513.7; tipo: numérico
  - CHCM (g/dL) — referência: 27.6 - 36.6; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 3194 - 13880; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 -; tipo: numérico
  - Segmentados — referência: 2 35 52 - 4858; tipo: numérico
  - Linfócitos — referência: 14 55 432 - 7582; tipo: numérico
  - Monócitos — referência: 0 14 0 - 1957; tipo: numérico
  - Azurófilos — referência: 11 23 348 - 3146; tipo: numérico
  - Eosinófilos — referência: 0 4 0 - 529; tipo: numérico
  - Basófilos — referência: 0 0 7 0 - 961; tipo: numérico
  - Fonte: — referência: I.S.I.S, 1999.; tipo: misto
#### TEIÚ - BIOQ Labvet 2026

- Arquivo: `Silvestres 2026\Répteis\TEIÚ - BIOQ Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Répteis
- Idade: Não indicada
- Analitos identificados: 16
- Estrutura de analitos:
  - Ácido Úrico (mg/dL) — referência: 0 0.8 - 5.6; tipo: numérico
  - Albumina (g/dL) — referência: 0 2.9 - 4.1; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 78 - 258; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 10 - 34; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 1 - 33; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0.1 - 0.5; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 11.5 - 12.7; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 139 - 273; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.2 - 0.4; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 132 - 1332; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 100 - 162; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 1.5 - 3.9; tipo: numérico
  - Lactato Desidrogenase (mg/dL) — referência: 0 94 - 1176; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 3.4 - 8; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 5 - 7.6; tipo: numérico; técnica: Colorimétrico automatizado
  - Fonte: — referência: I.S.I.S., 1999.; tipo: misto
#### TEIÚ - HEM Labvet 2026

- Arquivo: `Silvestres 2026\Répteis\TEIÚ - HEM Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Répteis
- Idade: Não indicada
- Analitos identificados: 15
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 0.68 - 1.24; tipo: numérico
  - Hemoglobina (g/dL) — referência: 8.2 - 14.6; tipo: numérico
  - Hematócrito (%) — referência: 20 - 30; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 -; tipo: numérico
  - Leucócitos — referência: 11800 - 21800; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0; tipo: numérico
  - Segmentados — referência: 1300 - 3100; tipo: numérico
  - Linfócitos — referência: 6340 - 8660; tipo: numérico
  - Monócitos — referência: 180 - 1820; tipo: numérico
  - Azurófilos — referência: 680 - 2920; tipo: numérico
  - Eosinófilos — referência: 3880 - 4320; tipo: numérico
  - Basófilos — referência: 0 380 - 420; tipo: numérico
  - Fonte: — referência: Carpenter, 2023.; tipo: misto
#### TIGRE D_ÁGUA - BIOQ Labvet 2026

- Arquivo: `Silvestres 2026\Répteis\TIGRE D_ÁGUA - BIOQ Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Répteis
- Idade: Não indicada
- Analitos identificados: 20
- Estrutura de analitos:
  - Ácido Úrico (mg/dL) — referência: 0 0.3 - 3.2; tipo: numérico
  - Albumina (g/dL) — referência: 0 1.6 - 2.5; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 201 - 677; tipo: numérico; técnica: Cinético UV automatizado
  - ALT (U/L) — referência: 0 1 - 66; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 108 - 350; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0.1 - 0.5; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 10 - 18; tipo: numérico; técnica: Colorimétrico automatizado
  - Colesterol Total (mg/dL) — referência: 0 106 - 227; tipo: numérico; técnica: Colorimétrico automatizado
  - Creatinina (mg/dL) — referência: 0 0.2 - 0.5; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 392 - 4856; tipo: numérico; técnica: Cinético UV automatizado
  - Glicose (mg/dL) — referência: 0 52 - 138; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 1.2 - 3.7; tipo: numérico
  - GGT (U/L) — referência: 0 0 - 21; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 371 - 5763; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 3.7 - 7.5; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 2.8 - 6.1; tipo: numérico; técnica: Colorimétrico automatizado
  - Triglicerídeos (mg/dL) — referência: 0 30 - 664; tipo: numérico; técnica: Colorimétrico automatizado
  - Uréia (mg/dL) — referência: 0 4 - 54; tipo: numérico; técnica: Cinético UV automatizado
  - Relação Albumina:Globulina — referência: 0 -; tipo: numérico
  - Fonte: — referência: I.S.I.S., 1999.; tipo: misto
#### TIGRE D_ÁGUA - HEM Labvet 2026

- Arquivo: `Silvestres 2026\Répteis\TIGRE D_ÁGUA - HEM Labvet 2026.xlsx`
- Tipo de animal: Silvestres > Répteis
- Idade: Não indicada
- Analitos identificados: 15
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 0.33 - 2.21; tipo: numérico
  - Hematócrito (%) — referência: 21 - 47; tipo: numérico
  - VCM (fL) — referência: 179 - 697; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0; tipo: numérico
  - Leucócitos — referência: 1200 - 25500; tipo: numérico
  - Mielócitos — referência: 0 0 -; tipo: numérico
  - Metamielócitos — referência: 0 0 -; tipo: numérico
  - Bastões — referência: 0 -; tipo: numérico
  - Segmentados — referência: 948 - 14000; tipo: numérico
  - Linfócitos — referência: 252 - 7880; tipo: numérico
  - Monócitos — referência: 138 - 375; tipo: numérico
  - Azurófilos — referência: 230 - 1330; tipo: numérico
  - Eosinófilos — referência: 166 - 5950; tipo: numérico
  - Basófilos — referência: 0 315 - 8000; tipo: numérico
  - Fonte: — referência: Bergamini, 2016 & I.S.I.S., 1999.; tipo: misto

### Suino

#### AVESSO BIOQUÍMICA_SUI - Labvet 2026

- Arquivo: `Suino 2026\AVESSO BIOQUÍMICA_SUI - Labvet 2026.xlsx`
- Tipo de animal: Suino
- Idade: Não indicada
- Analitos identificados: 18
- Estrutura de analitos:
  - ALT (U/L) — referência: 0 22 - 47; tipo: numérico; técnica: Cinético UV automatizado
  - AST (U/L) — referência: 0 15 - 55; tipo: numérico; técnica: Cinético UV automatizado
  - Uréia (mg/dL) — referência: 0 8.2 - 25; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0 0.8 - 2.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Fosfatase Alcalina (U/L) — referência: 0 41 - 176; tipo: numérico; técnica: Cinético UV automatizado
  - GGT (U/L) — referência: 0 31 - 52; tipo: numérico; técnica: Cinético UV automatizado
  - Proteínas totais (g/dL) — referência: 0 5.8 - 8.3; tipo: numérico; técnica: Colorimétrico automatizado
  - Albumina (g/dL) — referência: 0 2.3 - 4; tipo: numérico; técnica: Colorimétrico automatizado
  - Globulinas (g/dL) — referência: 0 3.9 - 6; tipo: numérico
  - Bilirrubina total (mg/dL) — referência: 0 0 - 0.5; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 -; tipo: numérico; técnica: Cinético UV automatizado
  - Colesterol Total (mg/dL) — referência: 0 81 - 134; tipo: numérico; técnica: Colorimétrico automatizado
  - CK (U/L) — referência: 0 66 - 489; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 160 - 425; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 5.5 - 9.3; tipo: numérico; técnica: Cinético UV automatizado
  - Triglicerídeos (mg/dL) — referência: 0 -; tipo: numérico; técnica: Colorimétrico automatizado
  - Glicose (mg/dL) — referência: 0 66 - 116; tipo: numérico; técnica: Colorimétrico automatizado
  - Cálcio total (mg/dL) — referência: 0 9.3 - 11.5; tipo: numérico; técnica: Colorimétrico automatizado
#### CHECK_UP_SUI - Labvet 2026

- Arquivo: `Suino 2026\CHECK_UP_SUI - Labvet 2026.xlsx`
- Tipo de animal: Suino
- Idade: Não indicada
- Analitos identificados: 11
- Estrutura de analitos:
  - Albumina (g/dL) — referência: 0 2.3 - 4; tipo: numérico; técnica: Colorimétrico automatizado
  - AST (U/L) — referência: 0 15 - 55; tipo: numérico; técnica: Cinético UV automatizado
  - Uréia (mg/dL) — referência: 0 8.2 - 25; tipo: numérico; técnica: Cinético UV automatizado
  - Creatinina (mg/dL) — referência: 0 0.8 - 2.3; tipo: numérico; técnica: Colorimétrico automatizado
  - GGT (U/L) — referência: 0 31 - 52; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina total (mg/dL) — referência: 0 0 - 0.5; tipo: numérico; técnica: Cinético UV automatizado
  - Bilirrubina direta (mg/dL) — referência: 0 -; tipo: numérico; técnica: Cinético UV automatizado
  - CK (U/L) — referência: 0 66 - 489; tipo: numérico; técnica: Cinético UV automatizado
  - Lactato Desidrogenase (mg/dL) — referência: 0 160 - 425; tipo: numérico; técnica: Colorimétrico automatizado
  - Fósforo (mg/dL) — referência: 0 5.5 - 9.3; tipo: numérico; técnica: Cinético UV automatizado
  - Cálcio total (mg/dL) — referência: 0 9.3 - 11.5; tipo: numérico; técnica: Colorimétrico automatizado
#### HEM_SUINO_Ad - Labvet 2026

- Arquivo: `Suino 2026\HEM_SUINO_Ad - Labvet 2026.xlsx`
- Tipo de animal: Suino
- Idade: Não indicada
- Analitos identificados: 17
- Estrutura de analitos:
  - Hemácias (x106céls/µL) — referência: 5 - 8; tipo: numérico
  - Hemoglobina (g/dL) — referência: 10 - 16; tipo: numérico
  - Hematócrito (%) — referência: 32 - 50; tipo: numérico
  - VCM (fL) — referência: 50 - 67; tipo: numérico
  - CHCM (g/dL) — referência: 30 - 34; tipo: numérico
  - Metarrubrícitos (%) — referência: 0 0 - 0; tipo: numérico
  - Leucócitos — referência: 11000 - 22000; tipo: numérico
  - Mielócitos — referência: 0 0 0; tipo: numérico
  - Metamielócitos — referência: 0 0 0; tipo: numérico
  - Bastões — referência: 0 0 4 0 - 800; tipo: numérico
  - Segmentados — referência: 20 70 2000 - 15000; tipo: numérico
  - Linfócitos — referência: 35 75 3800 - 16500; tipo: numérico
  - Monócitos — referência: 0 10 0 - 100; tipo: numérico
  - Eosinófilos — referência: 0 15 0 - 1500; tipo: numérico
  - Basófilos — referência: 0 raros raros; tipo: misto
  - Proteínas (g/dL) — referência: 6 - 8; tipo: numérico
  - Fibrinogênio (g/dL) — referência: 0.2 - 0.4; tipo: numérico

## Arquivos `.xls` pendentes de leitura estrutural

- `Silvestres 2026\Aves\Agapornis sp. CHECKUP 2026.xls`
- `Silvestres 2026\Aves\Coruja Orelhuda - BIOQ. 2026.xls`
- `Silvestres 2026\Mamíferos\B_AVESSO_RATO_TWISTER - Labvet 2024.xls`
- `Silvestres 2026\Mamíferos\HEDGEHOG - BIOQ - Labvet 2025.xls`

## Próxima etapa recomendada

Validar com o laboratório a nomenclatura dos agrupamentos de animal, as faixas etárias e a composição dos pacotes. Depois disso, aprovar a migração das referências para a estrutura por modelo de laudo antes de cadastrar os analitos definitivos.
