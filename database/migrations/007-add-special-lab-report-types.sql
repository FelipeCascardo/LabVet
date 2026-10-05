BEGIN;

ALTER TABLE labvet.lab_report_types
  DROP CONSTRAINT IF EXISTS lab_report_types_code_check;

ALTER TABLE labvet.lab_report_types
  ADD CONSTRAINT lab_report_types_code_check CHECK (code IN (
    'B', 'H', 'EAS', 'IMUNO4DX', 'LEPTO', 'KNOTT', 'CORTISOL', 'T4',
    'COMPAT', 'HEMOAGL', 'HEMOP', 'SALINA', 'LIQCAV', 'LAVBRONQ'
  ));

INSERT INTO labvet.lab_report_types (code, name, description) VALUES
  ('LEPTO', 'Leptospirose', 'Painel qualitativo para Leptospira spp.'),
  ('KNOTT', 'Técnica de Knott', 'Pesquisa de microfilárias em sangue total.'),
  ('CORTISOL', 'Cortisol', 'Dosagem de cortisol por imunoensaio.'),
  ('T4', 'T4', 'Dosagem de tiroxina total por imunoensaio.'),
  ('COMPAT', 'Compatibilidade sanguínea', 'Avaliação pré-transfusional de compatibilidade.'),
  ('HEMOAGL', 'Hemoaglutinação', 'Teste de hemoaglutinação.'),
  ('HEMOP', 'Pesquisa de hemoparasitas', 'Pesquisa em esfregaço sanguíneo.'),
  ('SALINA', 'Hemoaglutinação em salina', 'Teste de hemoaglutinação em salina.'),
  ('LIQCAV', 'Análise de líquido cavitário', 'Avaliação física, química e citológica de líquido cavitário.'),
  ('LAVBRONQ', 'Lavado broncoalveolar', 'Avaliação de amostra de lavado broncoalveolar.')
ON CONFLICT (code) DO NOTHING;

COMMIT;
