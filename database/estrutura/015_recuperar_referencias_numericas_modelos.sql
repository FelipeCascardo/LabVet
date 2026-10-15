-- LabVet V1 — recupera limites numéricos preservados apenas em dsreferencia.
-- Aplicar após 014_laudos_e_laudoanalitos.sql.

BEGIN;

SET search_path TO labvet, public;

WITH referencias_recuperaveis AS (
  SELECT
    modeloexameanalito.idmodeloexameanalito,
    regexp_match(
      regexp_replace(
        trim(modeloexameanalito.dsreferencia),
        '^0[[:space:]]+',
        ''
      ),
      '^([+-]?[0-9]+([.,][0-9]+)?)[[:space:]]*-[[:space:]]*([+-]?[0-9]+([.,][0-9]+)?)$'
    ) AS faixa
  FROM modeloexameanalitos modeloexameanalito
  WHERE modeloexameanalito.vrrefminimo IS NULL
    AND modeloexameanalito.vrrefmaximo IS NULL
    AND modeloexameanalito.dsreferencia IS NOT NULL
),
atualizados AS (
  UPDATE modeloexameanalitos modeloexameanalito
  SET
    vrrefminimo = referencias_recuperaveis.faixa[1],
    vrrefmaximo = referencias_recuperaveis.faixa[3]
  FROM referencias_recuperaveis
  WHERE modeloexameanalito.idmodeloexameanalito =
    referencias_recuperaveis.idmodeloexameanalito
    AND referencias_recuperaveis.faixa IS NOT NULL
  RETURNING modeloexameanalito.idmodeloexameanalito
)
SELECT count(*) AS referencias_recuperadas
FROM atualizados;

COMMIT;
