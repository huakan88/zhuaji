CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  phone TEXT UNIQUE,
  wechat_open_id TEXT UNIQUE,
  created_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE IF NOT EXISTS phone_codes (
  phone TEXT PRIMARY KEY,
  code TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE IF NOT EXISTS records (
  user_id TEXT NOT NULL REFERENCES users(id),
  entity TEXT NOT NULL,
  record_id TEXT NOT NULL,
  payload TEXT NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  deleted_at TIMESTAMPTZ,
  device_id TEXT NOT NULL,
  PRIMARY KEY (user_id, entity, record_id)
);

CREATE TABLE IF NOT EXISTS push_tokens (
  user_id TEXT NOT NULL REFERENCES users(id),
  vendor TEXT NOT NULL,
  token TEXT NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY (user_id, vendor, token)
);
