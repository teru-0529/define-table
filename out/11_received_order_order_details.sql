-- operation_afert_create_tables

-- 4.受注明細(order_details)

-- Set FK Constraint
ALTER TABLE received_order.order_details DROP CONSTRAINT IF EXISTS order_details_foreignKey_1;
ALTER TABLE received_order.order_details ADD CONSTRAINT order_details_foreignKey_1 FOREIGN KEY (
  order_no
) REFERENCES received_order.orders (
  order_no
) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE received_order.order_details DROP CONSTRAINT IF EXISTS order_details_foreignKey_2;
ALTER TABLE received_order.order_details ADD CONSTRAINT order_details_foreignKey_2 FOREIGN KEY (
  product_name
) REFERENCES received_order.products (
  product_name
);
