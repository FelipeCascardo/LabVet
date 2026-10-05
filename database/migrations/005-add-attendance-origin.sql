BEGIN;

ALTER TABLE labvet.attendances
  ADD COLUMN source_origin VARCHAR(3) NOT NULL
  CHECK (source_origin IN ('HV', 'AMA'));

ALTER TABLE labvet.attendances
  DROP CONSTRAINT attendances_source_record_number_key;

ALTER TABLE labvet.attendances
  ADD CONSTRAINT attendances_source_origin_record_key
  UNIQUE (source_origin, source_record_number);

COMMIT;
