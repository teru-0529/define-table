
-- 3.受注明細(order_details)

-- Create Table
DROP TABLE IF EXISTS received_order.order_details CASCADE;
CREATE TABLE received_order.order_details (
  received_order_no varchar(10) NOT NULL check (LENGTH(received_order_no) >= 10),
  product_no varchar(10) NOT NULL check (LENGTH(product_no) >= 9),
  quantity integer check (0 <= quantity AND quantity <= 99999),
  price integer check (price >= 0),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(30),
  updated_by varchar(30)
);

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
CREATE TRIGGER order_details_updated
  BEFORE UPDATE
  ON received_order.order_details
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at()
