-- LabVet — proposta de esquema alinhada aos padrões do Itriax
--
-- Este arquivo é SOMENTE PARA REVISÃO. Não é carregado automaticamente pelo
-- Docker Compose e não altera nenhuma base existente.
--
-- Convenções verificadas no Itriax:
--   id...  BIGINT       identificador e chave estrangeira
--   nm...  VARCHAR      nome
--   ds...  VARCHAR/TEXT descrição, texto livre ou conteúdo extraído
--   cd...  VARCHAR      código externo, chave de negócio ou hash
--   nr...  INTEGER      número sequencial ou número de registro
--   qt...  INTEGER      quantidade
--   vl...  NUMERIC      valor monetário ou medida numérica
--   dt...  DATE         data de negócio
--   dh...  TIMESTAMPTZ  data e hora de auditoria
--   tp...  SMALLINT     tipo/categoria codificada
--   st...  BOOLEAN      situação/indicador
--
-- Decisão deliberada: as chaves usam BIGINT sem DEFAULT, como no Itriax.
-- O backend será responsável por fornecer os identificadores, preservando a
-- compatibilidade com esse padrão e permitindo importações com IDs definidos.

CREATE SCHEMA IF NOT EXISTS labvet;
SET search_path TO labvet, public;

-- Atualiza a data/hora de alteração, no mesmo padrão de auditoria do Itriax.
CREATE OR REPLACE FUNCTION fn_atualizar_dhalteracao()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.dhalteracao = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;

CREATE TABLE owners (
  idproprietario BIGINT PRIMARY KEY,
  cdchaveorigem VARCHAR(255) NOT NULL,
  nmproprietario VARCHAR(200) NOT NULL,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_owners_cdchaveorigem UNIQUE (cdchaveorigem)
);

CREATE TABLE animals (
  idanimal BIGINT PRIMARY KEY,
  cdanimalexterno VARCHAR(100),
  cdchaveorigem VARCHAR(255) NOT NULL,
  nmanimal VARCHAR(150) NOT NULL,
  dsespecie VARCHAR(50),
  dsraca VARCHAR(100),
  tpsexo SMALLINT NOT NULL DEFAULT 9,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT ck_animals_tpsexo CHECK (tpsexo IN (0, 1, 2, 9)),
  CONSTRAINT uq_animals_cdchaveorigem UNIQUE (cdchaveorigem)
);

CREATE TABLE animal_owners (
  idanimalproprietario BIGINT PRIMARY KEY,
  idanimal BIGINT NOT NULL,
  idproprietario BIGINT NOT NULL,
  statual BOOLEAN NOT NULL DEFAULT true,
  dtinicio DATE,
  dtfim DATE,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_animalowners_animal FOREIGN KEY (idanimal)
    REFERENCES animals (idanimal),
  CONSTRAINT fk_animalowners_proprietario FOREIGN KEY (idproprietario)
    REFERENCES owners (idproprietario),
  CONSTRAINT uq_animalowners_vinculo UNIQUE (idanimal, idproprietario),
  CONSTRAINT ck_animalowners_periodo CHECK (
    dtfim IS NULL OR dtinicio IS NULL OR dtfim >= dtinicio
  )
);

CREATE UNIQUE INDEX ix_animalowners_animal_atual
  ON animal_owners (idanimal) WHERE statual;

CREATE TABLE sectors (
  idsetor BIGINT PRIMARY KEY,
  nmsetor VARCHAR(100) NOT NULL,
  dssetornormalizado VARCHAR(100) NOT NULL,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_sectors_dssetornormalizado UNIQUE (dssetornormalizado)
);

CREATE TABLE exams (
  idexame BIGINT PRIMARY KEY,
  cdexame VARCHAR(50) NOT NULL,
  nmexame VARCHAR(200),
  stativo BOOLEAN NOT NULL DEFAULT true,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_exams_cdexame UNIQUE (cdexame)
);

CREATE TABLE import_batches (
  idimportlote BIGINT PRIMARY KEY,
  nmarquivo VARCHAR(255) NOT NULL,
  dtcompetencia DATE,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dsobservacao VARCHAR(1000)
);

