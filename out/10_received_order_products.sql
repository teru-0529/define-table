-- is_master_table=false

-- 2.商品(products)

-- Create Table
DROP TABLE IF EXISTS received_order.products CASCADE;
CREATE TABLE received_order.products (
  product_name varchar(30) NOT NULL,
  cost_price integer NOT NULL check (cost_price >= 0),
  w_product_id varchar(5) NOT NULL check (w_product_id ~* '^P[0-9]{4}$'),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE received_order.products IS '商品';

-- Set Column Comment
COMMENT ON COLUMN received_order.products.product_name IS '商品名';
COMMENT ON COLUMN received_order.products.cost_price IS '商品原価';
COMMENT ON COLUMN received_order.products.w_product_id IS '商品ID(WORK)';
COMMENT ON COLUMN received_order.products.created_at IS '作成日時';
COMMENT ON COLUMN received_order.products.updated_at IS '更新日時';
COMMENT ON COLUMN received_order.products.created_by IS '作成者';
COMMENT ON COLUMN received_order.products.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE received_order.products ADD PRIMARY KEY (
  product_name
);

-- Set Unique Constraint
ALTER TABLE received_order.products ADD CONSTRAINT products_unique_1 UNIQUE (
  w_product_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON received_order.products
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS received_order.products_audit();
CREATE OR REPLACE FUNCTION received_order.products_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.product_name;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.product_name;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.product_name;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON received_order.products
  FOR EACH ROW
EXECUTE PROCEDURE received_order.products_audit();
