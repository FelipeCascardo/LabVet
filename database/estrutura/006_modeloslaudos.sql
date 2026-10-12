-- Labvet V1 — organização dos modelos de laudo e suas referências por analito.
-- Aplicar após 005_analitosexameanalitos.sql.

BEGIN;

SET search_path TO labvet, public;

CREATE TABLE tiposanimais (
  idtipoanimal BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  idtipoanimalpai BIGINT,
  nmtipoanimal VARCHAR(150) NOT NULL,
  dsdescricao VARCHAR(500),
  stativo BOOLEAN NOT NULL DEFAULT true,
  idusuarioinclusao BIGINT,
  idusuarioalteracao BIGINT,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fktiposanimaistipoanimalpai FOREIGN KEY (idtipoanimalpai)
    REFERENCES tiposanimais (idtipoanimal) ON DELETE RESTRICT,
  CONSTRAINT fktiposanimaisusuarioinclusao FOREIGN KEY (idusuarioinclusao)
    REFERENCES usuario (idusuario) ON DELETE RESTRICT,
  CONSTRAINT fktiposanimaisusuarioalteracao FOREIGN KEY (idusuarioalteracao)
    REFERENCES usuario (idusuario) ON DELETE RESTRICT,
  CONSTRAINT cktiposanimaisnome CHECK (BTRIM(nmtipoanimal) <> ''),
  CONSTRAINT cktiposanimaisdescricao CHECK (dsdescricao IS NULL OR BTRIM(dsdescricao) <> '')
);

CREATE UNIQUE INDEX uxtiposanimaisraiznome
  ON tiposanimais (LOWER(nmtipoanimal))
  WHERE idtipoanimalpai IS NULL;
CREATE UNIQUE INDEX uxtiposanimaisfilhonome
  ON tiposanimais (idtipoanimalpai, LOWER(nmtipoanimal))
  WHERE idtipoanimalpai IS NOT NULL;

CREATE TABLE modeloslaudos (
  idmodelolaudo BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  idexame BIGINT NOT NULL,
  idtipoanimal BIGINT,
  cdmodelolaudo VARCHAR(100) NOT NULL,
  nmmodelolaudo VARCHAR(250) NOT NULL,
  dsfaixaidade VARCHAR(250),
  nmarquivoorigem VARCHAR(500),
  stativo BOOLEAN NOT NULL DEFAULT true,
  idusuarioinclusao BIGINT,
  idusuarioalteracao BIGINT,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uqmodeloslaudoscodigo UNIQUE (cdmodelolaudo),
  CONSTRAINT fkmodeloslaudosexame FOREIGN KEY (idexame)
    REFERENCES exames (idexame) ON DELETE RESTRICT,
  CONSTRAINT fkmodeloslaudostipoanimal FOREIGN KEY (idtipoanimal)
    REFERENCES tiposanimais (idtipoanimal) ON DELETE RESTRICT,
  CONSTRAINT fkmodeloslaudosusuarioinclusao FOREIGN KEY (idusuarioinclusao)
    REFERENCES usuario (idusuario) ON DELETE RESTRICT,
  CONSTRAINT fkmodeloslaudosusuarioalteracao FOREIGN KEY (idusuarioalteracao)
    REFERENCES usuario (idusuario) ON DELETE RESTRICT,
  CONSTRAINT ckmodeloslaudoscodigo CHECK (BTRIM(cdmodelolaudo) <> ''),
  CONSTRAINT ckmodeloslaudosnome CHECK (BTRIM(nmmodelolaudo) <> ''),
  CONSTRAINT ckmodeloslaudosfaixaidade CHECK (dsfaixaidade IS NULL OR BTRIM(dsfaixaidade) <> '')
);

CREATE INDEX ixmodeloslaudosexame ON modeloslaudos (idexame);
CREATE INDEX ixmodeloslaudostipoanimal ON modeloslaudos (idtipoanimal);

