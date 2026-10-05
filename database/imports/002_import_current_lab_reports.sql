\set ON_ERROR_STOP on

BEGIN;

CREATE TEMP TABLE lab_report_staging (
  source_file_name TEXT NOT NULL,
  source_file_path TEXT NOT NULL,
  source_record_number BIGINT NOT NULL,
  report_year SMALLINT NOT NULL,
  report_type_code TEXT NOT NULL,
  reported_at TIMESTAMPTZ,
  source_file_hash TEXT NOT NULL,
  raw_text TEXT NOT NULL
);

\copy lab_report_staging FROM '/tmp/labvet-current-reports.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8', NULL '')

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM lab_report_staging source
    LEFT JOIN labvet.attendances attendance
      ON attendance.source_record_number = source.source_record_number
    WHERE attendance.attendance_id IS NULL
  ) THEN
    RAISE EXCEPTION 'Há PDFs sem atendimento correspondente';
  END IF;
END;
$$;

INSERT INTO labvet.laboratory_reports (
  attendance_id, lab_report_type_id, source_file_name, source_file_path,
  source_record_number, report_year, reported_at, source_file_hash,
  extraction_status, raw_text
)
SELECT
  attendance.attendance_id,
  report_type.lab_report_type_id,
  source.source_file_name,
  source.source_file_path,
  source.source_record_number,
  source.report_year,
  source.reported_at,
  source.source_file_hash,
  'EXTRACTED',
  source.raw_text
FROM lab_report_staging source
JOIN labvet.attendances attendance
  ON attendance.source_record_number = source.source_record_number
JOIN labvet.lab_report_types report_type
  ON report_type.code = source.report_type_code;

COMMIT;
