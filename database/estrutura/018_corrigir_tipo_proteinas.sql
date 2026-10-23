-- LabVet V1 — classifica Proteínas como valor numérico decimal.

BEGIN;

SET search_path TO labvet, public;

UPDATE analitos
SET tpvalor = 2
WHERE cdanalito = 'ANA-PROTEINAS'
  AND tpvalor <> 2;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM analitos
    WHERE cdanalito = 'ANA-PROTEINAS'
      AND tpvalor = 2
  ) THEN
    RAISE EXCEPTION 'Proteínas deve permanecer classificado como decimal.';
  END IF;
END;
$$;

COMMIT;
