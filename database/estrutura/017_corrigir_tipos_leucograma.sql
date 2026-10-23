-- LabVet V1 — classifica como inteiros os analitos numéricos do leucograma.
-- Basófilos permanece caractere porque pode usar referência textual (por exemplo, "raros").

BEGIN;

SET search_path TO labvet, public;

UPDATE analitos
SET tpvalor = 1
WHERE cdanalito IN (
  'ANA-BASTOES',
  'ANA-LEUCOCITOS',
  'ANA-MIELOCITOS'
)
  AND tpvalor <> 1;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM analitos
    WHERE cdanalito IN (
      'ANA-BASTOES',
      'ANA-LEUCOCITOS',
      'ANA-MIELOCITOS'
    )
      AND tpvalor <> 1
  ) THEN
    RAISE EXCEPTION 'Os analitos numéricos do leucograma devem permanecer como inteiros.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM analitos
    WHERE cdanalito = 'ANA-BASOFILOS'
      AND tpvalor = 3
  ) THEN
    RAISE EXCEPTION 'Basófilos deve permanecer como caractere.';
  END IF;
END;
$$;

COMMIT;
