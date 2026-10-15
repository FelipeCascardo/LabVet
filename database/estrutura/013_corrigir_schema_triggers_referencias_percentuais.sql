-- Labvet V1 — qualificação de schema dos triggers da migration 012.
-- Aplicar após 012_referencias_percentuais_modeloexameanalitos.sql.

BEGIN;

CREATE OR REPLACE FUNCTION labvet.fnvalidarreferenciapercentualmodeloexameanalito()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  LPermitePercentual BOOLEAN;
BEGIN
  SELECT analito.fgpercentual
  INTO LPermitePercentual
  FROM labvet.exameanalitos exameanalito
  INNER JOIN labvet.analitos analito
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

CREATE OR REPLACE FUNCTION labvet.fnvalidardesativacaopercentualanalito()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF OLD.fgpercentual
    AND NOT NEW.fgpercentual
    AND EXISTS (
      SELECT 1
      FROM labvet.exameanalitos exameanalito
      INNER JOIN labvet.modeloexameanalitos modeloexameanalito
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

COMMIT;
