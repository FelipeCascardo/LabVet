# Importação — setembro de 2026

## Origem

- Arquivo: `Importação/9 - Setembro - 2026.xlsx`
- Período: setembro de 2026
- Destino: base `labvet`, esquema `labvet`, na instância PostgreSQL de desenvolvimento do Itriax.

## Resultado da carga

| Item | Quantidade |
| --- | ---: |
| Linhas de origem | 657 |
| Atendimentos importados | 640 |
| Linhas rejeitadas | 17 |
| Proprietários criados | 477 |
| Animais criados | 562 |
| Setores normalizados | 13 |
| Códigos de exame criados | 73 |
| Relações atendimento–exame | 1.236 |

## Critérios aplicados

- Os 17 registros sem qualquer dado clínico foram rejeitados. Eles têm somente número de registro e data na origem.
- O campo `Exames` foi separado exclusivamente por vírgula. Por isso, códigos como `7.35` permanecem um único código de exame, enquanto `7,21,31` cria três relações na tabela `attendance_exams`.
- Repetições do mesmo código no mesmo atendimento são consolidadas em `attendance_exams.quantity`.
- Não foi imposta unicidade a `animals.external_code`: a planilha contém códigos associados a mais de um nome ou proprietário. As chaves técnicas `source_key` preservam a vinculação correta desta carga.
- Valores ausentes foram importados como `NULL`; não foram convertidos para zero.

## Verificações concluídas

- Nenhum número de registro de origem foi duplicado em `attendances`.
- Todos os 640 atendimentos importados possuem ao menos um exame associado.
- A carga foi executada em uma única transação: em caso de erro, nenhum dado parcial seria gravado.

## Ampliação de laudos — 2026-10-04

- Foram adicionados mapeadores incrementais para Imuno 4DX, Leptospirose, Técnica de Knott, Cortisol, T4, Compatibilidade sanguínea, Hemoaglutinação, Pesquisa de hemoparasitas, Hemoaglutinação em salina e análises de líquido cavitário e lavado broncoalveolar.
- A carga incremental inseriu 90 laudos, 325 resultados estruturados e 86 comentários, sem atualizar os laudos já existentes.
- Vinte e quatro arquivos mapeados não foram associados porque não há atendimento correspondente na base; eles não foram inseridos.
