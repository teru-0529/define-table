-- is_master_table=false

-- 2.受注(orders)

-- Create Table
DROP TABLE IF EXISTS received_order.orders CASCADE;
CREATE TABLE received_order.orders (
  received_order_no varchar(10) NOT NULL check (LENGTH(received_order_no) = 10),
  order_date date NOT NULL,
  person_in_charge varchar(30),
  customer_id varchar(3) NOT NULL check (LENGTH(customer_id) = 3),
  comment text check (LENGTH(comment) >= 10),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE received_order.orders IS '受注';

-- Set Column Comment
COMMENT ON COLUMN received_order.orders.received_order_no IS '受注No';
COMMENT ON COLUMN received_order.orders.order_date IS '受注日';
COMMENT ON COLUMN received_order.orders.person_in_charge IS '担当者名';
COMMENT ON COLUMN received_order.orders.customer_id IS '得意先ID';
COMMENT ON COLUMN received_order.orders.comment IS 'コメント';
COMMENT ON COLUMN received_order.orders.created_at IS '作成日時';
COMMENT ON COLUMN received_order.orders.updated_at IS '更新日時';
COMMENT ON COLUMN received_order.orders.created_by IS '作成者';
COMMENT ON COLUMN received_order.orders.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE received_order.orders ADD PRIMARY KEY (
  received_order_no
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON received_order.orders
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS received_order.orders_audit();
CREATE OR REPLACE FUNCTION received_order.orders_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.received_order_no;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.received_order_no;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.received_order_no;
  ENDIF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON received_order.orders
  FOR EACH ROW
EXECUTE PROCEDURE received_order.orders_audit();
