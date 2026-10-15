-- Labvet V1 — rascunho inicial das tabelas de realização de exames.
-- NÃO APLICAR antes da revisão funcional dos campos de paciente, atendimento,
-- coleta, execução, emissão e responsáveis técnicos.
-- Baseado em modeloexames e modeloexameanalitos, com chaves próprias de laudo.

BEGIN;

SET search_path TO labvet, public;

CREATE TABLE laudos (
  idlaudo BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  idmodeloexame BIGINT,
  cdlaudo VARCHAR(100) NOT NULL,
  nmlaudo VARCHAR(250) NOT NULL,
  dsidade VARCHAR(20),
  nmarquivoorigem VARCHAR(200),
  stativo BOOLEAN NOT NULL DEFAULT true,
  idusuarioinclusao BIGINT,
  idusuarioalteracao BIGINT,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uqlaudoscodigo UNIQUE (cdlaudo),
  CONSTRAINT fklaudosexame FOREIGN KEY (idexame)
    REFERENCES exames (idexame) ON DELETE RESTRICT,
  CONSTRAINT fklaudosanimalgrupo FOREIGN KEY (idanimalgrupo)
    REFERENCES animalgrupos (idanimalgrupo) ON DELETE RESTRICT,
  CONSTRAINT fklaudosusuarioinclusao FOREIGN KEY (idusuarioinclusao)
    REFERENCES usuario (idusuario) ON DELETE RESTRICT,
  CONSTRAINT fklaudosusuarioalteracao FOREIGN KEY (idusuarioalteracao)
    REFERENCES usuario (idusuario) ON DELETE RESTRICT,
  CONSTRAINT cklaudoscodigo CHECK (BTRIM(cdlaudo) <> ''),
  CONSTRAINT cklaudosnome CHECK (BTRIM(nmlaudo) <> ''),
  CONSTRAINT cklaudosfaixaidade CHECK (
    dsfaixaidade IS NULL
    OR BTRIM(dsfaixaidade) <> ''
  )
);

CREATE INDEX ixlaudosexame ON laudos (idexame);
CREATE INDEX ixlaudosanimalgrupo ON laudos (idanimalgrupo);

CREATE TABLE laudoanalitos (
  idlaudoanalito BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  idlaudo BIGINT NOT NULL,
  idexameanalito BIGINT NOT NULL,
  dssecao VARCHAR(150),
  nrexibicao INTEGER NOT NULL,
  dsrotulo VARCHAR(250),
  dstecnica VARCHAR(250),
  dsunidademedida VARCHAR(50),
  dsreferencia TEXT,
  vrrefminimo VARCHAR(100),
  vrrefmaximo VARCHAR(100),
  vrrefperminimo NUMERIC(7, 4),
  vrrefpermaximo NUMERIC(7, 4),
  stativo BOOLEAN NOT NULL DEFAULT true,
  idusuarioinclusao BIGINT,
  idusuarioalteracao BIGINT,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fklaudoanalitoslaudo FOREIGN KEY (idlaudo)
    REFERENCES laudos (idlaudo) ON DELETE RESTRICT,
  CONSTRAINT fklaudoanalitosexameanalito FOREIGN KEY (idexameanalito)
    REFERENCES exameanalitos (idexameanalito) ON DELETE RESTRICT,
  CONSTRAINT fklaudoanalitosusuarioinclusao FOREIGN KEY (idusuarioinclusao)
    REFERENCES usuario (idusuario) ON DELETE RESTRICT,
  CONSTRAINT fklaudoanalitosusuarioalteracao FOREIGN KEY (idusuarioalteracao)
    REFERENCES usuario (idusuario) ON DELETE RESTRICT,
  CONSTRAINT uqlaudoanalitosordem UNIQUE (idlaudo, nrexibicao),
  CONSTRAINT cklaudoanalitosordem CHECK (nrexibicao > 0),
  CONSTRAINT cklaudoanalitossecao CHECK (
    dssecao IS NULL
    OR BTRIM(dssecao) <> ''
  ),
  CONSTRAINT cklaudoanalitosreferenciapercentual CHECK (
    (vrrefperminimo IS NULL OR vrrefperminimo BETWEEN 0 AND 100)
    AND (vrrefpermaximo IS NULL OR vrrefpermaximo BETWEEN 0 AND 100)
    AND (
      vrrefperminimo IS NULL
      OR vrrefpermaximo IS NULL
      OR vrrefperminimo <= vrrefpermaximo
    )
  )
);

CREATE INDEX ixlaudoanalitoslaudo ON laudoanalitos (idlaudo);
CREATE INDEX ixlaudoanalitosexameanalito ON laudoanalitos (idexameanalito);

CREATE OR REPLACE FUNCTION labvet.fnvalidarreferenciapercentuallaudoanalito()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  LPermitePercentual BOOLEAN;
BEGIN
  SELECT analito.fgpercentual
  INTO LPermitePercentual
  FROM labvet.exameanalitos exameanalito
  INNER JOIN labvet.analitos analito
    ON analito.idanalito = exameanalito.idanalito
  WHERE exameanalito.idexameanalito = NEW.idexameanalito;

  IF NOT COALESCE(LPermitePercentual, false)
    AND (NEW.vrrefperminimo IS NOT NULL OR NEW.vrrefpermaximo IS NOT NULL) THEN
    RAISE EXCEPTION
      'O analito vinculado não aceita referências percentuais.';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trvalidarreferenciapercentuallaudoanalito
BEFORE INSERT OR UPDATE ON laudoanalitos
FOR EACH ROW EXECUTE FUNCTION labvet.fnvalidarreferenciapercentuallaudoanalito();

CREATE OR REPLACE FUNCTION labvet.fnvalidardesativacaopercentualanalito()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF OLD.fgpercentual
    AND NOT NEW.fgpercentual
    AND (
      EXISTS (
        SELECT 1
        FROM labvet.exameanalitos exameanalito
        INNER JOIN labvet.modeloexameanalitos modeloexameanalito
          ON modeloexameanalito.idexameanalito = exameanalito.idexameanalito
        WHERE exameanalito.idanalito = NEW.idanalito
          AND (
            modeloexameanalito.vrrefperminimo IS NOT NULL
            OR modeloexameanalito.vrrefpermaximo IS NOT NULL
          )
      )
      OR EXISTS (
        SELECT 1
        FROM labvet.exameanalitos exameanalito
        INNER JOIN labvet.laudoanalitos laudoanalito
          ON laudoanalito.idexameanalito = exameanalito.idexameanalito
        WHERE exameanalito.idanalito = NEW.idanalito
          AND (
            laudoanalito.vrrefperminimo IS NOT NULL
            OR laudoanalito.vrrefpermaximo IS NOT NULL
          )
      )
    ) THEN
    RAISE EXCEPTION
      'O analito possui referências percentuais em modelos ou laudos.';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER tratualizarlaudos
BEFORE UPDATE ON laudos
FOR EACH ROW EXECUTE FUNCTION fnatualizardhalteracao();

CREATE TRIGGER tratualizarlaudoanalitos
BEFORE UPDATE ON laudoanalitos
FOR EACH ROW EXECUTE FUNCTION fnatualizardhalteracao();

COMMENT ON TABLE laudos IS
  'Rascunho para a realização de exames e emissão de laudos; pendente de revisão funcional.';
COMMENT ON TABLE laudoanalitos IS
  'Rascunho dos resultados e referências dos analitos realizados em cada laudo.';

COMMIT;
