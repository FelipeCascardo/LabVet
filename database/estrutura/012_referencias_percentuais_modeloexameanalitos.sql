-- Labvet V1 — referências textuais e percentuais dos analitos por modelo.
-- Aplicar após 011_renomear_tiposanimais_para_animalgrupos.sql.

BEGIN;

SET search_path TO labvet, public;

ALTER TABLE analitos
  ADD COLUMN fgpercentual BOOLEAN NOT NULL DEFAULT false;

UPDATE analitos
SET tpvalor = 3
WHERE tpvalor = 4;

ALTER TABLE analitos
  DROP CONSTRAINT ckanalitostpvalor;

ALTER TABLE analitos
  ADD CONSTRAINT ckanalitostpvalor CHECK (tpvalor IN (1, 2, 3));

ALTER TABLE modeloexameanalitos
  DROP CONSTRAINT ckmodeloexameanalitosreferencia;

ALTER TABLE modeloexameanalitos
  ALTER COLUMN vrrefminimo TYPE VARCHAR(100)
    USING vrrefminimo::TEXT,
  ALTER COLUMN vrrefmaximo TYPE VARCHAR(100)
    USING vrrefmaximo::TEXT,
  ADD COLUMN vrrefperminimo NUMERIC(7, 4),
  ADD COLUMN vrrefpermaximo NUMERIC(7, 4);

ALTER TABLE modeloexameanalitos
  ADD CONSTRAINT ckmodeloexameanalitosreferenciapercentual CHECK (
    (vrrefperminimo IS NULL OR vrrefperminimo BETWEEN 0 AND 100)
    AND (vrrefpermaximo IS NULL OR vrrefpermaximo BETWEEN 0 AND 100)
    AND (
      vrrefperminimo IS NULL
      OR vrrefpermaximo IS NULL
      OR vrrefperminimo <= vrrefpermaximo
    )
  );

CREATE OR REPLACE FUNCTION fnvalidarreferenciapercentualmodeloexameanalito()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  LPermitePercentual BOOLEAN;
BEGIN
  SELECT analito.fgpercentual
  INTO LPermitePercentual
  FROM exameanalitos exameanalito
  INNER JOIN analitos analito
    ON analito.idanalito = exameanalito.idanalito
  WHERE exameanalito.idexameanalito = NEW.idexameanalito;

  IF NOT COALESCE(LPermitePercentual, false)
    AND (NEW.vrrefperminimo IS NOT NULL OR NEW.vrrefpermaximo IS NOT NULL) THEN
    RAISE EXCEPTION
      'O analito vinculado não aceita referências percentuais.';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trvalidarreferenciapercentualmodeloexameanalito
BEFORE INSERT OR UPDATE ON modeloexameanalitos
FOR EACH ROW EXECUTE FUNCTION fnvalidarreferenciapercentualmodeloexameanalito();

CREATE OR REPLACE FUNCTION fnvalidardesativacaopercentualanalito()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF OLD.fgpercentual
    AND NOT NEW.fgpercentual
    AND EXISTS (
      SELECT 1
      FROM exameanalitos exameanalito
      INNER JOIN modeloexameanalitos modeloexameanalito
        ON modeloexameanalito.idexameanalito = exameanalito.idexameanalito
      WHERE exameanalito.idanalito = NEW.idanalito
        AND (
          modeloexameanalito.vrrefperminimo IS NOT NULL
          OR modeloexameanalito.vrrefpermaximo IS NOT NULL
        )
    ) THEN
    RAISE EXCEPTION
      'O analito possui referências percentuais em modelos de exame.';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trvalidardesativacaopercentualanalito
BEFORE UPDATE OF fgpercentual ON analitos
FOR EACH ROW EXECUTE FUNCTION fnvalidardesativacaopercentualanalito();

COMMENT ON COLUMN analitos.tpvalor IS
  '1: inteiro; 2: decimal; 3: caractere.';
COMMENT ON COLUMN analitos.fgpercentual IS
  'Indica se o analito aceita referências percentuais no modelo de exame.';
COMMENT ON COLUMN modeloexameanalitos.vrrefminimo IS
  'Limite inferior textual da referência, validado conforme tpvalor do analito.';
COMMENT ON COLUMN modeloexameanalitos.vrrefmaximo IS
  'Limite superior textual da referência, validado conforme tpvalor do analito.';
COMMENT ON COLUMN modeloexameanalitos.vrrefperminimo IS
  'Limite inferior percentual, entre 0 e 100, quando o analito permite percentual.';
COMMENT ON COLUMN modeloexameanalitos.vrrefpermaximo IS
  'Limite superior percentual, entre 0 e 100, quando o analito permite percentual.';

COMMIT;
