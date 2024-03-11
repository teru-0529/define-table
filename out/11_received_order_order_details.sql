-- operation_afert_create_tables

-- 3.受注明細(order_details)

-- Set FK Constraint
ALTER TABLE received_order.order_details DROP CONSTRAINT IF EXISTS order_details_foreignKey_1;
ALTER TABLE received_order.order_details ADD CONSTRAINT order_details_foreignKey_1 FOREIGN KEY (
  received_order_no
) REFERENCES received_order.orders (
  received_order_no
) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE received_order.order_details DROP CONSTRAINT IF EXISTS order_details_foreignKey_2;
ALTER TABLE received_order.order_details ADD CONSTRAINT order_details_foreignKey_2 FOREIGN KEY (
  order_pic
) REFERENCES received_order.customers (
  product_pic
);
