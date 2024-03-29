-- 更新区分
DROP TYPE IF EXISTS operation_type;
CREATE TYPE operation_type AS enum (
  'INSERT',
  'UPDATE',
  'DELETE'
);

-- オペレーション履歴
DROP TABLE IF EXISTS operation_histories CASCADE;
CREATE TABLE operation_histories (
  operated_at timestamp NOT NULL DEFAULT current_timestamp,
  operated_by varchar(58),
  schema_name text NOT NULL,
  table_name text NOT NULL,
  operation_type operation_type NOT NULL,
  table_key text NOT NULL
);

-- 更新日時の設定
DROP FUNCTION IF EXISTS set_updated_at();
CREATE FUNCTION set_updated_at() RETURNS TRIGGER AS $$
BEGIN
  -- 更新日時
  NEW.updated_at := now();
  return NEW;
END;
$$ LANGUAGE plpgsql;