CREATE TABLE attendances (
  idatendimento BIGINT PRIMARY KEY,
  nratendimento BIGINT NOT NULL,
  tporigem SMALLINT NOT NULL,
  dtatendimento DATE NOT NULL,
  idanimal BIGINT,
  idsetor BIGINT,
  idimportlote BIGINT,
  dsidade VARCHAR(50),
  dshistoricoclinico TEXT,
  vltotalexame NUMERIC(18,2),
  vlcobrado NUMERIC(18,2),
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_attendances_animal FOREIGN KEY (idanimal)
    REFERENCES animals (idanimal),
  CONSTRAINT fk_attendances_setor FOREIGN KEY (idsetor)
    REFERENCES sectors (idsetor),
  CONSTRAINT fk_attendances_importlote FOREIGN KEY (idimportlote)
    REFERENCES import_batches (idimportlote),
  CONSTRAINT uq_attendances_origem_numero UNIQUE (tporigem, nratendimento),
  CONSTRAINT ck_attendances_tporigem CHECK (tporigem IN (1, 2)),
  CONSTRAINT ck_attendances_vltotalexame CHECK (
    vltotalexame IS NULL OR vltotalexame >= 0
  ),
  CONSTRAINT ck_attendances_vlcobrado CHECK (vlcobrado IS NULL OR vlcobrado >= 0)
);

CREATE TABLE attendance_exams (
  idatendimentoexame BIGINT PRIMARY KEY,
  idatendimento BIGINT NOT NULL,
  idexame BIGINT NOT NULL,
  qtexame INTEGER NOT NULL DEFAULT 1,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_attendanceexams_atendimento FOREIGN KEY (idatendimento)
    REFERENCES attendances (idatendimento) ON DELETE CASCADE,
  CONSTRAINT fk_attendanceexams_exame FOREIGN KEY (idexame)
    REFERENCES exams (idexame),
  CONSTRAINT uq_attendanceexams_vinculo UNIQUE (idatendimento, idexame),
  CONSTRAINT ck_attendanceexams_qtexame CHECK (qtexame > 0)
);

CREATE TABLE lab_report_types (
  idtipolaudo BIGINT PRIMARY KEY,
  cdtipolaudo VARCHAR(30) NOT NULL,
  nmtipolaudo VARCHAR(150) NOT NULL,
  dstipolaudo VARCHAR(500),
  stativo BOOLEAN NOT NULL DEFAULT true,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_labreporttypes_cdtipolaudo UNIQUE (cdtipolaudo)
);

CREATE TABLE laboratory_reports (
  idlaudo BIGINT PRIMARY KEY,
  idatendimento BIGINT NOT NULL,
  idtipolaudo BIGINT NOT NULL,
  nmarquivo VARCHAR(255) NOT NULL,
  dscaminhoarquivo VARCHAR(500) NOT NULL,
  tporigem SMALLINT NOT NULL,
  nratendimento BIGINT NOT NULL,
  nranolaudo SMALLINT NOT NULL,
  dhlaudo TIMESTAMPTZ,
  dstipoamostra VARCHAR(150),
  nmkit VARCHAR(150),
  dsmetodo VARCHAR(500),
  nmanimalinformado VARCHAR(150),
  cdanimalinformado VARCHAR(100),
  dsespecieinformada VARCHAR(50),
  dsracainformada VARCHAR(100),
  dssexoinformado VARCHAR(30),
  dsidadeinformada VARCHAR(50),
  nmproprietarioinformado VARCHAR(200),
  nmveterinarioinformado VARCHAR(200),
  cdcrmvveterinario VARCHAR(50),
  cdhasharquivo VARCHAR(128),
  tpextracao SMALLINT NOT NULL DEFAULT 1,
  dslaudobruto TEXT,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_laboratoryreports_atendimento FOREIGN KEY (idatendimento)
    REFERENCES attendances (idatendimento),
  CONSTRAINT fk_laboratoryreports_tipolaudo FOREIGN KEY (idtipolaudo)
    REFERENCES lab_report_types (idtipolaudo),
  CONSTRAINT uq_laboratoryreports_nmarquivo UNIQUE (nmarquivo),
  CONSTRAINT ck_laboratoryreports_tporigem CHECK (tporigem IN (1, 2)),
  CONSTRAINT ck_laboratoryreports_nranolaudo CHECK (nranolaudo BETWEEN 2000 AND 2100),
  CONSTRAINT ck_laboratoryreports_tpextracao CHECK (tpextracao IN (1, 2, 3, 4)),
  CONSTRAINT ck_laboratoryreports_nratendimento CHECK (nratendimento > 0)
);

