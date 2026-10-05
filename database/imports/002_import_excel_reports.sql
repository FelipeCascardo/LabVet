\set ON_ERROR_STOP on

BEGIN;

CREATE TEMP TABLE report_staging (
  source_file_name TEXT NOT NULL,
  source_file_path TEXT NOT NULL,
  source_origin VARCHAR(3) NOT NULL CHECK (source_origin IN ('HV', 'AMA')),
  source_record_number BIGINT NOT NULL,
  report_type_code TEXT NOT NULL,
  raw_text TEXT,
  comments TEXT
);

CREATE TEMP TABLE result_staging (
  source_file_name TEXT NOT NULL,
  analyte_code TEXT NOT NULL,
  analyte_name TEXT NOT NULL,
  default_unit TEXT,
  value_kind TEXT NOT NULL CHECK (value_kind IN ('NUMERIC', 'TEXT', 'MIXED')),
  section_name TEXT NOT NULL,
  display_order SMALLINT NOT NULL,
  result_numeric NUMERIC(18,6),
  result_text TEXT,
  unit TEXT,
  reference_low NUMERIC(18,6),
  reference_high NUMERIC(18,6),
  reference_text TEXT
);

CREATE TEMP TABLE note_staging (
  source_file_name TEXT NOT NULL,
  note_text TEXT NOT NULL
);

\copy report_staging FROM '/tmp/labvet-laudos.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8', NULL '')
\copy result_staging FROM '/tmp/labvet-resultados.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8', NULL '')
\copy note_staging FROM '/tmp/labvet-comentarios.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8', NULL '')

INSERT INTO labvet.lab_analytes (code, name, default_unit, value_kind)
SELECT DISTINCT ON (source.analyte_code)
  source.analyte_code,
  source.analyte_name,
  NULLIF(source.default_unit, ''),
  source.value_kind
FROM result_staging source
ORDER BY source.analyte_code, source.analyte_name
ON CONFLICT (code) DO NOTHING;

CREATE TEMP TABLE inserted_reports AS
WITH inserted AS (
INSERT INTO labvet.laboratory_reports (
  attendance_id, lab_report_type_id, source_file_name, source_file_path,
  source_origin, source_record_number, report_year, extraction_status, raw_text
)
SELECT
  attendance.attendance_id,
  report_type.lab_report_type_id,
  source.source_file_name,
  source.source_file_path,
  source.source_origin,
  source.source_record_number,
  2026,
  'EXTRACTED',
  NULLIF(source.raw_text, '')
FROM report_staging source
JOIN labvet.attendances attendance
  ON attendance.source_origin = source.source_origin
  AND attendance.source_record_number = source.source_record_number
JOIN labvet.lab_report_types report_type ON report_type.code = source.report_type_code
ON CONFLICT (source_file_name) DO NOTHING
RETURNING laboratory_report_id, source_file_name
)
SELECT laboratory_report_id, source_file_name FROM inserted;

INSERT INTO labvet.laboratory_results (
  laboratory_report_id, lab_analyte_id, section_name, display_order,
  result_numeric, result_text, unit, reference_low, reference_high, reference_text
)
SELECT
  report.laboratory_report_id,
  analyte.lab_analyte_id,
  source.section_name,
  source.display_order,
  source.result_numeric,
  NULLIF(source.result_text, ''),
  NULLIF(source.unit, ''),
  source.reference_low,
  source.reference_high,
  NULLIF(source.reference_text, '')
FROM result_staging source
JOIN inserted_reports report ON report.source_file_name = source.source_file_name
JOIN labvet.lab_analytes analyte ON analyte.code = source.analyte_code
ON CONFLICT (laboratory_report_id, lab_analyte_id, section_name) DO UPDATE
  SET display_order = EXCLUDED.display_order,
      result_numeric = EXCLUDED.result_numeric,
      result_text = EXCLUDED.result_text,
      unit = EXCLUDED.unit,
      reference_low = EXCLUDED.reference_low,
      reference_high = EXCLUDED.reference_high,
      reference_text = EXCLUDED.reference_text;

INSERT INTO labvet.laboratory_report_notes (
  laboratory_report_id, note_type, display_order, note_text
)
SELECT report.laboratory_report_id, 'OBSERVATION', 1, source.note_text
FROM note_staging source
JOIN inserted_reports report ON report.source_file_name = source.source_file_name;

COMMIT;
