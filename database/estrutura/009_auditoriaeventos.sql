-- Labvet V1 — registro imutável de eventos do aplicativo.

BEGIN;

SET search_path TO labvet, public;

CREATE TABLE auditoriaeventos (
  idauditoriaevento BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  idusuario BIGINT,
  tpevento VARCHAR(100) NOT NULL,
  tprecurso VARCHAR(100) NOT NULL,
  cdrecurso VARCHAR(100),
  cdrequisicao VARCHAR(100),
  dsdetalhes JSONB NOT NULL DEFAULT '{}'::JSONB,
  dhocorrencia TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fkauditoriaeventosusuario FOREIGN KEY (idusuario)
    REFERENCES usuario (idusuario) ON DELETE RESTRICT,
  CONSTRAINT ckauditoriaeventostpevento CHECK (BTRIM(tpevento) <> ''),
  CONSTRAINT ckauditoriaeventostprecurso CHECK (BTRIM(tprecurso) <> '')
);

CREATE INDEX ixauditoriaeventosrecurso
  ON auditoriaeventos (tprecurso, cdrecurso, dhocorrencia DESC);
CREATE INDEX ixauditoriaeventosusuario
  ON auditoriaeventos (idusuario, dhocorrencia DESC)
  WHERE idusuario IS NOT NULL;
CREATE INDEX ixauditoriaeventosrequisicao
  ON auditoriaeventos (cdrequisicao)
  WHERE cdrequisicao IS NOT NULL;

CREATE OR REPLACE FUNCTION fnbloquearalteracaoauditoriaeventos()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE EXCEPTION 'Registros de auditoria são imutáveis.' USING ERRCODE = '23514';
END;
$$;

CREATE TRIGGER trbloquearalteracaoauditoriaeventos
BEFORE UPDATE OR DELETE OR TRUNCATE ON auditoriaeventos
FOR EACH STATEMENT EXECUTE FUNCTION fnbloquearalteracaoauditoriaeventos();

COMMENT ON TABLE auditoriaeventos IS
  'Registro imutável de eventos relevantes do aplicativo.';

COMMIT;
