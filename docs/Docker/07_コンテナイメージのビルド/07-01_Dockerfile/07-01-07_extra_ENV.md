# Docker講義: ENV

## 概要
ENVはDockerfileで環境変数を設定するための命令で、コンテナ内のアプリケーション設定を柔軟に管理できます。

## 理論的説明
環境変数はコンテナ実行時に参照される名前と値のペアで、アプリケーションの動作をコードを変更せずに制御できます。

## ENVの基本構文

Dockerfileでの記述方法には2つの形式があります：

```dockerfile
# 形式1: 一つの環境変数を設定
ENV 変数名 値

# 形式2: 複数の環境変数を一度に設定
ENV 変数名1=値1 変数名2=値2
```

## ENVの使用例

### 基本的な例
```dockerfile
FROM ubuntu:20.04
# データベース接続情報を環境変数として設定
ENV DB_HOST=localhost
ENV DB_PORT=5432
ENV DB_USER=admin
ENV DB_PASSWORD=password

# 複数の変数を一行で設定する例
ENV APP_HOME=/app APP_ENV=production DEBUG=false
```

### 環境変数の利用

コンテナ内では設定した環境変数を以下のように利用できます：

1. シェルで参照：
```bash
echo $DB_HOST        # localhost と表示される
```

2. Dockerfileの他の命令内で参照：
```dockerfile
ENV APP_HOME=/app
WORKDIR $APP_HOME    # /app ディレクトリを作業ディレクトリに設定
```

## ENVのベストプラクティス

- **機密情報は避ける**: パスワードなどの機密情報はENVに直接書かず、ビルド時の引数（ARG）やDocker Secretsを使用しましょう。

- **デフォルト値の設定**: 開発環境と本番環境で異なる値を使用する場合は、ENVでデフォルト値を設定しておくと便利です。

- **グループ化**: 関連する環境変数はまとめて定義し、コメントで説明を追加すると管理しやすくなります。

## ENVとARGの違い

| ENV | ARG |
|-----|-----|
| コンテナ実行時も使用可能 | ビルド時のみ使用可能 |
| Dockerfileと実行コンテナ内で有効 | Dockerfileのみで有効 |
| `docker run -e` で上書き可能 | `docker build --build-arg` で上書き可能 |

## 実行時の環境変数上書き

コンテナ起動時に環境変数を上書きするには：

```bash
# 単一の環境変数を上書き
docker run -e DB_HOST=production-db コンテナ名

# 複数の環境変数を上書き
docker run -e DB_HOST=production-db -e DB_PORT=5433 コンテナ名

# 環境変数ファイルから読み込む
docker run --env-file ./env.list コンテナ名
```

## ENVの活用シナリオ

- **アプリケーション設定**: データベース接続情報、APIキー、ログレベルなど
- **言語設定**: `LANG=ja_JP.UTF-8` などでロケールを設定
- **パス設定**: `PATH=/usr/local/bin:$PATH` などで実行パスを追加
- **プロキシ設定**: `HTTP_PROXY`, `HTTPS_PROXY` などのネットワーク設定
