-- is_master_table=true

-- 9.得意先06(custom06)

-- Create Table
DROP TABLE IF EXISTS received_order.custom06 CASCADE;
CREATE TABLE received_order.custom06 (
  customer_id varchar(3) NOT NULL check (LENGTH(customer_id) = 3),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE received_order.custom06 IS '得意先06';

-- Set Column Comment
COMMENT ON COLUMN received_order.custom06.customer_id IS '得意先ID';
COMMENT ON COLUMN received_order.custom06.created_at IS '作成日時';
COMMENT ON COLUMN received_order.custom06.updated_at IS '更新日時';
COMMENT ON COLUMN received_order.custom06.created_by IS '作成者';
COMMENT ON COLUMN received_order.custom06.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE received_order.custom06 ADD PRIMARY KEY (
  customer_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON received_order.custom06
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS received_order.custom06_audit();
CREATE OR REPLACE FUNCTION received_order.custom06_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.customer_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.customer_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.customer_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON received_order.custom06
  FOR EACH ROW
EXECUTE PROCEDURE received_order.custom06_audit();
