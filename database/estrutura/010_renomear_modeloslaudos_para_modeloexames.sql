-- Labvet V1 — padronização do grupo de modelos de exames.
-- Executar após 009_auditoriaeventos.sql.

BEGIN;

SET search_path TO labvet, public;

-- O modelo descreve a composição de um exame. "Laudo" será reservado
-- às entidades que registrarem a realização e a emissão do resultado.
ALTER TABLE modeloslaudos
  RENAME TO modeloexames;

ALTER TABLE modeloexames
  RENAME COLUMN idmodelolaudo TO idmodeloexame;

ALTER TABLE modeloexameanalitos
  RENAME COLUMN idmodelolaudo TO idmodeloexame;

-- Restrições, índices e trigger recebem nomes coerentes com a nova tabela.
ALTER TABLE modeloexames
  RENAME CONSTRAINT modeloslaudos_pkey TO modeloexames_pkey;
ALTER TABLE modeloexames
  RENAME CONSTRAINT uqmodeloslaudoscodigo TO uqmodeloexamescodigo;
ALTER TABLE modeloexames
  RENAME CONSTRAINT fkmodeloslaudosexame TO fkmodeloexamesexame;
ALTER TABLE modeloexames
  RENAME CONSTRAINT fkmodeloslaudostipoanimal TO fkmodeloexamestipoanimal;
ALTER TABLE modeloexames
  RENAME CONSTRAINT fkmodeloslaudosusuarioinclusao TO fkmodeloexamesusuarioinclusao;
ALTER TABLE modeloexames
  RENAME CONSTRAINT fkmodeloslaudosusuarioalteracao TO fkmodeloexamesusuarioalteracao;
ALTER TABLE modeloexames
  RENAME CONSTRAINT ckmodeloslaudoscodigo TO ckmodeloexamescodigo;
ALTER TABLE modeloexames
  RENAME CONSTRAINT ckmodeloslaudosnome TO ckmodeloexamesnome;
ALTER TABLE modeloexames
  RENAME CONSTRAINT ckmodeloslaudosfaixaidade TO ckmodeloexamesfaixaidade;

ALTER TABLE modeloexameanalitos
  RENAME CONSTRAINT fkmodeloexameanalitosmodelolaudo TO fkmodeloexameanalitosmodeloexame;

ALTER INDEX ixmodeloslaudosexame
  RENAME TO ixmodeloexamesexame;
ALTER INDEX ixmodeloslaudostipoanimal
  RENAME TO ixmodeloexamestipoanimal;
ALTER INDEX ixmodeloexameanalitosmodelo
  RENAME TO ixmodeloexameanalitosmodeloexame;

ALTER TRIGGER tratualizarmodeloslaudos ON modeloexames
  RENAME TO tratualizarmodeloexames;

COMMENT ON TABLE modeloexames IS
  'Modelos configuráveis de exames, aplicáveis opcionalmente a agrupamentos de animais.';
COMMENT ON COLUMN modeloexameanalitos.idmodeloexame IS
  'Modelo de exame que configura a apresentação e referências do analito.';

COMMIT;
