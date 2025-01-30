-- is_master_table=false

-- 4.受注明細(order_details)

-- Create Table
DROP TABLE IF EXISTS received_order.order_details CASCADE;
CREATE TABLE received_order.order_details (
  order_no integer NOT NULL,
  order_detail_no integer NOT NULL,
  product_name varchar(30) NOT NULL,
  receiving_quantity integer NOT NULL check (receiving_quantity >= 0),
  shipping_flag boolean NOT NULL,
  cancel_flag boolean NOT NULL,
  selling_price integer NOT NULL check (selling_price >= 0),
  cost_price integer NOT NULL check (cost_price >= 0),
  w_order_no varchar(10) NOT NULL check (w_order_no ~* '^RO-[0-9]{7}$'),
  w_shipping_quantity integer NOT NULL DEFAULT 0 check (w_shipping_quantity >= 0),
  w_cancel_quantity integer NOT NULL DEFAULT 0 check (w_cancel_quantity >= 0),
  w_remaining_quantity integer NOT NULL DEFAULT 0 check (w_remaining_quantity >= 0),
  w_total_order_price integer NOT NULL DEFAULT 0 check (w_total_order_price >= 0),
  w_remaining_order_price integer NOT NULL DEFAULT 0 check (w_remaining_order_price >= 0),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE received_order.order_details IS '受注明細';

-- Set Column Comment
COMMENT ON COLUMN received_order.order_details.order_no IS '受注番号';
COMMENT ON COLUMN received_order.order_details.order_detail_no IS '受注明細番号';
COMMENT ON COLUMN received_order.order_details.product_name IS '商品名';
COMMENT ON COLUMN received_order.order_details.receiving_quantity IS '受注数量';
COMMENT ON COLUMN received_order.order_details.shipping_flag IS '出荷済フラグ';
COMMENT ON COLUMN received_order.order_details.cancel_flag IS 'キャンセルフラグ';
COMMENT ON COLUMN received_order.order_details.selling_price IS '販売単価';
COMMENT ON COLUMN received_order.order_details.cost_price IS '商品原価';
COMMENT ON COLUMN received_order.order_details.w_order_no IS '受注番号(WORK)';
COMMENT ON COLUMN received_order.order_details.w_shipping_quantity IS '出荷済数(WORK)';
COMMENT ON COLUMN received_order.order_details.w_cancel_quantity IS 'キャンセル数(WORK)';
COMMENT ON COLUMN received_order.order_details.w_remaining_quantity IS '受注残数(WORK)';
COMMENT ON COLUMN received_order.order_details.w_total_order_price IS '受注金額(WORK)';
COMMENT ON COLUMN received_order.order_details.w_remaining_order_price IS '受注残額(WORK)';
COMMENT ON COLUMN received_order.order_details.created_at IS '作成日時';
COMMENT ON COLUMN received_order.order_details.updated_at IS '更新日時';
COMMENT ON COLUMN received_order.order_details.created_by IS '作成者';
COMMENT ON COLUMN received_order.order_details.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE received_order.order_details ADD PRIMARY KEY (
  order_no,
  order_detail_no
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
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.order_no || '-' || OLD.order_detail_no;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.order_no || '-' || NEW.order_detail_no;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.order_no || '-' || NEW.order_detail_no;
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
