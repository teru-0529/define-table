# テーブル定義

----------

## #1 得意先(customers)

### Fields

| # | 名称 | データ型 | NOT NULL | 初期値 | 制約 |
| -- | -- | -- | -- | -- | -- |
| 1 | 得意先ID(customer_id) | varchar(3) | true |  | (LENGTH(customer_id) = 3) |
| 2 | 得意先(customer_name) | varchar(100) | true | AAA |  |
| 3 | 担当者名(person_in_charge) | varchar(30) | false |  |  |
| 4 | 取引先区分(customer_type) | customer_type | true |  |  |
| 5 | 登録日(registration_date) | date | true | current_timestamp |  |

### Constraints

#### Primary Key

* 得意先ID(customer_id)

#### Uniques

#### customers_unique_1

* 得意先(customer_name)
* 担当者名(person_in_charge)

#### customers_unique_2

* 登録日(registration_date)

----------

## #2 受注(orders)

### Fields

| # | 名称 | データ型 | NOT NULL | 初期値 | 制約 |
| -- | -- | -- | -- | -- | -- |
| 1 | 受注No(received_order_no) | varchar(10) | true |  | (LENGTH(received_order_no) = 10) |
| 2 | 受注日(order_date) | date | true |  |  |
| 3 | 担当者名(person_in_charge) | varchar(30) | false |  |  |
| 4 | 得意先ID(customer_id) | varchar(3) | true |  | (LENGTH(customer_id) = 3) |
| 5 | コメント(comment) | text | false |  | (LENGTH(comment) >= 10) |

### Constraints

#### Primary Key

* 受注No(received_order_no)

----------

## #3 受注明細(order_details)

### Fields

| # | 名称 | データ型 | NOT NULL | 初期値 | 制約 |
| -- | -- | -- | -- | -- | -- |
| 1 | 受注No(received_order_no) | varchar(10) | true |  | (LENGTH(received_order_no) = 10) |
| 2 | 商品No(product_no) | varchar(10) | true |  | (LENGTH(product_no) >= 9) |
| 3 | 数量(quantity) | integer | false |  | (0 <= quantity AND quantity <= 99999) |
| 4 | 定価(price) | integer | false |  | (price >= 0) |

### Constraints

#### Primary Key

* 受注No(received_order_no)
* 商品No(product_no)

----------
