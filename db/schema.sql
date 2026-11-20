-- ARIA v4.2 schema reference. server.js also creates/updates these tables at startup.
-- Run only if you want to inspect or provision the schema manually.

CREATE TABLE IF NOT EXISTS aria_users (
  id uuid PRIMARY KEY,
  email text NOT NULL UNIQUE,
  display_name text NOT NULL,
  password_hash text NOT NULL,
  role text NOT NULL DEFAULT 'member' CHECK (role IN ('admin','member')),
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active','suspended')),
  daily_ai_limit integer NOT NULL DEFAULT 20 CHECK (daily_ai_limit BETWEEN 1 AND 500),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS aria_invites (
  id uuid PRIMARY KEY,
  code_hash text NOT NULL UNIQUE,
  created_by uuid NOT NULL REFERENCES aria_users(id) ON DELETE CASCADE,
  max_uses integer NOT NULL DEFAULT 1 CHECK (max_uses BETWEEN 1 AND 20),
  used_count integer NOT NULL DEFAULT 0,
  daily_ai_limit integer NOT NULL DEFAULT 20 CHECK (daily_ai_limit BETWEEN 1 AND 200),
  expires_at timestamptz NOT NULL,
  revoked boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS aria_sessions (
  token_hash text PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES aria_users(id) ON DELETE CASCADE,
  expires_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS aria_sessions_user_idx ON aria_sessions(user_id);

CREATE TABLE IF NOT EXISTS aria_user_data (
  user_id uuid PRIMARY KEY REFERENCES aria_users(id) ON DELETE CASCADE,
  payload jsonb NOT NULL DEFAULT '{"logs":[],"holidays":[]}'::jsonb,
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS aria_usage_daily (
  user_id uuid NOT NULL REFERENCES aria_users(id) ON DELETE CASCADE,
  usage_date date NOT NULL,
  requests integer NOT NULL DEFAULT 0,
  input_tokens integer NOT NULL DEFAULT 0,
  output_tokens integer NOT NULL DEFAULT 0,
  PRIMARY KEY (user_id, usage_date)
);

CREATE TABLE IF NOT EXISTS aria_global_usage_daily (
  usage_date date PRIMARY KEY,
  requests integer NOT NULL DEFAULT 0,
  api_calls integer NOT NULL DEFAULT 0,
  input_tokens bigint NOT NULL DEFAULT 0,
  output_tokens bigint NOT NULL DEFAULT 0
);
ALTER TABLE aria_global_usage_daily ADD COLUMN IF NOT EXISTS api_calls integer NOT NULL DEFAULT 0;
