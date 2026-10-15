-- LabVet V1 — recupera referências percentuais preservadas em dsreferencia.
-- O formato de origem é: percentual mínimo, percentual máximo,
-- referência mínima convencional e referência máxima convencional.
-- Aplicar após 015_recuperar_referencias_numericas_modelos.sql.

BEGIN;

SET search_path TO labvet, public;

WITH referencias_percentuais AS (
  SELECT DISTINCT exameanalito.idanalito
  FROM modeloexameanalitos modeloexameanalito
  INNER JOIN exameanalitos exameanalito
    ON exameanalito.idexameanalito = modeloexameanalito.idexameanalito
  WHERE trim(modeloexameanalito.dsreferencia) ~
    '^([+-]?[0-9]+([.,][0-9]+)?)[[:space:]]+([+-]?[0-9]+([.,][0-9]+)?)[[:space:]]+([+-]?[0-9]+([.,][0-9]+)?)[[:space:]]*-[[:space:]]*([+-]?[0-9]+([.,][0-9]+)?)$'
)
UPDATE analitos analito
SET fgpercentual = TRUE
FROM referencias_percentuais
WHERE analito.idanalito = referencias_percentuais.idanalito
  AND NOT analito.fgpercentual;

WITH referencias_recuperaveis AS (
  SELECT
    modeloexameanalito.idmodeloexameanalito,
    regexp_match(
      trim(modeloexameanalito.dsreferencia),
      '^([+-]?[0-9]+([.,][0-9]+)?)[[:space:]]+([+-]?[0-9]+([.,][0-9]+)?)[[:space:]]+([+-]?[0-9]+([.,][0-9]+)?)[[:space:]]*-[[:space:]]*([+-]?[0-9]+([.,][0-9]+)?)$'
    ) AS faixa
  FROM modeloexameanalitos modeloexameanalito
  WHERE modeloexameanalito.dsreferencia IS NOT NULL
    AND (
      modeloexameanalito.vrrefperminimo IS NULL
      OR modeloexameanalito.vrrefpermaximo IS NULL
    )
),
atualizados AS (
  UPDATE modeloexameanalitos modeloexameanalito
  SET
    vrrefminimo = CASE
      WHEN replace(referencias_recuperaveis.faixa[5], ',', '.')::NUMERIC <=
        replace(referencias_recuperaveis.faixa[7], ',', '.')::NUMERIC
      THEN COALESCE(modeloexameanalito.vrrefminimo, referencias_recuperaveis.faixa[5])
      ELSE modeloexameanalito.vrrefminimo
    END,
    vrrefmaximo = CASE
      WHEN replace(referencias_recuperaveis.faixa[5], ',', '.')::NUMERIC <=
        replace(referencias_recuperaveis.faixa[7], ',', '.')::NUMERIC
      THEN COALESCE(modeloexameanalito.vrrefmaximo, referencias_recuperaveis.faixa[7])
      ELSE modeloexameanalito.vrrefmaximo
    END,
    vrrefperminimo = COALESCE(
      modeloexameanalito.vrrefperminimo,
      replace(referencias_recuperaveis.faixa[1], ',', '.')::NUMERIC
    ),
    vrrefpermaximo = COALESCE(
      modeloexameanalito.vrrefpermaximo,
      replace(referencias_recuperaveis.faixa[3], ',', '.')::NUMERIC
    )
  FROM referencias_recuperaveis
  WHERE modeloexameanalito.idmodeloexameanalito =
    referencias_recuperaveis.idmodeloexameanalito
    AND referencias_recuperaveis.faixa IS NOT NULL
  RETURNING modeloexameanalito.idmodeloexameanalito
)
SELECT count(*) AS referencias_percentuais_recuperadas
FROM atualizados;

COMMIT;
