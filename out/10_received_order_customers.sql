
-- 1.得意先(customers)

-- Create Table
DROP TABLE IF EXISTS received_order.customers CASCADE;
CREATE TABLE received_order.customers (
  customer_id varchar(3) NOT NULL check (LENGTH(customer_id) >= 3),
  customer_name varchar(100) NOT NULL,
  person_in_charge varchar(30),
  customer_type customer_type NOT NULL,
  registration_date date NOT NULL DEFAULT current_timestamp,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(30),
  updated_by varchar(30)
);

-- Set Column Comment
COMMENT ON COLUMN received_order.customers.customer_id IS '得意先ID';
COMMENT ON COLUMN received_order.customers.customer_name IS '得意先';
COMMENT ON COLUMN received_order.customers.person_in_charge IS '担当者名';
COMMENT ON COLUMN received_order.customers.customer_type IS '取引先区分';
COMMENT ON COLUMN received_order.customers.registration_date IS '登録日';
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
  customer_name,
  person_in_charge
);

ALTER TABLE received_order.customers ADD CONSTRAINT customers_unique_2 UNIQUE (
  registration_date
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER customers_updated
  BEFORE UPDATE
  ON received_order.customers
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at()
