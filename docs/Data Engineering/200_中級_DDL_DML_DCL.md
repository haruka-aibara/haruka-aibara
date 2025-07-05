# DDL・DML・DCL (難易度レベル: 200)

## 概要
DDL（Data Definition Language）、DML（Data Manipulation Language）、DCL（Data Control Language）は、リレーショナルデータベース管理システム（RDBMS）におけるSQL言語の3つの主要なカテゴリです。それぞれがデータベースの異なる側面を扱い、データベースの設計、操作、セキュリティを統合的に管理します。

これらの言語を学ぶ意義：
- データベース設計の体系的理解
- 効率的なデータ操作の実現
- セキュリティとアクセス制御の実装
- データベース管理の実践的スキル

## 詳細

### DDL（Data Definition Language）

#### DDLとは
データベースの構造を定義・変更・削除するための言語です。データベースのスキーマ（構造）を管理する役割を担います。

#### 主要なDDLコマンド

##### CREATE
データベースオブジェクトを作成します。

```sql
-- データベースの作成
CREATE DATABASE sales_db;

-- テーブルの作成
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    registration_date DATE DEFAULT CURRENT_DATE,
    status ENUM('active', 'inactive') DEFAULT 'active'
);

-- インデックスの作成
CREATE INDEX idx_customer_email ON customers(email);

-- ビューの作成
CREATE VIEW active_customers AS
SELECT customer_id, customer_name, email
FROM customers
WHERE status = 'active';
```

##### ALTER
既存のデータベースオブジェクトを変更します。

```sql
-- テーブルに列を追加
ALTER TABLE customers ADD COLUMN phone VARCHAR(20);

-- 列の型を変更
ALTER TABLE customers MODIFY COLUMN customer_name VARCHAR(150);

-- 列名を変更
ALTER TABLE customers CHANGE COLUMN customer_name name VARCHAR(100);

-- 制約を追加
ALTER TABLE customers ADD CONSTRAINT chk_email CHECK (email LIKE '%@%');
```

##### DROP
データベースオブジェクトを削除します。

```sql
-- テーブルの削除
DROP TABLE customers;

-- インデックスの削除
DROP INDEX idx_customer_email ON customers;

-- ビューの削除
DROP VIEW active_customers;

-- データベースの削除
DROP DATABASE sales_db;
```

##### TRUNCATE
テーブルの全データを削除し、テーブル構造は保持します。

```sql
-- テーブルの全データを削除
TRUNCATE TABLE customers;
```

### DML（Data Manipulation Language）

#### DMLとは
データベース内のデータを操作（挿入、更新、削除、検索）するための言語です。実際のデータの処理を担当します。

#### 主要なDMLコマンド

##### SELECT
データを検索・取得します。

```sql
-- 基本的なSELECT
SELECT customer_id, customer_name, email
FROM customers
WHERE status = 'active';

-- 集計関数を使用
SELECT 
    COUNT(*) as total_customers,
    AVG(registration_date) as avg_registration_date
FROM customers;

-- JOINを使用
SELECT 
    c.customer_name,
    o.order_id,
    o.order_date
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;

-- サブクエリを使用
SELECT customer_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id 
    FROM orders 
    WHERE order_date >= '2024-01-01'
);
```

##### INSERT
新しいデータを挿入します。

```sql
-- 単一行の挿入
INSERT INTO customers (customer_id, customer_name, email)
VALUES (1, '田中太郎', 'tanaka@example.com');

-- 複数行の挿入
INSERT INTO customers (customer_id, customer_name, email) VALUES
(2, '佐藤花子', 'sato@example.com'),
(3, '鈴木一郎', 'suzuki@example.com'),
(4, '高橋美咲', 'takahashi@example.com');

-- SELECT結果を挿入
INSERT INTO customers (customer_id, customer_name, email)
SELECT customer_id, customer_name, email
FROM temp_customers
WHERE status = 'active';
```

##### UPDATE
既存のデータを更新します。

```sql
-- 単一条件での更新
UPDATE customers
SET status = 'inactive'
WHERE customer_id = 1;

-- 複数条件での更新
UPDATE customers
SET 
    status = 'active',
    registration_date = CURRENT_DATE
WHERE email IS NOT NULL AND status = 'pending';

-- JOINを使用した更新
UPDATE customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
SET c.status = 'active'
WHERE o.order_date >= '2024-01-01';
```

##### DELETE
データを削除します。

```sql
-- 条件付き削除
DELETE FROM customers
WHERE status = 'inactive';

-- 複数条件での削除
DELETE FROM customers
WHERE registration_date < '2020-01-01'
AND status = 'inactive';

-- JOINを使用した削除
DELETE c FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date < '2020-01-01';
```

### DCL（Data Control Language）

#### DCLとは
データベースのセキュリティとアクセス制御を管理するための言語です。ユーザーの権限とアクセス権を制御します。

#### 主要なDCLコマンド

##### GRANT
ユーザーやロールに権限を付与します。

```sql
-- 基本的な権限付与
GRANT SELECT ON customers TO user1;

-- 複数権限の付与
GRANT SELECT, INSERT, UPDATE ON customers TO user2;

-- 全テーブルへの権限付与
GRANT ALL PRIVILEGES ON sales_db.* TO admin_user;

-- 特定の列への権限付与
GRANT SELECT (customer_id, customer_name) ON customers TO analyst_user;

-- ロールへの権限付与
GRANT SELECT ON customers TO role_analyst;
```