CREATE TABLE lab_report_exams (
  idlaudoexame BIGINT PRIMARY KEY,
  idlaudo BIGINT NOT NULL,
  idexame BIGINT NOT NULL,
  stprincipal BOOLEAN NOT NULL DEFAULT false,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_labreportexams_laudo FOREIGN KEY (idlaudo)
    REFERENCES laboratory_reports (idlaudo) ON DELETE CASCADE,
  CONSTRAINT fk_labreportexams_exame FOREIGN KEY (idexame)
    REFERENCES exams (idexame),
  CONSTRAINT uq_labreportexams_vinculo UNIQUE (idlaudo, idexame)
);

CREATE UNIQUE INDEX ix_labreportexams_laudo_principal
  ON lab_report_exams (idlaudo) WHERE stprincipal;

CREATE TABLE lab_analytes (
  idanalito BIGINT PRIMARY KEY,
  cdanalito VARCHAR(100) NOT NULL,
  nmanalito VARCHAR(200) NOT NULL,
  dsunidadepadrao VARCHAR(50),
  tpvalor SMALLINT NOT NULL DEFAULT 3,
  stativo BOOLEAN NOT NULL DEFAULT true,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_labanalytes_cdanalito UNIQUE (cdanalito),
  CONSTRAINT ck_labanalytes_tpvalor CHECK (tpvalor IN (1, 2, 3))
);

CREATE TABLE laboratory_results (
  idresultado BIGINT PRIMARY KEY,
  idlaudo BIGINT NOT NULL,
  idanalito BIGINT NOT NULL,
  dssecao VARCHAR(150) NOT NULL,
  nrexibicao SMALLINT NOT NULL,
  vlresultado NUMERIC(18,6),
  dsresultado TEXT,
  dsunidade VARCHAR(50),
  vlreferenciainicial NUMERIC(18,6),
  vlreferenciafinal NUMERIC(18,6),
  dsreferencia VARCHAR(500),
  dsmetodo VARCHAR(500),
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_laboratoryresults_laudo FOREIGN KEY (idlaudo)
    REFERENCES laboratory_reports (idlaudo) ON DELETE CASCADE,
  CONSTRAINT fk_laboratoryresults_analito FOREIGN KEY (idanalito)
    REFERENCES lab_analytes (idanalito),
  CONSTRAINT uq_laboratoryresults_item UNIQUE (idlaudo, idanalito, dssecao),
  CONSTRAINT ck_laboratoryresults_nrexibicao CHECK (nrexibicao > 0),
  CONSTRAINT ck_laboratoryresults_valor CHECK (
    vlresultado IS NOT NULL OR dsresultado IS NOT NULL
  )
);

CREATE TABLE laboratory_report_notes (
  idlaudoobservacao BIGINT PRIMARY KEY,
  idlaudo BIGINT NOT NULL,
  tpobservacao SMALLINT NOT NULL,
  nrexibicao SMALLINT NOT NULL DEFAULT 1,
  dsobservacao TEXT NOT NULL,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_laboratoryreportnotes_laudo FOREIGN KEY (idlaudo)
    REFERENCES laboratory_reports (idlaudo) ON DELETE CASCADE,
  CONSTRAINT ck_laboratoryreportnotes_tpobservacao CHECK (tpobservacao IN (1, 2, 3, 4)),
  CONSTRAINT ck_laboratoryreportnotes_nrexibicao CHECK (nrexibicao > 0)
);

