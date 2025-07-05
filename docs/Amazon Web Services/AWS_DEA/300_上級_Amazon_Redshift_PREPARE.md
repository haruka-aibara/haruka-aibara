# Amazon Redshift PREPARE (難易度レベル: 300)

## 概要
Amazon Redshiftの`PREPARE`コマンドは、SQLステートメントを事前に準備し、パラメータ化されたクエリを効率的に実行するための機能です。この機能は、同じ構造のクエリを異なるパラメータで繰り返し実行する際のパフォーマンス向上とセキュリティ強化において重要な役割を果たします。

PREPAREコマンドを学ぶ意義：
- クエリパフォーマンスの最適化
- SQLインジェクション攻撃の防止
- アプリケーション開発の効率化
- データベースセキュリティの向上

## 詳細

### PREPAREコマンドとは

#### 基本的な概念
`PREPARE`コマンドは、SQLステートメントを事前に解析・最適化し、実行時にパラメータをバインドできるようにする機能です。これにより以下の利点があります：

- **パフォーマンス向上**: クエリの解析・最適化を事前に実行
- **セキュリティ強化**: パラメータとクエリの分離によるSQLインジェクション防止
- **再利用性**: 同じクエリ構造を異なるパラメータで実行
- **メモリ効率**: 準備されたステートメントの再利用

#### 基本的な構文
```sql
PREPARE statement_name (parameter_types) AS statement;
```

#### パラメータの型指定
Redshiftで使用可能なパラメータ型：

- **文字列型**: `VARCHAR`, `CHAR`, `TEXT`
- **数値型**: `INTEGER`, `BIGINT`, `DECIMAL`, `FLOAT`, `DOUBLE PRECISION`
- **日付型**: `DATE`, `TIMESTAMP`
- **真偽値**: `BOOLEAN`
- **配列型**: `VARCHAR[]`, `INTEGER[]`

### 基本的な使用方法

#### 単純なPREPARE文
```sql
-- 基本的なSELECT文の準備
PREPARE get_customer (INTEGER) AS
SELECT customer_id, customer_name, email
FROM customers
WHERE customer_id = $1;

-- 準備されたステートメントの実行
EXECUTE get_customer(123);
```

#### 複数パラメータの使用
```sql
-- 複数パラメータを持つクエリの準備
PREPARE find_customers (VARCHAR, DATE, DECIMAL) AS
SELECT customer_id, customer_name, email, registration_date
FROM customers
WHERE region = $1 
  AND registration_date >= $2
  AND total_spent >= $3
ORDER BY total_spent DESC;

-- 実行例
EXECUTE find_customers('APAC', '2024-01-01', 1000.00);
```

#### 異なるデータ型の組み合わせ
```sql
-- 様々なデータ型を組み合わせたクエリ
PREPARE complex_query (VARCHAR, INTEGER, BOOLEAN, DATE) AS
SELECT 
    c.customer_name,
    o.order_id,
    o.order_date,
    o.total_amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE c.region = $1
  AND c.customer_id > $2
  AND c.is_active = $3
  AND o.order_date >= $4
ORDER BY o.total_amount DESC;

-- 実行例
EXECUTE complex_query('North America', 1000, true, '2024-01-01');
```

### 高度な使用方法

#### 動的クエリの構築
```sql
-- 条件付きクエリの準備
PREPARE dynamic_search (VARCHAR, VARCHAR, INTEGER) AS
SELECT customer_id, customer_name, email, region
FROM customers
WHERE ($1 IS NULL OR region = $1)
  AND ($2 IS NULL OR customer_name LIKE '%' || $2 || '%')
  AND ($3 IS NULL OR customer_id > $3)
ORDER BY customer_name;

-- 様々な条件での実行
EXECUTE dynamic_search('APAC', NULL, NULL);  -- 地域のみ指定
EXECUTE dynamic_search(NULL, 'Tanaka', NULL);  -- 名前のみ指定
EXECUTE dynamic_search('APAC', 'Tanaka', 1000);  -- 全条件指定
```

#### 集計クエリの準備
```sql
-- 売上集計クエリの準備
PREPARE sales_summary (VARCHAR, DATE, DATE) AS
SELECT 
    p.product_name,
    COUNT(o.order_id) as order_count,
    SUM(od.quantity) as total_quantity,
    SUM(od.quantity * od.unit_price) as total_revenue
FROM products p
INNER JOIN order_details od ON p.product_id = od.product_id
INNER JOIN orders o ON od.order_id = o.order_id
WHERE p.category = $1
  AND o.order_date BETWEEN $2 AND $3
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;

-- 実行例
EXECUTE sales_summary('Electronics', '2024-01-01', '2024-12-31');
```

#### データ更新クエリの準備
```sql
-- 顧客情報更新クエリの準備
PREPARE update_customer (VARCHAR, VARCHAR, INTEGER) AS
UPDATE customers
SET 
    email = $1,
    phone = $2
WHERE customer_id = $3;

-- 実行例
EXECUTE update_customer('newemail@example.com', '090-9999-9999', 123);

-- 一括更新クエリの準備
PREPARE bulk_update_status (VARCHAR, DATE) AS
UPDATE customers
SET status = 'inactive'
WHERE last_login_date < $1
  AND region = $2;

-- 実行例
EXECUTE bulk_update_status('APAC', '2023-01-01');
```

### 実践的なアプリケーション例

