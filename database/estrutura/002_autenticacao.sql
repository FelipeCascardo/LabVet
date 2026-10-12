-- LabVet V1 — sessões e recuperação de senha.
-- Aplicar após 001_catalogoexames.sql.

BEGIN;

SET search_path TO labvet, public;

ALTER TABLE usuario
  ALTER COLUMN dssenhahash TYPE VARCHAR(255),
  ADD COLUMN nrversaoseguranca INTEGER NOT NULL DEFAULT 1;

CREATE TABLE sessao (
  idsessao BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  idusuario BIGINT NOT NULL,
  dsrefreshhash VARCHAR(64) NOT NULL,
  dhexpiracao TIMESTAMPTZ NOT NULL,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhrevogacao TIMESTAMPTZ,
  nrversaoseguranca INTEGER NOT NULL,
  CONSTRAINT fksessaousuario FOREIGN KEY (idusuario)
    REFERENCES usuario (idusuario) ON DELETE RESTRICT
);

CREATE INDEX ixsessaousuario ON sessao (idusuario);
CREATE UNIQUE INDEX uxsessaorefreshhash ON sessao (dsrefreshhash)
  WHERE dhrevogacao IS NULL;

CREATE TABLE recuperacaosenha (
  idrecuperacaosenha BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  idusuario BIGINT NOT NULL,
  dstokenhash VARCHAR(64) NOT NULL,
  dhexpiracao TIMESTAMPTZ NOT NULL,
  dhutilizacao TIMESTAMPTZ,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fkrecuperacaosenhausuario FOREIGN KEY (idusuario)
    REFERENCES usuario (idusuario) ON DELETE RESTRICT,
  CONSTRAINT uqrecuperacaosenhatokenhash UNIQUE (dstokenhash)
);

CREATE INDEX ixrecuperacaosenhausuarioativa
  ON recuperacaosenha (idusuario)
  WHERE dhutilizacao IS NULL;

CREATE TRIGGER tratualizarsessao
BEFORE UPDATE ON sessao
FOR EACH ROW EXECUTE FUNCTION fnatualizardhalteracao();

CREATE TRIGGER tratualizarrecuperacaosenha
BEFORE UPDATE ON recuperacaosenha
FOR EACH ROW EXECUTE FUNCTION fnatualizardhalteracao();

COMMENT ON TABLE sessao IS
  'Sessões autenticadas, com token de atualização armazenado somente como hash.';
COMMENT ON TABLE recuperacaosenha IS
  'Solicitações de recuperação de senha, com token armazenado somente como hash.';

COMMIT;
