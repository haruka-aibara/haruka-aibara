# GitHub Actions サービスコンテナ

## 概要
サービスコンテナは、GitHub Actionsのワークフロー内でデータベースやキャッシュサービスなどの依存サービスを実行するためのコンテナです。CI/CDパイプラインでテストやビルド時に必要な外部サービスを簡単に利用できるようにすることで、開発効率を大幅に向上させることができます。

## 主要概念
サービスコンテナは、Dockerコンテナ技術を活用して、ワークフローの実行環境内に独立したサービスを提供します。各サービスは独自のネットワーク空間で動作し、ジョブの実行中のみ存在する一時的な環境として機能します。これにより、テスト環境の再現性と分離性を確保することができます。

```mermaid
graph TB
    subgraph "GitHub Actions Runner"
        subgraph "Job 1"
            A1[Step 1] --> B1[Step 2]
            B1 --> C1[Step 3]
            A1 -.-> S1[Service Container 1]
            B1 -.-> S1
            C1 -.-> S1
        end
        
        subgraph "Job 2"
            A2[Step 1] --> B2[Step 2]
            B2 --> C2[Step 3]
            A2 -.-> S2[Service Container 2]
            B2 -.-> S2
            C2 -.-> S2
        end
    end
    
    style S1 fill:#f9f,stroke:#333,stroke-width:2px
    style S2 fill:#f9f,stroke:#333,stroke-width:2px
```

## 基本的な使い方

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      redis:
        image: redis
        ports:
          - 6379:6379
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
```

## 実践的なユースケース

### 1. データベースを使用したテスト
```yaml
jobs:
  integration-test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_USER: postgres
          POSTGRES_DB: test_db
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: npm test
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
```

### 2. 複数サービスの連携
```yaml
jobs:
  e2e-test:
    runs-on: ubuntu-latest
    services:
      redis:
        image: redis
        ports:
          - 6379:6379
      rabbitmq:
        image: rabbitmq:3-management
        ports:
          - 5672:5672
          - 15672:15672
```

## 主な特徴

1. **ジョブごとの分離**: 各ジョブで個別にサービスを定義する必要があります
2. **自動ヘルスチェック**: サービスが正常に起動するまで待機
3. **ネットワーク分離**: 各サービスは独立したネットワークで実行

## よく使われるサービス

| カテゴリ | サービス例 |
|---------|-----------|
| データベース | MySQL, PostgreSQL, MongoDB |
| キャッシュ | Redis, Memcached |
| メッセージキュー | RabbitMQ |
| 検索エンジン | Elasticsearch |

## セキュリティと注意点

1. **認証情報の管理**
   - サービスコンテナの認証情報は環境変数として安全に管理
   - 本番環境の認証情報は使用しない

2. **ネットワークセキュリティ**
   - 必要なポートのみを公開
   - サービス間の通信は内部ネットワークで行う

3. **リソース制限**
   - サービスコンテナはジョブの実行中のみ存在
   - ジョブ間でサービスを共有することはできない
   - パフォーマンスを考慮して必要なサービスのみを定義

## 参考資料
- [GitHub Actions サービスコンテナの公式ドキュメント](https://docs.github.com/ja/actions/using-containerized-services/about-service-containers)
- [Docker 公式ドキュメント](https://docs.docker.com/)
