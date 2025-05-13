# GitHub Actionsにおけるサービスコンテナとジョブのコミュニケーション

## 概要
GitHub Actionsのサービスコンテナは、ジョブの実行中に必要な外部サービス（データベース、キャッシュサーバーなど）を提供するための重要な機能です。ジョブとサービスコンテナ間の適切な通信設定は、ワークフローの信頼性と効率性を確保するために不可欠です。

## 主要概念
サービスコンテナとジョブの通信は、主に以下の2つの方法で行われます：
1. 環境変数による設定情報の共有
2. ネットワーク接続による直接通信

## コンテナ化されたジョブでの通信
ジョブがコンテナ内で実行される場合（`container` ディレクティブを使用する場合）、サービスコンテナとの通信はより単純になります。これは、GitHub Actionsが自動的に同じDockerネットワーク内にジョブコンテナとサービスコンテナを配置するためです。

この場合、サービスコンテナには単純にサービス名でアクセスできます。例えば：

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container: node:16
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
    
    steps:
      - name: Connect to PostgreSQL
        run: |
          # サービス名（postgres）で直接アクセス可能
          echo "Connection string: postgresql://postgres:postgres@postgres:5432/postgres"
```

この例では、`localhost` の代わりに `postgres` というサービス名を使用してデータベースにアクセスできます。これは、Dockerの内部DNSが自動的にサービス名をコンテナのIPアドレスに解決するためです。

## 実装例
以下は、PostgreSQLサービスコンテナを使用する例です：

```yaml
name: Service Container Example

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - name: Connect to PostgreSQL
        run: |
          echo "PostgreSQL is running on port 5432"
          echo "Connection string: postgresql://postgres:postgres@localhost:5432/postgres"
```

## 通信フロー
```mermaid
sequenceDiagram
    participant Job as ジョブ
    participant Service as サービスコンテナ
    participant Runner as GitHub Runner

    Job->>Runner: ジョブ開始
    Runner->>Service: サービスコンテナ起動
    Service-->>Runner: ヘルスチェック成功
    Runner-->>Job: サービス準備完了
    Job->>Service: 通信開始
    Service-->>Job: レスポンス
```

## 重要なポイント
1. **ポートマッピング**: サービスコンテナのポートをホストマシンにマッピングする必要があります
2. **ヘルスチェック**: サービスが完全に起動するまで待機するためのヘルスチェックを設定することが推奨されます
3. **環境変数**: サービスコンテナの設定情報は環境変数を通じて共有できます
4. **ネットワーク分離**: 各ジョブは独自のネットワーク名前空間を持ち、他のジョブからは分離されています

## セキュリティ考慮事項
- サービスコンテナの認証情報は、GitHub Secretsを使用して安全に管理する
- 必要最小限のポートのみを公開する
- サービスコンテナのイメージは信頼できるソースから取得する

## 参考資料
- [GitHub Actions サービスコンテナのドキュメント](https://docs.github.com/ja/actions/using-containerized-services/about-service-containers)
- [Docker コンテナのヘルスチェック](https://docs.docker.com/engine/reference/builder/#healthcheck) 
