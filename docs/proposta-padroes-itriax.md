# Proposta de convenções Itriax para o LabVet

## Finalidade

O próximo esquema do LabVet deve manter as 14 entidades funcionais atuais,
mas adotar a nomenclatura e os tipos predominantes no banco Itriax. A proposta
está em [001_labvet_schema_itriax.sql](../database/proposed/001_labvet_schema_itriax.sql).

O arquivo é intencionalmente separado dos scripts de inicialização: ele deve
ser revisado e aprovado antes da criação de uma nova base.

## Convenções observadas no Itriax

| Prefixo | Uso | Tipo predominante |
| --- | --- | --- |
| `id` | Identificador e chave estrangeira | `BIGINT` |
| `nm` | Nome | `VARCHAR` |
| `ds` | Descrição, texto ou observação | `VARCHAR` ou `TEXT` |
| `cd` | Código, chave externa ou hash | `VARCHAR` |
| `nr` | Número sequencial ou de registro | `INTEGER` ou `BIGINT` |
| `qt` | Quantidade | `INTEGER` |
| `vl` | Valor financeiro ou medida | `NUMERIC` |
| `dt` | Data de negócio | `DATE` |
| `dh` | Data e hora de auditoria | `TIMESTAMPTZ` |
| `tp` | Tipo ou categoria codificada | `SMALLINT` |
| `st` | Indicador lógico ou situação | `BOOLEAN` |

## Decisões da proposta

- As tabelas mantêm os nomes já usados no LabVet para preservar a organização
  do domínio; a padronização é aplicada aos campos.
- As chaves utilizam `BIGINT` sem valor-padrão, reproduzindo o padrão
  identificado no Itriax. O futuro backend deve fornecer os valores de `id...`.
- `dhinclusao` e `dhalteracao` são incluídos nas entidades alteráveis, com a
  função `fn_atualizar_dhalteracao`, também presente no Itriax.
- Estados textuais foram codificados em campos `tp...` (`SMALLINT`), com
  restrições `CHECK` e comentários que documentam cada código.
- Conteúdos extensos de laudos permanecem em `TEXT`, pois ultrapassam o uso
  usual de `VARCHAR` no Itriax.

## Situação

Esta proposta não foi aplicada ao PostgreSQL. A instância em uso continua com
o esquema legado e os dados migrados em 07/10/2026. A criação da nova base,
a conversão dos dados e a atualização dos importadores dependem da revisão e
aprovação deste modelo.
