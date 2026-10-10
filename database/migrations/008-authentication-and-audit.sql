-- Fundação de autenticação e auditoria do LabVet.
-- Inspirada na estrutura do Itriax, sem o conceito de Espaço.
-- Perfis e permissões serão introduzidos em migração própria.

BEGIN;

SET search_path TO labvet, public;

CREATE TABLE IF NOT EXISTS app_users (
  user_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  full_name VARCHAR(150) NOT NULL,
  cpf VARCHAR(14),
  email VARCHAR(150) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  security_version INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,

  CONSTRAINT app_users_security_version_check CHECK (security_version >= 1)
);

CREATE UNIQUE INDEX IF NOT EXISTS app_users_email_unique_idx
  ON app_users (LOWER(email));

CREATE TABLE IF NOT EXISTS user_sessions (
  session_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL,
  refresh_token_hash VARCHAR(64) NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  revoked_at TIMESTAMPTZ,
  security_version INTEGER NOT NULL,

  CONSTRAINT user_sessions_user_fk
    FOREIGN KEY (user_id) REFERENCES app_users(user_id) ON DELETE RESTRICT,
  CONSTRAINT user_sessions_security_version_check CHECK (security_version >= 1)
);

CREATE INDEX IF NOT EXISTS user_sessions_user_idx
  ON user_sessions (user_id);

CREATE UNIQUE INDEX IF NOT EXISTS user_sessions_refresh_token_hash_unique_idx
  ON user_sessions (refresh_token_hash)
  WHERE revoked_at IS NULL;

CREATE TABLE IF NOT EXISTS audit_events (
  audit_event_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  actor_user_id BIGINT,
  event_type VARCHAR(100) NOT NULL,
  resource_type VARCHAR(100) NOT NULL,
  resource_id VARCHAR(100),
  request_id VARCHAR(100),
  details JSONB NOT NULL DEFAULT '{}'::jsonb,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT audit_events_actor_user_fk
    FOREIGN KEY (actor_user_id) REFERENCES app_users(user_id) ON DELETE RESTRICT,
  CONSTRAINT audit_events_event_type_not_blank CHECK (BTRIM(event_type) <> ''),
  CONSTRAINT audit_events_resource_type_not_blank CHECK (BTRIM(resource_type) <> '')
);

CREATE INDEX IF NOT EXISTS audit_events_resource_idx
  ON audit_events (resource_type, resource_id, occurred_at DESC);

CREATE INDEX IF NOT EXISTS audit_events_actor_idx
  ON audit_events (actor_user_id, occurred_at DESC)
  WHERE actor_user_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS audit_events_request_idx
  ON audit_events (request_id)
  WHERE request_id IS NOT NULL;

CREATE OR REPLACE FUNCTION labvet_set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at := statement_timestamp();
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION labvet_block_physical_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE EXCEPTION
    'Exclusão física bloqueada em %. Utilize inativação ou revogação.',
    TG_TABLE_NAME
    USING ERRCODE = '23514';
END;
$$;

CREATE OR REPLACE FUNCTION labvet_block_audit_mutation()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE EXCEPTION
    'Registros de auditoria são imutáveis.'
    USING ERRCODE = '23514';
END;
$$;

DROP TRIGGER IF EXISTS app_users_set_updated_at ON app_users;
CREATE TRIGGER app_users_set_updated_at
  BEFORE UPDATE ON app_users
  FOR EACH ROW EXECUTE FUNCTION labvet_set_updated_at();

DROP TRIGGER IF EXISTS user_sessions_set_updated_at ON user_sessions;
CREATE TRIGGER user_sessions_set_updated_at
  BEFORE UPDATE ON user_sessions
  FOR EACH ROW EXECUTE FUNCTION labvet_set_updated_at();

DROP TRIGGER IF EXISTS app_users_block_delete ON app_users;
CREATE TRIGGER app_users_block_delete
  BEFORE DELETE OR TRUNCATE ON app_users
  FOR EACH STATEMENT EXECUTE FUNCTION labvet_block_physical_delete();

DROP TRIGGER IF EXISTS user_sessions_block_delete ON user_sessions;
CREATE TRIGGER user_sessions_block_delete
  BEFORE DELETE OR TRUNCATE ON user_sessions
  FOR EACH STATEMENT EXECUTE FUNCTION labvet_block_physical_delete();

DROP TRIGGER IF EXISTS audit_events_block_mutation ON audit_events;
CREATE TRIGGER audit_events_block_mutation
  BEFORE UPDATE OR DELETE OR TRUNCATE ON audit_events
  FOR EACH STATEMENT EXECUTE FUNCTION labvet_block_audit_mutation();

COMMIT;