##### REVOKE
ユーザーやロールから権限を削除します。

```sql
-- 権限の削除
REVOKE SELECT ON customers FROM user1;

-- 複数権限の削除
REVOKE INSERT, UPDATE ON customers FROM user2;

-- 全権限の削除
REVOKE ALL PRIVILEGES ON sales_db.* FROM admin_user;

-- ロールからの権限削除
REVOKE SELECT ON customers FROM role_analyst;
```

##### DENY
特定の権限を明示的に拒否します（SQL Serverなど）。

```sql
-- 権限の明示的拒否
DENY DELETE ON customers TO user1;

-- 複数権限の拒否
DENY INSERT, UPDATE ON customers TO user2;
```

## 具体例

### 実践的なデータベース設計例

#### オンラインショップのデータベース設計

```sql
-- データベースの作成
CREATE DATABASE online_shop;

-- 顧客テーブル
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    INDEX idx_email (email),
    INDEX idx_status (status)
);

-- 商品テーブル
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    category_id INT,
    created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category_id),
    INDEX idx_price (price)
);

-- 注文テーブル
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'confirmed', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    INDEX idx_customer (customer_id),
    INDEX idx_status (status),
    INDEX idx_date (order_date)
);

-- 注文詳細テーブル
CREATE TABLE order_details (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    INDEX idx_order (order_id),
    INDEX idx_product (product_id)
);
```

#### データ操作の実例

```sql
-- サンプルデータの挿入
INSERT INTO customers (customer_name, email, phone) VALUES
('田中太郎', 'tanaka@example.com', '090-1234-5678'),
('佐藤花子', 'sato@example.com', '090-2345-6789'),
('鈴木一郎', 'suzuki@example.com', '090-3456-7890');

INSERT INTO products (product_name, description, price, stock_quantity) VALUES
('ノートPC', '高性能ノートパソコン', 150000.00, 10),
('スマートフォン', '最新スマートフォン', 80000.00, 20),
('タブレット', '軽量タブレット', 50000.00, 15);

-- 注文の作成
INSERT INTO orders (customer_id, total_amount) VALUES (1, 230000.00);

-- 注文詳細の作成
INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 150000.00),
(1, 2, 1, 80000.00);

-- 在庫の更新
UPDATE products 
SET stock_quantity = stock_quantity - 1 
WHERE product_id = 1;

-- 売上レポートの作成
SELECT 
    p.product_name,
    SUM(od.quantity) as total_sold,
    SUM(od.quantity * od.unit_price) as total_revenue
FROM products p
INNER JOIN order_details od ON p.product_id = od.product_id
INNER JOIN orders o ON od.order_id = o.order_id
WHERE o.status != 'cancelled'
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;
```

#### セキュリティ設定の実例

```sql
-- ユーザーの作成
CREATE USER 'sales_user'@'localhost' IDENTIFIED BY 'password123';
CREATE USER 'analyst_user'@'localhost' IDENTIFIED BY 'password456';
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'adminpass123';

-- ロールの作成
CREATE ROLE 'sales_role';
CREATE ROLE 'analyst_role';
CREATE ROLE 'admin_role';

-- 権限の付与
-- 営業担当者用
GRANT SELECT, INSERT, UPDATE ON online_shop.customers TO sales_role;
GRANT SELECT, INSERT, UPDATE ON online_shop.orders TO sales_role;
GRANT SELECT ON online_shop.products TO sales_role;

-- 分析担当者用
GRANT SELECT ON online_shop.* TO analyst_role;

-- 管理者用
GRANT ALL PRIVILEGES ON online_shop.* TO admin_role;

-- ユーザーにロールを割り当て
GRANT sales_role TO 'sales_user'@'localhost';
GRANT analyst_role TO 'analyst_user'@'localhost';
GRANT admin_role TO 'admin_user'@'localhost';

-- ビューの作成（セキュリティ向上）
CREATE VIEW customer_summary AS
SELECT 
    customer_id,
    customer_name,
    email,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE c.status = 'active'
GROUP BY c.customer_id, c.customer_name, c.email;

-- 分析担当者にビューへのアクセス権を付与
GRANT SELECT ON online_shop.customer_summary TO analyst_role;
```

## まとめ

### 学んだことの振り返り
- **DDL**: データベース構造の定義・変更・削除を担当
- **DML**: データの挿入・更新・削除・検索を担当
- **DCL**: セキュリティとアクセス制御を担当
- 3つの言語を組み合わせることで、完全なデータベース管理が可能
- 実践的なプロジェクトでは、適切な権限設計が重要

### 次のステップへの提案
1. **トランザクション管理**: COMMIT、ROLLBACK、SAVEPOINTの理解
2. **ストアドプロシージャ**: 複雑な処理の自動化
3. **トリガー**: データ変更時の自動処理
4. **パフォーマンス最適化**: インデックス設計とクエリ最適化
5. **データベース設計**: 正規化と非正規化の実践
6. **セキュリティ強化**: 暗号化、監査ログ、バックアップ戦略

DDL・DML・DCLの理解は、データベース管理の基盤となる重要なスキルです。これらの言語を適切に組み合わせることで、効率的で安全なデータベースシステムを構築・運用することができます。 
