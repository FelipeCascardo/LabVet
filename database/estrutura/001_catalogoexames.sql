-- LabVet definitivo — módulo de catálogo de exames.
-- Aplicar exclusivamente na base labvet_estrutura.

BEGIN;

CREATE SCHEMA IF NOT EXISTS labvet;
SET search_path TO labvet, public;

CREATE OR REPLACE FUNCTION fnatualizardhalteracao()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.dhalteracao = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;

CREATE TABLE examecategorias (
  idexamecategoria BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nmcategoria VARCHAR(100) NOT NULL,
  stativo BOOLEAN NOT NULL DEFAULT true,
  idusuarioinclusao BIGINT,
  idusuarioalteracao BIGINT,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uqexamecategoriasnome UNIQUE (nmcategoria)
);

CREATE TABLE exames (
  idexame BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  idexamecategoria BIGINT NOT NULL,
  cdexame VARCHAR(50) NOT NULL,
  nmexame VARCHAR(200) NOT NULL,
  qttotalexames INTEGER NOT NULL DEFAULT 1,
  vlexame NUMERIC(18,2),
  stprimario BOOLEAN NOT NULL DEFAULT true,
  idexamepai BIGINT,
  stativo BOOLEAN NOT NULL DEFAULT true,
  idusuarioinclusao BIGINT,
  idusuarioalteracao BIGINT,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fkexamescategoria FOREIGN KEY (idexamecategoria)
    REFERENCES examecategorias (idexamecategoria),
  CONSTRAINT fkexamespai FOREIGN KEY (idexamepai)
    REFERENCES exames (idexame),
  CONSTRAINT uqexamescodigo UNIQUE (cdexame),
  CONSTRAINT ckexamesquantidade CHECK (qttotalexames > 0),
  CONSTRAINT ckexamesvalor CHECK (vlexame IS NULL OR vlexame >= 0)
);

CREATE INDEX ixexamescategoria ON exames (idexamecategoria);
CREATE INDEX ixexamespai ON exames (idexamepai);

CREATE TRIGGER tratualizarexamecategorias
BEFORE UPDATE ON examecategorias
FOR EACH ROW EXECUTE FUNCTION fnatualizardhalteracao();

CREATE TRIGGER tratualizarexames
BEFORE UPDATE ON exames
FOR EACH ROW EXECUTE FUNCTION fnatualizardhalteracao();

COMMENT ON TABLE examecategorias IS
  'Categorias operacionais do catálogo de exames.';
COMMENT ON TABLE exames IS
  'Exames unitários e pacotes do catálogo operacional do LabVet.';
COMMENT ON COLUMN exames.qttotalexames IS
  'Quantidade de exames representada pelo item do catálogo.';
COMMENT ON COLUMN exames.stprimario IS
  'True para exame unitário; false para pacote.';
COMMENT ON COLUMN exames.idexamepai IS
  'Relação hierárquica temporária de pacote; composição definitiva exigirá tabela associativa.';

-- Cadastros compartilhados, baseados na estrutura vigente do Itriax.
CREATE TABLE pessoaatividade (
  idpessoaatividade BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  dspessoaatividade VARCHAR(100) NOT NULL,
  CONSTRAINT uqpessoaatividadedescricao UNIQUE (dspessoaatividade),
  CONSTRAINT ckpessoaatividadedescricao CHECK (BTRIM(dspessoaatividade) <> '')
);

CREATE TABLE pessoa (
  idpessoa BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nmpessoa VARCHAR(150) NOT NULL,
  tppessoa SMALLINT NOT NULL,
  nrpessoa VARCHAR(18),
  idpessoaatividade BIGINT,
  dslogradouro VARCHAR(150),
  nrendereco VARCHAR(20),
  dscomplemento VARCHAR(100),
  dsbairro VARCHAR(100),
  dscidade VARCHAR(100),
  sguf VARCHAR(2),
  nrcep VARCHAR(8),
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  stativo BOOLEAN NOT NULL DEFAULT true,
  CONSTRAINT ckpessoatppessoa CHECK (tppessoa IN (1, 2)),
  CONSTRAINT ckpessoanrpessoa CHECK (
    nrpessoa IS NULL
    OR (
      tppessoa = 1
      AND CHAR_LENGTH(nrpessoa) = 14
      AND nrpessoa ~ '^[0-9]{3}[.][0-9]{3}[.][0-9]{3}-[0-9]{2}$'
    )
    OR (
      tppessoa = 2
      AND CHAR_LENGTH(nrpessoa) = 18
      AND nrpessoa ~ '^[A-Z0-9]{2}[.][A-Z0-9]{3}[.][A-Z0-9]{3}/[A-Z0-9]{4}-[0-9]{2}$'
    )
  ),
  CONSTRAINT uqpessoadocumento UNIQUE (nrpessoa),
  CONSTRAINT fkpessoaatividade FOREIGN KEY (idpessoaatividade)
    REFERENCES pessoaatividade (idpessoaatividade) ON DELETE RESTRICT,
  CONSTRAINT ckpessoauf CHECK (sguf IS NULL OR sguf ~ '^[A-Z]{2}$'),
  CONSTRAINT ckpessoacep CHECK (nrcep IS NULL OR nrcep ~ '^[0-9]{8}$')
);