-- Índices de consulta.
CREATE INDEX ix_animals_cdanimalexterno ON animals (cdanimalexterno);
CREATE INDEX ix_attendances_dtatendimento ON attendances (dtatendimento);
CREATE INDEX ix_attendances_animal ON attendances (idanimal);
CREATE INDEX ix_attendances_setor ON attendances (idsetor);
CREATE INDEX ix_laboratoryreports_atendimento ON laboratory_reports (idatendimento);
CREATE INDEX ix_laboratoryreports_tipolaudo ON laboratory_reports (idtipolaudo);
CREATE INDEX ix_laboratoryreports_origem_atendimento
  ON laboratory_reports (tporigem, nratendimento);
CREATE INDEX ix_laboratoryresults_laudo_exibicao
  ON laboratory_results (idlaudo, nrexibicao);
CREATE INDEX ix_laboratoryresults_analito ON laboratory_results (idanalito);
CREATE INDEX ix_laboratoryreportnotes_laudo_exibicao
  ON laboratory_report_notes (idlaudo, nrexibicao);

-- Auditoria automática, seguindo o nome de função e o comportamento do Itriax.
CREATE TRIGGER tr_owners_dhalteracao BEFORE UPDATE ON owners
FOR EACH ROW EXECUTE FUNCTION fn_atualizar_dhalteracao();
CREATE TRIGGER tr_animals_dhalteracao BEFORE UPDATE ON animals
FOR EACH ROW EXECUTE FUNCTION fn_atualizar_dhalteracao();
CREATE TRIGGER tr_animalowners_dhalteracao BEFORE UPDATE ON animal_owners
FOR EACH ROW EXECUTE FUNCTION fn_atualizar_dhalteracao();
CREATE TRIGGER tr_sectors_dhalteracao BEFORE UPDATE ON sectors
FOR EACH ROW EXECUTE FUNCTION fn_atualizar_dhalteracao();
CREATE TRIGGER tr_exams_dhalteracao BEFORE UPDATE ON exams
FOR EACH ROW EXECUTE FUNCTION fn_atualizar_dhalteracao();
CREATE TRIGGER tr_attendances_dhalteracao BEFORE UPDATE ON attendances
FOR EACH ROW EXECUTE FUNCTION fn_atualizar_dhalteracao();
CREATE TRIGGER tr_attendanceexams_dhalteracao BEFORE UPDATE ON attendance_exams
FOR EACH ROW EXECUTE FUNCTION fn_atualizar_dhalteracao();
CREATE TRIGGER tr_labreporttypes_dhalteracao BEFORE UPDATE ON lab_report_types
FOR EACH ROW EXECUTE FUNCTION fn_atualizar_dhalteracao();
CREATE TRIGGER tr_laboratoryreports_dhalteracao BEFORE UPDATE ON laboratory_reports
FOR EACH ROW EXECUTE FUNCTION fn_atualizar_dhalteracao();
CREATE TRIGGER tr_labreportexams_dhalteracao BEFORE UPDATE ON lab_report_exams
FOR EACH ROW EXECUTE FUNCTION fn_atualizar_dhalteracao();
CREATE TRIGGER tr_labanalytes_dhalteracao BEFORE UPDATE ON lab_analytes
FOR EACH ROW EXECUTE FUNCTION fn_atualizar_dhalteracao();
CREATE TRIGGER tr_laboratoryresults_dhalteracao BEFORE UPDATE ON laboratory_results
FOR EACH ROW EXECUTE FUNCTION fn_atualizar_dhalteracao();
CREATE TRIGGER tr_laboratoryreportnotes_dhalteracao BEFORE UPDATE ON laboratory_report_notes
FOR EACH ROW EXECUTE FUNCTION fn_atualizar_dhalteracao();

COMMENT ON SCHEMA labvet IS 'Esquema LabVet com convenções de campos alinhadas ao Itriax.';
COMMENT ON COLUMN animals.tpsexo IS '0: não informado; 1: macho; 2: fêmea; 9: indefinido.';
COMMENT ON COLUMN attendances.tporigem IS '1: HV; 2: AMA.';
COMMENT ON COLUMN laboratory_reports.tpextracao IS '1: pendente; 2: extraído; 3: revisado; 4: falhou.';
COMMENT ON COLUMN lab_analytes.tpvalor IS '1: numérico; 2: texto; 3: misto.';
COMMENT ON COLUMN laboratory_report_notes.tpobservacao IS '1: observação; 2: achado; 3: fonte de referência; 4: outro.';
