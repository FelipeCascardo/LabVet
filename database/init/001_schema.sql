CREATE SCHEMA IF NOT EXISTS labvet;
SET search_path TO labvet, public;

CREATE TYPE sex_code AS ENUM ('M', 'F', 'INDEFINIDO', 'NAO_INFORMADO');

CREATE TABLE owners (
  owner_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  source_key TEXT UNIQUE,
  full_name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE animals (
  animal_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  source_key TEXT UNIQUE,
  external_code TEXT,
  name TEXT NOT NULL,
  species TEXT,
  breed TEXT,
  sex sex_code NOT NULL DEFAULT 'NAO_INFORMADO',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX animals_external_code_idx ON animals (external_code);

CREATE TABLE animal_owners (
  animal_id BIGINT NOT NULL REFERENCES animals(animal_id),
  owner_id BIGINT NOT NULL REFERENCES owners(owner_id),
  is_current BOOLEAN NOT NULL DEFAULT true,
  started_on DATE,
  ended_on DATE,
  PRIMARY KEY (animal_id, owner_id),
  CHECK (ended_on IS NULL OR started_on IS NULL OR ended_on >= started_on)
);

CREATE UNIQUE INDEX animal_owners_one_current_owner_idx
  ON animal_owners (animal_id)
  WHERE is_current;

CREATE TABLE sectors (
  sector_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name TEXT NOT NULL,
  normalized_name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE exams (
  exam_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  external_code TEXT NOT NULL UNIQUE,
  name TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE import_batches (
  import_batch_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  source_file_name TEXT NOT NULL,
  source_period DATE,
  imported_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  notes TEXT
);

CREATE TABLE attendances (
  attendance_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  source_record_number BIGINT NOT NULL,
  source_origin VARCHAR(3) NOT NULL CHECK (source_origin IN ('HV', 'AMA')),
  attended_on DATE NOT NULL,
  animal_id BIGINT REFERENCES animals(animal_id),
  sector_id BIGINT REFERENCES sectors(sector_id),
  import_batch_id BIGINT REFERENCES import_batches(import_batch_id),
  age_text TEXT,
  clinical_history TEXT,
  reported_exam_total NUMERIC(12,2),
  charged_amount NUMERIC(12,2),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT attendances_source_origin_record_key UNIQUE (source_origin, source_record_number),
  CHECK (reported_exam_total IS NULL OR reported_exam_total >= 0),
  CHECK (charged_amount IS NULL OR charged_amount >= 0)
);

CREATE INDEX attendances_attended_on_idx ON attendances (attended_on);
CREATE INDEX attendances_animal_idx ON attendances (animal_id);
CREATE INDEX attendances_sector_idx ON attendances (sector_id);

CREATE TABLE attendance_exams (
  attendance_id BIGINT NOT NULL REFERENCES attendances(attendance_id) ON DELETE CASCADE,
  exam_id BIGINT NOT NULL REFERENCES exams(exam_id),
  quantity INTEGER NOT NULL DEFAULT 1,
  PRIMARY KEY (attendance_id, exam_id),
  CHECK (quantity > 0)
);

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER owners_set_updated_at
BEFORE UPDATE ON owners
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER animals_set_updated_at
BEFORE UPDATE ON animals
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
