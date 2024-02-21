-- is_master_table=false

-- 3.受注明細(order_details)

-- Create Table
DROP TABLE IF EXISTS received_order.order_details CASCADE;
CREATE TABLE received_order.order_details (
  received_order_no varchar(10) NOT NULL check (LENGTH(received_order_no) = 10),
  product_no varchar(10) NOT NULL check (LENGTH(product_no) >= 9),
  quantity integer check (0 <= quantity AND quantity <= 99999),
  price integer check (price >= 0),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE received_order.order_details IS '受注明細';

-- Set Column Comment
COMMENT ON COLUMN received_order.order_details.received_order_no IS '受注No';
COMMENT ON COLUMN received_order.order_details.product_no IS '商品No';
COMMENT ON COLUMN received_order.order_details.quantity IS '数量';
COMMENT ON COLUMN received_order.order_details.price IS '定価';
COMMENT ON COLUMN received_order.order_details.created_at IS '作成日時';
COMMENT ON COLUMN received_order.order_details.updated_at IS '更新日時';
COMMENT ON COLUMN received_order.order_details.created_by IS '作成者';
COMMENT ON COLUMN received_order.order_details.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE received_order.order_details ADD PRIMARY KEY (
  received_order_no,
  product_no
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON received_order.order_details
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS received_order.order_details_audit();
CREATE OR REPLACE FUNCTION received_order.order_details_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.received_order_no || '-' || OLD.product_no;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.received_order_no || '-' || NEW.product_no;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.received_order_no || '-' || NEW.product_no;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON received_order.order_details
  FOR EACH ROW
EXECUTE PROCEDURE received_order.order_details_audit();