CREATE TABLE modeloexameanalitos (
  idmodeloexameanalito BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  idmodelolaudo BIGINT NOT NULL,
  idexameanalito BIGINT NOT NULL,
  dssecao VARCHAR(150),
  nrexibicao INTEGER NOT NULL,
  dsrotulo VARCHAR(250),
  dstecnica VARCHAR(250),
  dsunidademedida VARCHAR(50),
  dsreferencia TEXT,
  vrrefminimo NUMERIC(18,6),
  vrrefmaximo NUMERIC(18,6),
  stativo BOOLEAN NOT NULL DEFAULT true,
  idusuarioinclusao BIGINT,
  idusuarioalteracao BIGINT,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fkmodeloexameanalitosmodelolaudo FOREIGN KEY (idmodelolaudo)
    REFERENCES modeloslaudos (idmodelolaudo) ON DELETE RESTRICT,
  CONSTRAINT fkmodeloexameanalitosexameanalito FOREIGN KEY (idexameanalito)
    REFERENCES exameanalitos (idexameanalito) ON DELETE RESTRICT,
  CONSTRAINT fkmodeloexameanalitosusuarioinclusao FOREIGN KEY (idusuarioinclusao)
    REFERENCES usuario (idusuario) ON DELETE RESTRICT,
  CONSTRAINT fkmodeloexameanalitosusuarioalteracao FOREIGN KEY (idusuarioalteracao)
    REFERENCES usuario (idusuario) ON DELETE RESTRICT,
  CONSTRAINT uqmodeloexameanalitosordem UNIQUE (idmodelolaudo, nrexibicao),
  CONSTRAINT ckmodeloexameanalitosordem CHECK (nrexibicao > 0),
  CONSTRAINT ckmodeloexameanalitossecao CHECK (dssecao IS NULL OR BTRIM(dssecao) <> ''),
  CONSTRAINT ckmodeloexameanalitosreferencia CHECK (
    vrrefminimo IS NULL
    OR vrrefmaximo IS NULL
    OR vrrefminimo <= vrrefmaximo
  )
);

CREATE INDEX ixmodeloexameanalitosmodelo ON modeloexameanalitos (idmodelolaudo);
CREATE INDEX ixmodeloexameanalitosexameanalito ON modeloexameanalitos (idexameanalito);

CREATE TRIGGER tratualizartiposanimais
BEFORE UPDATE ON tiposanimais
FOR EACH ROW EXECUTE FUNCTION fnatualizardhalteracao();

CREATE TRIGGER tratualizarmodeloslaudos
BEFORE UPDATE ON modeloslaudos
FOR EACH ROW EXECUTE FUNCTION fnatualizardhalteracao();

CREATE TRIGGER tratualizarmodeloexameanalitos
BEFORE UPDATE ON modeloexameanalitos
FOR EACH ROW EXECUTE FUNCTION fnatualizardhalteracao();

COMMENT ON TABLE tiposanimais IS
  'Agrupamentos operacionais de animais utilizados pelo laboratório, com hierarquia opcional.';
COMMENT ON TABLE modeloslaudos IS
  'Modelos de laudo aplicáveis a um exame e, opcionalmente, a um agrupamento de animais.';
COMMENT ON COLUMN modeloslaudos.dsfaixaidade IS
  'Descrição livre da idade ou faixa etária à qual o modelo se aplica.';
COMMENT ON TABLE modeloexameanalitos IS
  'Configuração do analito em um modelo de laudo, incluindo apresentação e referências.';
COMMENT ON COLUMN modeloexameanalitos.dssecao IS
  'Seção visual ou clínica do laudo onde o analito é exibido, como Eritrograma ou Perfil renal.';
COMMENT ON COLUMN modeloexameanalitos.dsreferencia IS
  'Texto integral da referência apresentada no laudo, inclusive quando não numérica.';

COMMIT;
