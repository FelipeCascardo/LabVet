-- LabVet V1 — usuário como especialização de pessoa.
-- Aplicar após 002_autenticacao.sql somente quando não houver usuários.

BEGIN;

SET search_path TO labvet, public;

ALTER TABLE usuario
  ADD COLUMN idpessoa BIGINT;

ALTER TABLE usuario
  ADD CONSTRAINT fkusuariopessoa FOREIGN KEY (idpessoa)
    REFERENCES pessoa (idpessoa) ON DELETE RESTRICT,
  ADD CONSTRAINT uxusuariopessoa UNIQUE (idpessoa);

ALTER TABLE usuario
  ALTER COLUMN idpessoa SET NOT NULL,
  DROP COLUMN nmusuario,
  DROP COLUMN nrcpf;

COMMENT ON COLUMN usuario.idpessoa IS
  'Pessoa da qual o usuário é uma especialização, em relação obrigatória 1:1.';

COMMIT;
