.# Dockerfile からイメージを作成

## 概要

Dockerfileを使用してカスタムイメージを作成することは、アプリケーションの環境を標準化し再現可能にするDockerの基本的な機能です。

## 主要概念

Dockerfileはテキストファイルで、イメージを構築するための一連の指示を含み、これを基にDockerエンジンが自動的にイメージをビルドします。

## docker image build コマンド

`docker image build`コマンド（または短縮形の`docker build`）を使用して、Dockerfileからイメージを作成します。

### 基本的な構文

```bash
docker image build [オプション] パス
```

または

```bash
docker build [オプション] パス
```

ここで「パス」はDockerfileが置かれているディレクトリを指します。

### 主要オプション

- `-t, --tag`: イメージ名とタグを指定します
- `-f, --file`: デフォルト名(`Dockerfile`)以外のファイル名を使用する場合に指定します
- `--no-cache`: キャッシュを使用せずに構築します
- `--pull`: 常に最新のベースイメージをダウンロードします

### 基本的な使用例

#### 現在のディレクトリにあるDockerfileからイメージを構築

```bash
docker image build -t アプリ名:タグ名 .
```

`.`は現在のディレクトリを指します。このコマンドは現在のディレクトリにあるDockerfileを使用してイメージを構築します。

#### 別のディレクトリにあるDockerfileからイメージを構築

```bash
docker image build -t アプリ名:タグ名 ./path/to/directory
```

#### 別名のDockerfileを使用

```bash
docker image build -t アプリ名:タグ名 -f MyDockerfile .
```

#### 常に最新のベースイメージを使用

```bash
docker image build --pull -t アプリ名:タグ名 .
```

### ビルドコンテキスト

`docker build`コマンドの最後に指定するパスは「ビルドコンテキスト」と呼ばれます。このディレクトリ内のファイルがビルドプロセス中にDockerデーモンに送信されます。

大きなディレクトリをビルドコンテキストとして使用する場合、不要なファイルが含まれていると転送時間が長くなるため、`.dockerignore`ファイルを使用して不要なファイルを除外することをお勧めします。

### ビルドキャッシュ

Docker はビルドプロセスを高速化するためにキャッシュを使用します。各Dockerfileの命令は、以前のビルドから再利用できるかチェックされます。

キャッシュを無効にする場合は `--no-cache` オプションを使用します：

```bash
docker image build --no-cache -t アプリ名:タグ名 .
```

### マルチステージビルド

複数のステージを持つDockerfileを使用して、ビルド環境と実行環境を分離し、最終的なイメージサイズを小さくすることができます。

```dockerfile
# ビルドステージ
FROM node:14 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# 実行ステージ
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### よくあるエラーと対処法

#### コンテキストアクセスエラー

エラー例：`Forbidden path outside the build context`

対処法：Dockerfileからアクセスできるのはビルドコンテキスト内のファイルのみです。ビルドコンテキストを適切に設定してください。

#### ベースイメージ問題

エラー例：`pull access denied` または `repository does not exist`

対処法：イメージ名が正しいか、認証が必要なプライベートリポジトリの場合は適切にログインしているか確認してください。

#### メモリ不足エラー

エラー例：`killed` または `exited with code 137`

対処法：Docker に割り当てられているメモリを増やすか、リソースを多く消費する操作を最適化してください。

### ベストプラクティス

1. **キャッシュを活用する**：頻繁に変更されるファイルよりも、変更が少ないファイル（例：依存関係定義）を先にコピーすることでビルド時間を短縮できます。

2. **レイヤー数を最小化する**：RUN 命令はレイヤーを作成するため、複数のコマンドを `&&` で結合して一つのレイヤーにまとめることが望ましいです。

3. **`.dockerignore` ファイルを使用する**：ビルドコンテキストから不要なファイルを除外します。

4. **マルチステージビルドを活用する**：最終イメージには必要なファイルのみを含めることでイメージサイズを小さくできます。

5. **明示的なタグを使用する**：`latest` タグより、バージョンを明示したタグ（例：`node:14.17`）の方が再現性が高いです。
