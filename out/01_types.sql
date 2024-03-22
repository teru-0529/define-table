-- Enum Type DDL

-- 商品区分
DROP TYPE IF EXISTS received_order.product_kbn;
CREATE TYPE received_order.product_kbn AS enum (
  'NO_CHECKED',
  'NORMAL',
  'CHANGED',
  'STOPPED'
);

-- 部署
DROP TYPE IF EXISTS received_order.department;
CREATE TYPE received_order.department AS enum (
  'RECEIVING',
  'ORDERING',
  'PRODUCTS',
  'OVERSEAS',
  'ACCOUNTING'
);

-- 取引先区分
DROP TYPE IF EXISTS received_order.customer_type;
CREATE TYPE received_order.customer_type AS enum (
  'LOYAL',
  'STANDARD',
  'TRIAL',
  'NOT_TRADE'
);