CREATE INDEX ixpessoaatividade ON pessoa (idpessoaatividade)
  WHERE idpessoaatividade IS NOT NULL;

CREATE TABLE usuario (
  idusuario BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  idpessoa BIGINT NOT NULL,
  dsemail VARCHAR(50) NOT NULL,
  dssenhahash VARCHAR(128) NOT NULL,
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  stativo BOOLEAN NOT NULL DEFAULT true,
  CONSTRAINT fkusuariopessoa FOREIGN KEY (idpessoa)
    REFERENCES pessoa (idpessoa) ON DELETE RESTRICT,
  CONSTRAINT uxusuariopessoa UNIQUE (idpessoa)
);

CREATE UNIQUE INDEX uxusuariodsemail ON usuario (LOWER(dsemail));

CREATE TABLE tipocontato (
  idtipocontato BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  dstipocontato VARCHAR(100) NOT NULL,
  dsurlbase VARCHAR(250),
  CONSTRAINT uqtipocontatodescricao UNIQUE (dstipocontato),
  CONSTRAINT cktipocontatodescricao CHECK (BTRIM(dstipocontato) <> ''),
  CONSTRAINT cktipocontatourlbase CHECK (dsurlbase IS NULL OR BTRIM(dsurlbase) <> '')
);

CREATE TABLE pessoacontato (
  idpessoacontato BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  idpessoa BIGINT NOT NULL,
  idtipocontato BIGINT NOT NULL,
  dscontato VARCHAR(250) NOT NULL,
  dsrotulo VARCHAR(100),
  dhinclusao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dhalteracao TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  stativo BOOLEAN NOT NULL DEFAULT true,
  CONSTRAINT fkpessoacontatopessoa FOREIGN KEY (idpessoa)
    REFERENCES pessoa (idpessoa) ON DELETE RESTRICT,
  CONSTRAINT fkpessoacontatotipocontato FOREIGN KEY (idtipocontato)
    REFERENCES tipocontato (idtipocontato) ON DELETE RESTRICT,
  CONSTRAINT ckpessoacontatovalor CHECK (BTRIM(dscontato) <> '')
);

CREATE UNIQUE INDEX uxpessoacontatoativo
  ON pessoacontato (idpessoa, idtipocontato, LOWER(dscontato))
  WHERE stativo = true;
CREATE INDEX ixpessoacontatopessoa ON pessoacontato (idpessoa);
CREATE INDEX ixpessoacontatotipo ON pessoacontato (idtipocontato);

CREATE TRIGGER tratualizarusuario
BEFORE UPDATE ON usuario
FOR EACH ROW EXECUTE FUNCTION fnatualizardhalteracao();

CREATE TRIGGER tratualizarpessoa
BEFORE UPDATE ON pessoa
FOR EACH ROW EXECUTE FUNCTION fnatualizardhalteracao();

CREATE TRIGGER tratualizarpessoacontato
BEFORE UPDATE ON pessoacontato
FOR EACH ROW EXECUTE FUNCTION fnatualizardhalteracao();

COMMENT ON TABLE usuario IS
  'Usuários do aplicativo, conforme estrutura de autenticação do Itriax.';
COMMENT ON TABLE pessoa IS
  'Cadastro compartilhado de pessoas físicas e jurídicas.';
COMMENT ON TABLE pessoaatividade IS
  'Atividades econômicas ou institucionais associáveis a pessoas.';
COMMENT ON TABLE tipocontato IS
  'Tipos padronizados de contato de uma pessoa.';
COMMENT ON TABLE pessoacontato IS
  'Canais de contato ativos ou inativos de uma pessoa.';

COMMIT;
