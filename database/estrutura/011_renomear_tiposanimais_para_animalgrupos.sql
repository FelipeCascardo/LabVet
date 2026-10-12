-- LabVet V1 — padronização dos agrupamentos de animais.
-- Executar após 010_renomear_modeloslaudos_para_modeloexames.sql.

BEGIN;

SET search_path TO labvet, public;

ALTER TABLE tiposanimais
  RENAME TO animalgrupos;

ALTER TABLE animalgrupos
  RENAME COLUMN idtipoanimal TO idanimalgrupo;

ALTER TABLE animalgrupos
  RENAME COLUMN idtipoanimalpai TO idanimalgrupopai;

ALTER TABLE modeloexames
  RENAME COLUMN idtipoanimal TO idanimalgrupo;

ALTER TABLE animalgrupos
  RENAME CONSTRAINT tiposanimais_pkey TO animalgrupos_pkey;
ALTER TABLE animalgrupos
  RENAME CONSTRAINT fktiposanimaistipoanimalpai TO fkanimalgruposanimalgrupopai;
ALTER TABLE animalgrupos
  RENAME CONSTRAINT fktiposanimaisusuarioinclusao TO fkanimalgruposusuarioinclusao;
ALTER TABLE animalgrupos
  RENAME CONSTRAINT fktiposanimaisusuarioalteracao TO fkanimalgruposusuarioalteracao;
ALTER TABLE animalgrupos
  RENAME CONSTRAINT cktiposanimaisnome TO ckanimalgruposnome;
ALTER TABLE animalgrupos
  RENAME CONSTRAINT cktiposanimaisdescricao TO ckanimalgruposdescricao;

ALTER TABLE modeloexames
  RENAME CONSTRAINT fkmodeloexamestipoanimal TO fkmodeloexamesanimalgrupo;

ALTER INDEX uxtiposanimaisraiznome
  RENAME TO uxanimalgruposraiznome;
ALTER INDEX uxtiposanimaisfilhonome
  RENAME TO uxanimalgruposfilhonome;
ALTER INDEX ixmodeloexamestipoanimal
  RENAME TO ixmodeloexamesanimalgrupo;

ALTER TRIGGER tratualizartiposanimais ON animalgrupos
  RENAME TO tratualizaranimalgrupos;

COMMENT ON TABLE animalgrupos IS
  'Agrupamentos operacionais de animais, com hierarquia opcional.';
COMMENT ON COLUMN modeloexames.idanimalgrupo IS
  'Grupo de animais opcional ao qual o modelo de exame se aplica.';

COMMIT;
