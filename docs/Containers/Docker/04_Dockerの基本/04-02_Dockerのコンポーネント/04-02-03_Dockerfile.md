# Dockerfileとは

Dockerfileは、Dockerイメージを自動的に構築するためのテキストファイルで、アプリケーション環境の再現性と移植性を高めるための重要な要素です。

Dockerfileは、ベースイメージの指定から始まり、一連のコマンド（命令）を通じて環境構築の手順を定義するテキスト形式の設計図です。

## Dockerfileの基本構造

Dockerfileは以下のような基本構造を持っています：

```dockerfile
# ベースイメージの指定
FROM イメージ名:タグ

# 作成者情報（オプション）
MAINTAINER 作成者名 <メールアドレス>

# 環境変数の設定
ENV キー 値

# 作業ディレクトリの設定
WORKDIR パス

# ファイルのコピー
COPY ソースパス 宛先パス

# コマンドの実行
RUN コマンド

# ポートの公開
EXPOSE ポート番号

# コンテナ起動時に実行されるコマンド
CMD ["実行コマンド", "引数1", "引数2"]
```

## 主要な命令（インストラクション）

### FROM
- 必ず最初に記述する命令
- ベースとなるイメージを指定する
- 例：`FROM ubuntu:20.04`

### RUN
- イメージ構築時に実行するコマンド
- シェルコマンドを実行してイメージにレイヤーを追加する
- 例：`RUN apt-get update && apt-get install -y nginx`

### COPY
- ホストマシンからコンテナ内にファイルやディレクトリをコピーする
- 例：`COPY ./app /usr/src/app`

### ADD
- COPYと似ているが、追加機能がある
- tarアーカイブの自動展開やURLからのダウンロードが可能
- 例：`ADD https://example.com/file.tar.gz /tmp/`

### WORKDIR
- 以降の命令が実行される作業ディレクトリを設定する
- 例：`WORKDIR /usr/src/app`

### ENV
- 環境変数を設定する
- 例：`ENV NODE_ENV production`

### EXPOSE
- コンテナがリッスンするポートを指定する
- 例：`EXPOSE 80`

### CMD
- コンテナ起動時に実行されるコマンドを指定する
- Dockerfileで1つだけ有効（複数あると最後のものだけが有効）
- 例：`CMD ["nginx", "-g", "daemon off;"]`

### ENTRYPOINT
- コンテナ起動時に実行されるコマンドを指定する
- CMDと組み合わせることができる
- 例：`ENTRYPOINT ["npm", "start"]`

## Dockerfileのベストプラクティス

### 1. マルチステージビルドの活用
- 複数のFROM命令を使ってビルド環境と実行環境を分離する
- 最終イメージのサイズを小さくできる

```dockerfile
# ビルドステージ
FROM node:14 AS build
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
RUN npm run build

# 実行ステージ
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### 2. レイヤーの最適化
- RUN命令を連結して使用する（`&&`で結合）
- 不要なファイルを削除する
- 例：`RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*`

### 3. .dockerignoreファイルの使用
- 不要なファイルをビルドコンテキストから除外する
- イメージサイズの削減とビルド時間の短縮に役立つ

## Dockerfileからイメージを構築する

```bash
# 基本的なビルドコマンド
docker build -t イメージ名:タグ Dockerfileのあるディレクトリパス

# 例
docker build -t myapp:1.0 .
```

## Dockerfileの実践例

### Webアプリケーション（Node.js）の例

```dockerfile
FROM node:14-alpine

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "app.js"]
```

### Pythonアプリケーションの例

```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
```
