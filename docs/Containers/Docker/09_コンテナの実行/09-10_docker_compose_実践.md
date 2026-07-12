# Docker Compose 実践——本番に近い構成を組む

「`docker run` を何度も打つのが面倒」「チームメンバーが手順通りに環境を立ち上げられない」——Docker Compose は複数コンテナの構成をコードで宣言し、1コマンドで再現できるようにする。

---

## Web + DB + Redis の3コンテナ構成

最もよくある構成。FastAPI アプリ・PostgreSQL・Redis を組み合わせる例。

```yaml
# compose.yml
services:
  app:
    build: .
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://user:password@db:5432/mydb
      REDIS_URL: redis://cache:6379
    depends_on:
      db:
        condition: service_healthy
      cache:
        condition: service_started
    restart: unless-stopped

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: mydb
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d mydb"]
      interval: 10s
      timeout: 5s
      retries: 5

  cache:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes

volumes:
  postgres_data:
  redis_data:
```

**ポイント:**
- `depends_on` に `condition: service_healthy` を使うと、DB の healthcheck が通ってからアプリが起動する（単純な `depends_on` は「コンテナが起動した」だけを見るので DB の準備が整っていない）
- ボリュームを名前付きにする（`postgres_data`）ことで `docker compose down` しても DB データが消えない
- `restart: unless-stopped` で予期しない終了時に自動再起動

---

## 環境変数を `.env` ファイルで管理

パスワードや設定をコードにハードコードしない。

```bash
# .env（Git に入れない、.gitignore に追加する）
POSTGRES_USER=user
POSTGRES_PASSWORD=s3cr3t
POSTGRES_DB=mydb
REDIS_URL=redis://cache:6379
```

```yaml
# compose.yml
services:
  db:
    image: postgres:16-alpine
    env_file:
      - .env
```

`.env.example`（ダミー値が入ったサンプル）をリポジトリに含め、新メンバーが `cp .env.example .env` してから値を埋める運用が定番。

---

## 開発と本番でオーバーライドを使い分ける

```yaml
# compose.yml（共通）
services:
  app:
    build: .
    environment:
      DATABASE_URL: postgresql://user:password@db:5432/mydb
```

```yaml
# compose.override.yml（開発用、自動的に読まれる）
services:
  app:
    volumes:
      - .:/app          # ホットリロードのためにソースをマウント
    command: uvicorn main:app --reload
```

```yaml
# compose.prod.yml（本番用、明示的に指定して使う）
services:
  app:
    command: uvicorn main:app --workers 4
    restart: always
```

```bash
# 本番用で起動
docker compose -f compose.yml -f compose.prod.yml up -d
```

---

## よく使うコマンド

```bash
# 起動（バックグラウンド）
docker compose up -d

# ログを追跡（特定サービスのみ）
docker compose logs -f app

# 実行中コンテナに入る
docker compose exec app bash

# 特定サービスだけ再起動
docker compose restart app

# イメージを再ビルドして起動
docker compose up -d --build app

# ボリュームごと全削除（DBを初期化したいとき）
docker compose down -v
```

---

## Compose を使ったローカル開発でよくある失敗パターン

| 失敗 | 原因 | 対策 |
|---|---|---|
| アプリが DB に接続できずに落ちる | `depends_on` が healthcheck を見ていない | `condition: service_healthy` + healthcheck を設定 |
| コード変更が反映されない | イメージがキャッシュされている | `--build` フラグで再ビルド |
| 環境変数が反映されない | `.env` ファイルがない or タイポ | `docker compose config` で展開後の設定を確認 |
| ポート競合でエラー | ホスト側のポートが使用中 | `lsof -i :5432` で確認してプロセスを停止 |
| ボリュームの権限エラー | UID が異なる | `user: "${UID}:${GID}"` を service に追加 |
