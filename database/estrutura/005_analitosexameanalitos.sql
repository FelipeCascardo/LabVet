-- Labvet V1 — catálogo de analitos e vínculo base com exames.
-- Aplicar após 004_carga_catalogoexames.sql.

BEGIN;

SET search_path TO labvet, public;

CREATE TABLE analitos (
  idanalito BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  cdanalito VARCHAR(100) NOT NULL,
  nmanalito VARCHAR(200) NOT NULL,
  dstecnica VARCHAR(250),
  dsunidademedida VARCHAR(50),
  tpvalor SMALLINT NOT NULL,
  stativo BOOLEAN NOT NULL DEFAULT true,
  idusuarioinclusao BIGINT,
  idusuarioalteracao BIGINT,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uqanalitoscodigo UNIQUE (cdanalito),
  CONSTRAINT ckanalitostpvalor CHECK (tpvalor IN (1, 2, 3, 4)),
  CONSTRAINT fkanalitosusuarioinclusao FOREIGN KEY (idusuarioinclusao)
    REFERENCES usuario (idusuario) ON DELETE RESTRICT,
  CONSTRAINT fkanalitosusuarioalteracao FOREIGN KEY (idusuarioalteracao)
    REFERENCES usuario (idusuario) ON DELETE RESTRICT
);

CREATE TABLE exameanalitos (
  idexameanalito BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  idexame BIGINT NOT NULL,
  idanalito BIGINT NOT NULL,
  stativo BOOLEAN NOT NULL DEFAULT true,
  idusuarioinclusao BIGINT,
  idusuarioalteracao BIGINT,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uqexameanalitosvinculo UNIQUE (idexame, idanalito),
  CONSTRAINT fkexameanalitosexame FOREIGN KEY (idexame)
    REFERENCES exames (idexame) ON DELETE RESTRICT,
  CONSTRAINT fkexameanalitosanalito FOREIGN KEY (idanalito)
    REFERENCES analitos (idanalito) ON DELETE RESTRICT,
  CONSTRAINT fkexameanalitosusuarioinclusao FOREIGN KEY (idusuarioinclusao)
    REFERENCES usuario (idusuario) ON DELETE RESTRICT,
  CONSTRAINT fkexameanalitosusuarioalteracao FOREIGN KEY (idusuarioalteracao)
    REFERENCES usuario (idusuario) ON DELETE RESTRICT
);

CREATE INDEX ixexameanalitosexame ON exameanalitos (idexame);
CREATE INDEX ixexameanalitosanalito ON exameanalitos (idanalito);
CREATE INDEX ixanalitosnome ON analitos (nmanalito);

CREATE TRIGGER tratualizaranalitos
BEFORE UPDATE ON analitos
FOR EACH ROW EXECUTE FUNCTION fnatualizardhalteracao();

CREATE TRIGGER tratualizarexameanalitos
BEFORE UPDATE ON exameanalitos
FOR EACH ROW EXECUTE FUNCTION fnatualizardhalteracao();

COMMENT ON TABLE analitos IS
  'Parâmetros laboratoriais medidos nos exames.';
COMMENT ON COLUMN analitos.tpvalor IS
  '1: numérico inteiro; 2: numérico decimal; 3: caractere; 4: misto.';
COMMENT ON TABLE exameanalitos IS
  'Vínculo base entre exame e analito. Referências e apresentação são definidas por modelo de laudo.';

COMMIT;
