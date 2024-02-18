# テーブル定義
----------

## #1 得意先 (customers)

### fielsds
| # | name_jp | name_en | model | not_null | default | field_constraint |
| -- | -- | -- | -- | -- | -- | -- |
| 1 | 得意先ID | customer_id | varchar(3) | True |  | (LENGTH(customer_id) >= 3) |
| 2 | 得意先 | customer_name | varchar(100) | True |  |  |
| 3 | 担当者名 | person_in_charge | varchar(30) | False |  |  |
| 4 | 取引先区分 | customer_type | customer_type | True |  |  |
| 5 | 登録日 | registration_date | date | True | current_timestamp |  |
### table constraint
#### primary key
* 得意先ID
#### unique
##### customers_unique_1
* 得意先
* 担当者名
##### customers_unique_2
* 登録日
----------

## #2 受注 (orders)

### fielsds
| # | name_jp | name_en | model | not_null | default | field_constraint |
| -- | -- | -- | -- | -- | -- | -- |
| 1 | 受注No | received_order_no | varchar(10) | True |  | (LENGTH(received_order_no) >= 10) |
| 2 | 受注日 | order_date | date | True |  |  |
| 3 | 担当者名 | person_in_charge | varchar(30) | False |  |  |
| 4 | 得意先ID | customer_id | varchar(3) | True |  | (LENGTH(customer_id) >= 3) |
| 5 | コメント | comment | text | False |  | (LENGTH(comment) >= 10) |
### table constraint
#### primary key
* 受注No
----------

## #3 受注明細 (order_details)

### fielsds
| # | name_jp | name_en | model | not_null | default | field_constraint |
| -- | -- | -- | -- | -- | -- | -- |
| 1 | 受注No | received_order_no | varchar(10) | True |  | (LENGTH(received_order_no) >= 10) |
| 2 | 商品No | product_no | varchar(10) | True |  | (LENGTH(product_no) >= 9) |
| 3 | 数量 | quantity | integer | False |  | (0 <= quantity AND quantity <= 99999) |
| 4 | 定価 | price | integer | False |  | (price >= 0) |
### table constraint
#### primary key
* 受注No
* 商品No
----------

