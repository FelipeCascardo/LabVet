\set ON_ERROR_STOP on

BEGIN;

CREATE TEMP TABLE import_staging (
  source_origin VARCHAR(3) NOT NULL CHECK (source_origin IN ('HV', 'AMA')),
  source_record_number BIGINT NOT NULL,
  attended_on DATE NOT NULL,
  owner_name TEXT,
  owner_key TEXT,
  animal_name TEXT,
  animal_key TEXT,
  external_code TEXT,
  species TEXT,
  breed TEXT,
  sex labvet.sex_code NOT NULL,
  sector_name TEXT,
  sector_key TEXT,
  age_text TEXT,
  clinical_history TEXT,
  reported_exam_total NUMERIC(12,2),
  charged_amount NUMERIC(12,2),
  exams_pipe TEXT
);

\copy import_staging FROM '/tmp/labvet-setembro-2026.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8', NULL '')

INSERT INTO labvet.owners (source_key, full_name)
SELECT owner_key, owner_name
FROM (
  SELECT DISTINCT ON (owner_key) owner_key, owner_name
  FROM import_staging
  WHERE owner_key <> ''
  ORDER BY owner_key, owner_name
) owners_to_insert
ON CONFLICT (source_key) DO NOTHING;

INSERT INTO labvet.animals (source_key, external_code, name, species, breed, sex)
SELECT animal_key, external_code, animal_name, species, breed, sex
FROM (
  SELECT DISTINCT ON (animal_key)
    external_code, animal_name, species, breed, sex, animal_key
  FROM import_staging
  WHERE animal_key <> '' AND animal_name <> ''
  ORDER BY animal_key, source_record_number
) animals_to_insert
ON CONFLICT (source_key) DO NOTHING;

INSERT INTO labvet.animal_owners (animal_id, owner_id, is_current)
SELECT DISTINCT animal.animal_id, owner.owner_id, true
FROM import_staging source
JOIN labvet.animals animal
  ON animal.source_key = source.animal_key
JOIN labvet.owners owner ON owner.source_key = source.owner_key
WHERE source.animal_name <> '' AND source.owner_name <> ''
ON CONFLICT DO NOTHING;

INSERT INTO labvet.sectors (name, normalized_name)
SELECT DISTINCT ON (sector_key) sector_name, sector_key
FROM import_staging
WHERE sector_key <> ''
ORDER BY sector_key, sector_name
ON CONFLICT (normalized_name) DO NOTHING;

INSERT INTO labvet.exams (external_code)
SELECT DISTINCT NULLIF(btrim(exam_token), '')
FROM import_staging source
CROSS JOIN LATERAL regexp_split_to_table(source.exams_pipe, '\s*\|\s*') AS exam_token
WHERE NULLIF(btrim(exam_token), '') IS NOT NULL
ON CONFLICT (external_code) DO NOTHING;

WITH inserted_batches AS (
  INSERT INTO labvet.import_batches (source_file_name, source_period, notes)
  SELECT
    CASE source_origin
      WHEN 'HV' THEN '9 - Setembro - 2026 HV.xlsx'
      WHEN 'AMA' THEN '9 - Setembro - 2026 AMA.xlsx'
    END,
    DATE '2026-09-01',
    'Carga de atendimentos de setembro de 2026, origem ' || source_origin || '.'
  FROM (SELECT DISTINCT source_origin FROM import_staging) origins
  RETURNING import_batch_id, source_file_name
)
INSERT INTO labvet.attendances (
  source_origin, source_record_number, attended_on, animal_id, sector_id, import_batch_id,
  age_text, clinical_history, reported_exam_total, charged_amount
)
SELECT
  source.source_origin,
  source.source_record_number,
  source.attended_on,
  animal.animal_id,
  sector.sector_id,
  batch.import_batch_id,
  NULLIF(source.age_text, ''),
  NULLIF(source.clinical_history, ''),
  source.reported_exam_total,
  source.charged_amount
FROM import_staging source
LEFT JOIN labvet.animals animal
  ON animal.source_key = source.animal_key
LEFT JOIN labvet.sectors sector ON sector.normalized_name = source.sector_key
JOIN inserted_batches batch ON batch.source_file_name = CASE source.source_origin
  WHEN 'HV' THEN '9 - Setembro - 2026 HV.xlsx'
  WHEN 'AMA' THEN '9 - Setembro - 2026 AMA.xlsx'
END;

INSERT INTO labvet.attendance_exams (attendance_id, exam_id, quantity)
SELECT attendance.attendance_id, exam.exam_id, COUNT(*)::INTEGER
FROM import_staging source
JOIN labvet.attendances attendance
  ON attendance.source_origin = source.source_origin
  AND attendance.source_record_number = source.source_record_number
CROSS JOIN LATERAL regexp_split_to_table(source.exams_pipe, '\s*\|\s*') AS exam_token
JOIN labvet.exams exam ON exam.external_code = NULLIF(btrim(exam_token), '')
WHERE NULLIF(btrim(exam_token), '') IS NOT NULL
GROUP BY attendance.attendance_id, exam.exam_id;

COMMIT;
