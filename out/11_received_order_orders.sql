-- operation_afert_create_tables

-- 2.受注(orders)

-- Set FK Constraint
ALTER TABLE received_order.orders DROP CONSTRAINT IF EXIST orders_foreignKey_1;
ALTER TABLE received_order.orders ADD CONSTRAINT orders_foreignKey_1 FOREIGN KEY (
  customer_id,
  person_in_charge
) REFERENCES received_order.customers (
  customer_id,
  person_in_charge
);
