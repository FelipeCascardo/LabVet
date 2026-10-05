BEGIN;

ALTER TABLE labvet.laboratory_reports
  ADD COLUMN source_origin VARCHAR(3) NOT NULL DEFAULT 'HV'
  CHECK (source_origin IN ('HV', 'AMA'));

CREATE INDEX laboratory_reports_origin_record_idx
  ON labvet.laboratory_reports (source_origin, source_record_number);

COMMIT;
