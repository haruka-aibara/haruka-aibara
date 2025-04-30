# Docker Compose講義

## Docker Composeとは
Docker Composeは複数のコンテナを定義し、単一のコマンドで一度に実行できるようにするツールです。

## 主要概念
Docker Composeは`docker-compose.yml`ファイルを使用して、アプリケーションの全サービスを構成します。

## docker-compose.yml

Docker Composeの中心となるのは`docker-compose.yml`というYAMLファイルです。このファイルでは、アプリケーションを構成する各サービス（コンテナ）の設定を記述します。

### 基本構造

```yaml
services:      # サービス（コンテナ）の定義
  web:         # サービス名
    image: nginx:latest  # 使用するDockerイメージ
    ports:
      - "80:80"  # ポートマッピング（ホスト:コンテナ）
    volumes:
      - ./html:/usr/share/nginx/html  # ボリュームマウント
    
  database:    # 別のサービス
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: example
      MYSQL_DATABASE: app_db
    volumes:
      - db-data:/var/lib/mysql

volumes:       # 名前付きボリュームの定義
  db-data:
```

### 主要な設定項目

- `services`: 各コンテナの設定
  - `image`: 使用するDockerイメージ
  - `build`: Dockerfileからイメージをビルドする場合の設定
  - `ports`: ポートマッピング
  - `volumes`: ボリュームマウント
  - `environment`: 環境変数
  - `depends_on`: サービス間の依存関係
  - `networks`: 使用するネットワーク

## Docker Composeコマンド

### up - コンテナの起動

`docker compose up`コマンドは、docker-compose.ymlで定義されたすべてのサービスを起動します。

```bash
# 基本的な使い方
docker compose up

# デタッチドモード（バックグラウンドで実行）
docker compose up -d

# 特定のサービスのみ起動
docker compose up web

# コンテナを強制的に再作成
docker compose up --force-recreate
```

### down - コンテナの停止と削除

`docker compose down`コマンドは、起動中のコンテナを停止して削除します。

```bash
# 基本的な使い方
docker compose down

# ボリュームも削除
docker compose down -v

# ネットワークも削除
docker compose down --remove-orphans
```

### その他の主要コマンド

これらのコマンドは参考までに記載しています：

```bash
# サービスの状態確認
docker compose ps

# コンテナのログを表示
docker compose logs

# 実行中のサービスに対してコマンドを実行
docker compose exec web bash
```

## まとめ

Docker Composeを使うことで、複数のコンテナから成るアプリケーションを簡単に定義・実行することができます。`docker-compose.yml`ファイルでサービスを定義し、`up`と`down`コマンドで管理するという基本的な流れを覚えておけば、複雑な開発環境やアプリケーションも効率的に扱えるようになります。
