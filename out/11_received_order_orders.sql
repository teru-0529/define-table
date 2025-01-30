-- operation_afert_create_tables

-- 3.受注(orders)

-- Set FK Constraint
ALTER TABLE received_order.orders DROP CONSTRAINT IF EXISTS orders_foreignKey_1;
ALTER TABLE received_order.orders ADD CONSTRAINT orders_foreignKey_1 FOREIGN KEY (
  order_pic
) REFERENCES received_order.operators (
  operator_name
);
