-- is_master_table=false

-- 1.担当者(operators)

-- Create Table
DROP TABLE IF EXISTS received_order.operators CASCADE;
CREATE TABLE received_order.operators (
  operator_id varchar(5) NOT NULL check (LENGTH(operator_id) = 5),
  operator_name varchar(30) NOT NULL,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE received_order.operators IS '担当者';

-- Set Column Comment
COMMENT ON COLUMN received_order.operators.operator_id IS '担当者ID';
COMMENT ON COLUMN received_order.operators.operator_name IS '担当者名';
COMMENT ON COLUMN received_order.operators.created_at IS '作成日時';
COMMENT ON COLUMN received_order.operators.updated_at IS '更新日時';
COMMENT ON COLUMN received_order.operators.created_by IS '作成者';
COMMENT ON COLUMN received_order.operators.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE received_order.operators ADD PRIMARY KEY (
  operator_id
);

-- Set Unique Constraint
ALTER TABLE received_order.operators ADD CONSTRAINT operators_unique_1 UNIQUE (
  operator_name
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON received_order.operators
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS received_order.operators_audit();
CREATE OR REPLACE FUNCTION received_order.operators_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.operator_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.operator_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.operator_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON received_order.operators
  FOR EACH ROW
EXECUTE PROCEDURE received_order.operators_audit();
