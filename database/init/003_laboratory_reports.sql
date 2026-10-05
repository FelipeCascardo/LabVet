BEGIN;

CREATE TABLE labvet.lab_report_types (
  lab_report_type_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  CHECK (code IN ('B', 'H', 'IMUNO4DX', 'EAS'))
);

INSERT INTO labvet.lab_report_types (code, name, description)
VALUES
  ('B', 'Bioquímica', 'Laudo bioquímico com resultados quantitativos.'),
  ('H', 'Hemograma', 'Laudo hematológico com eritrograma, leucograma e medidas associadas.'),
  ('IMUNO4DX', 'Imuno 4DX', 'Painel qualitativo para Anaplasma, Borrelia, Dirofilaria e Ehrlichia.'),
  ('EAS', 'Urinálise', 'Exame de urina com avaliação física, química, sedimentoscopia e bioquímica urinária.');

CREATE TABLE labvet.laboratory_reports (
  laboratory_report_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  attendance_id BIGINT NOT NULL REFERENCES labvet.attendances(attendance_id),
  lab_report_type_id BIGINT NOT NULL REFERENCES labvet.lab_report_types(lab_report_type_id),
  source_file_name TEXT NOT NULL UNIQUE,
  source_file_path TEXT NOT NULL,
  source_origin VARCHAR(3) NOT NULL CHECK (source_origin IN ('HV', 'AMA')),
  source_record_number BIGINT NOT NULL,
  report_year SMALLINT NOT NULL CHECK (report_year BETWEEN 2000 AND 2100),
  reported_at TIMESTAMPTZ,
  sample_type TEXT,
  kit_name TEXT,
  method_text TEXT,
  reported_patient_name TEXT,
  reported_animal_code TEXT,
  reported_species TEXT,
  reported_breed TEXT,
  reported_sex TEXT,
  reported_age_text TEXT,
  reported_owner_name TEXT,
  reported_veterinarian_name TEXT,
  reported_veterinarian_crmv TEXT,
  source_file_hash TEXT,
  extraction_status TEXT NOT NULL DEFAULT 'PENDING'
    CHECK (extraction_status IN ('PENDING', 'EXTRACTED', 'REVIEWED', 'FAILED')),
  raw_text TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (source_record_number > 0)
);

CREATE INDEX laboratory_reports_attendance_idx
  ON labvet.laboratory_reports (attendance_id);
CREATE INDEX laboratory_reports_type_idx
  ON labvet.laboratory_reports (lab_report_type_id);
CREATE INDEX laboratory_reports_record_idx
  ON labvet.laboratory_reports (source_record_number);

CREATE TABLE labvet.lab_report_exams (
  laboratory_report_id BIGINT NOT NULL REFERENCES labvet.laboratory_reports(laboratory_report_id) ON DELETE CASCADE,
  exam_id BIGINT NOT NULL REFERENCES labvet.exams(exam_id),
  is_primary BOOLEAN NOT NULL DEFAULT false,
  PRIMARY KEY (laboratory_report_id, exam_id)
);

CREATE UNIQUE INDEX lab_report_exams_one_primary_idx
  ON labvet.lab_report_exams (laboratory_report_id)
  WHERE is_primary;

CREATE TABLE labvet.lab_analytes (
  lab_analyte_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  default_unit TEXT,
  value_kind TEXT NOT NULL DEFAULT 'MIXED'
    CHECK (value_kind IN ('NUMERIC', 'TEXT', 'MIXED')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE labvet.laboratory_results (
  laboratory_result_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  laboratory_report_id BIGINT NOT NULL REFERENCES labvet.laboratory_reports(laboratory_report_id) ON DELETE CASCADE,
  lab_analyte_id BIGINT NOT NULL REFERENCES labvet.lab_analytes(lab_analyte_id),
  section_name TEXT NOT NULL,
  display_order SMALLINT NOT NULL CHECK (display_order > 0),
  result_numeric NUMERIC(18,6),
  result_text TEXT,
  unit TEXT,
  reference_low NUMERIC(18,6),
  reference_high NUMERIC(18,6),
  reference_text TEXT,
  method_text TEXT,
  CHECK (result_numeric IS NOT NULL OR result_text IS NOT NULL),
  UNIQUE (laboratory_report_id, lab_analyte_id, section_name)
);

CREATE INDEX laboratory_results_report_idx
  ON labvet.laboratory_results (laboratory_report_id, display_order);
CREATE INDEX laboratory_results_analyte_idx
  ON labvet.laboratory_results (lab_analyte_id);

CREATE TABLE labvet.laboratory_report_notes (
  laboratory_report_note_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  laboratory_report_id BIGINT NOT NULL REFERENCES labvet.laboratory_reports(laboratory_report_id) ON DELETE CASCADE,
  note_type TEXT NOT NULL CHECK (note_type IN ('OBSERVATION', 'FINDING', 'REFERENCE_SOURCE', 'OTHER')),
  display_order SMALLINT NOT NULL DEFAULT 1 CHECK (display_order > 0),
  note_text TEXT NOT NULL
);

CREATE INDEX laboratory_report_notes_report_idx
  ON labvet.laboratory_report_notes (laboratory_report_id, display_order);

COMMIT;
