# Docker講義: RUN コマンド

## 概要
RUNコマンドはDockerfile内でイメージ構築時に実行するコマンドを指定する命令で、ベースイメージにソフトウェアのインストールや設定を追加する際に不可欠です。

## 理論的説明
RUNはイメージのビルド時に実行されるシェルコマンドを定義し、実行結果が新しいレイヤーとしてイメージに追加されます。

## RUNコマンドの基本

### 構文

RUNコマンドには2つの形式があります：

1. **シェル形式**（デフォルト）:
```dockerfile
RUN コマンド パラメータ
```

2. **exec形式**:
```dockerfile
RUN ["実行ファイル", "パラメータ1", "パラメータ2"]
```

### 例

#### シェル形式の例
```dockerfile
# Ubuntuにnginxをインストール
RUN apt-get update && apt-get install -y nginx
```

#### exec形式の例
```dockerfile
# exec形式を使用してコマンドを実行
RUN ["/bin/bash", "-c", "echo '現在の日付: ' $(date)"]
```

## 現代のベストプラクティス

### 1. 目的に応じたRUNの分割と連結
状況に応じて適切に判断しましょう：

```dockerfile
# 論理的にグループ化された操作ごとに分ける例
# 依存関係のインストール
RUN apt-get update && apt-get install -y nginx

# 設定ファイルの調整
RUN sed -i 's/worker_processes 1/worker_processes auto/' /etc/nginx/nginx.conf

# ログディレクトリの準備
RUN mkdir -p /var/log/nginx && chmod 755 /var/log/nginx
```

理由：
- 分割すると開発時のキャッシュ活用が容易になります
- 関連する操作のみをグループ化すると可読性と保守性が向上します
- マルチステージビルドを使用する場合は中間イメージのレイヤー数はそれほど重要ではありません

### 2. キャッシュクリア
特にパッケージマネージャを使う場合は、キャッシュをクリアしましょう：

```dockerfile
# Ubuntuの場合
RUN apt-get update && \
    apt-get install -y some-package && \
    rm -rf /var/lib/apt/lists/*

# Alpine Linuxの場合
RUN apk add --no-cache some-package
```

### 3. マルチステージビルドの活用
最終イメージのサイズを最適化するためにマルチステージビルドを検討しましょう：

```dockerfile
# ビルドステージ
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# 実行ステージ
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

## よくある使用例

### ソフトウェアインストール
```dockerfile
# パッケージマネージャでのインストール
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    git \
    nginx \
    && rm -rf /var/lib/apt/lists/*
```

### ファイル操作
```dockerfile
# ディレクトリ作成とファイル操作
RUN mkdir -p /app/data && chmod 755 /app/data
```

### アプリケーション依存関係のインストール
```dockerfile
# Pythonパッケージインストール
RUN pip install --no-cache-dir flask requests

# Node.jsパッケージインストール
RUN npm install --production
```

## 注意点

1. **バランスの取れたアプローチ**: 
   - 開発中は個別のコマンドがキャッシュされるメリットを活かす
   - 本番環境向けの最終イメージではサイズ最適化を考慮する

2. **バージョン固定**: 再現性を確保するため、インストールするパッケージのバージョンを明示的に指定すると良いです。
```dockerfile
RUN pip install flask==2.0.1 requests==2.26.0
```

3. **可読性とメンテナンス性の重視**: 
   - 過度に長い連結コマンドは避け、論理的なグループで分割する
   - コメントで各ステップの目的を明確にする
```dockerfile
# アプリケーション実行環境のセットアップ
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*
```