#### レポート生成システム
```sql
-- 月次売上レポートの準備
PREPARE monthly_sales_report (INTEGER, INTEGER) AS
SELECT 
    DATE_TRUNC('month', o.order_date) as month,
    c.region,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE EXTRACT(YEAR FROM o.order_date) = $1
  AND EXTRACT(MONTH FROM o.order_date) = $2
GROUP BY DATE_TRUNC('month', o.order_date), c.region
ORDER BY total_revenue DESC;

-- 2024年1月のレポート
EXECUTE monthly_sales_report(2024, 1);
```

#### ダッシュボード用クエリ
```sql
-- リアルタイムダッシュボード用クエリの準備
PREPARE dashboard_metrics (VARCHAR, INTEGER) AS
SELECT 
    'total_customers' as metric_name,
    COUNT(*) as metric_value
FROM customers
WHERE region = $1
UNION ALL
SELECT 
    'active_customers' as metric_name,
    COUNT(*) as metric_value
FROM customers
WHERE region = $1 AND status = 'active'
UNION ALL
SELECT 
    'total_orders' as metric_name,
    COUNT(*) as metric_value
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE c.region = $1
  AND o.order_date >= CURRENT_DATE - $2;

-- 実行例
EXECUTE dashboard_metrics('APAC', 30);  -- 過去30日間
```

#### データ検証クエリ
```sql
-- データ品質チェッククエリの準備
PREPARE data_quality_check (VARCHAR, DATE) AS
SELECT 
    'duplicate_emails' as check_type,
    COUNT(*) as issue_count
FROM (
    SELECT email, COUNT(*)
    FROM customers
    WHERE region = $1
    GROUP BY email
    HAVING COUNT(*) > 1
) duplicates
UNION ALL
SELECT 
    'missing_phone' as check_type,
    COUNT(*) as issue_count
FROM customers
WHERE region = $1 
  AND (phone IS NULL OR phone = '')
UNION ALL
SELECT 
    'inactive_long_time' as check_type,
    COUNT(*) as issue_count
FROM customers
WHERE region = $1
  AND status = 'active'
  AND last_login_date < $2;

-- 実行例
EXECUTE data_quality_check('APAC', '2023-01-01');
```

### セキュリティとベストプラクティス

#### SQLインジェクション対策
```sql
-- 危険な例（PREPAREを使用しない）
-- ユーザー入力: "'; DROP TABLE customers; --"
SELECT * FROM customers WHERE customer_name = 'user_input';

-- 安全な例（PREPAREを使用）
PREPARE safe_query (VARCHAR) AS
SELECT * FROM customers WHERE customer_name = $1;

-- 実行時はパラメータとして渡されるため、SQLインジェクションを防止
EXECUTE safe_query('user_input');
```

#### エラーハンドリング
```sql
-- エラーハンドリングを含むPREPARE文
PREPARE safe_update (VARCHAR, INTEGER) AS
UPDATE customers
SET email = $1
WHERE customer_id = $2
  AND email IS NOT NULL;  -- 安全条件の追加

-- 実行前の存在確認
PREPARE check_exists (INTEGER) AS
SELECT COUNT(*) FROM customers WHERE customer_id = $1;

-- 実行例
DO $$
DECLARE
    customer_count INTEGER;
BEGIN
    EXECUTE check_exists(123) INTO customer_count;
    IF customer_count > 0 THEN
        EXECUTE safe_update('newemail@example.com', 123);
    ELSE
        RAISE NOTICE 'Customer not found';
    END IF;
END $$;
```

#### パフォーマンス最適化
```sql
-- インデックスを活用したPREPARE文
PREPARE optimized_query (VARCHAR, DATE) AS
SELECT customer_id, customer_name, email
FROM customers
WHERE region = $1  -- インデックス付き列
  AND registration_date >= $2  -- インデックス付き列
ORDER BY customer_name;  -- ソートキーを考慮

-- 実行計画の確認
EXPLAIN EXECUTE optimized_query('APAC', '2024-01-01');
```

### 管理とメンテナンス

#### 準備されたステートメントの管理
```sql
-- 準備されたステートメントの一覧表示
SELECT 
    name,
    statement,
    parameter_types,
    prepare_time
FROM pg_prepared_statements;

-- 特定のステートメントの削除
DEALLOCATE statement_name;

-- 全ステートメントの削除
DEALLOCATE ALL;
```

#### セッション管理
```sql
-- セッション固有のPREPARE文
PREPARE session_specific (VARCHAR) AS
SELECT * FROM customers 
WHERE region = $1 
  AND created_by = current_user;  -- セッション情報の活用

-- 実行例
EXECUTE session_specific('APAC');
```

## まとめ

### 学んだことの振り返り
- **PREPAREコマンド**: クエリの事前準備とパラメータ化
- **パフォーマンス向上**: 解析・最適化の事前実行
- **セキュリティ強化**: SQLインジェクション攻撃の防止
- **再利用性**: 同じクエリ構造の効率的な実行
- **実践的活用**: レポート生成、ダッシュボード、データ検証

### 次のステップへの提案
1. **ストアドプロシージャ**: より複雑なロジックの実装
2. **トリガー**: データ変更時の自動処理
3. **ビュー**: 複雑なクエリの抽象化
4. **マテリアライズドビュー**: 事前計算された結果の活用
5. **パーティショニング**: 大規模データの効率的な管理
6. **ワークロード管理**: クエリ優先度とリソース制御

Amazon Redshiftの`PREPARE`コマンドは、高性能で安全なデータベースアプリケーションを構築するための重要な技術です。適切に活用することで、パフォーマンスとセキュリティの両方を向上させることができます。 
