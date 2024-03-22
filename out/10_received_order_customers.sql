-- is_master_table=true

-- 1.得意先(customers)

-- Create Table
DROP TABLE IF EXISTS received_order.customers CASCADE;
CREATE TABLE received_order.customers (
  customer_id varchar(3) NOT NULL check (LENGTH(customer_id) = 3),
  customer_name varchar(100) NOT NULL DEFAULT 'AAA',
  person_in_charge varchar(30),
  customer_type received_order.customer_type NOT NULL,
  registration_date date NOT NULL DEFAULT current_timestamp,
  product_pic varchar(4) NOT NULL check (LENGTH(product_pic) = 4),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE received_order.customers IS '得意先';

-- Set Column Comment
COMMENT ON COLUMN received_order.customers.customer_id IS '得意先ID';
COMMENT ON COLUMN received_order.customers.customer_name IS '得意先';
COMMENT ON COLUMN received_order.customers.person_in_charge IS '担当者名';
COMMENT ON COLUMN received_order.customers.customer_type IS '取引先区分';
COMMENT ON COLUMN received_order.customers.registration_date IS '登録日';
COMMENT ON COLUMN received_order.customers.product_pic IS '商品担当者ID';
COMMENT ON COLUMN received_order.customers.created_at IS '作成日時';
COMMENT ON COLUMN received_order.customers.updated_at IS '更新日時';
COMMENT ON COLUMN received_order.customers.created_by IS '作成者';
COMMENT ON COLUMN received_order.customers.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE received_order.customers ADD PRIMARY KEY (
  customer_id
);

-- Set Unique Constraint
ALTER TABLE received_order.customers ADD CONSTRAINT customers_unique_1 UNIQUE (
  customer_id,
  person_in_charge
);

ALTER TABLE received_order.customers ADD CONSTRAINT customers_unique_2 UNIQUE (
  registration_date
);

ALTER TABLE received_order.customers ADD CONSTRAINT customers_unique_3 UNIQUE (
  product_pic
);

-- create index
CREATE INDEX idx_customers_1 ON received_order.customers (
  person_in_charge
);

CREATE INDEX idx_customers_2 ON received_order.customers (
  registration_date,
  customer_type
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON received_order.customers
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS received_order.customers_audit();
CREATE OR REPLACE FUNCTION received_order.customers_audit() RETURNS TRIGGER AS $$
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
  ON received_order.customers
  FOR EACH ROW
EXECUTE PROCEDURE received_order.customers_audit();
