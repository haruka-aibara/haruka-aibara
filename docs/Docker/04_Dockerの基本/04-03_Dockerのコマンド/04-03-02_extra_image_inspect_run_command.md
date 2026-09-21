# Docker Image講義

## イメージの概要と重要性
Docker Imageはコンテナを作成するための読み取り専用テンプレートであり、アプリケーションとその依存関係を一つのパッケージにまとめることで、環境に依存しない実行を可能にします。

## 主要概念の理論的説明
Docker Imageは複数の読み取り専用レイヤーの積み重ねで構成され、各レイヤーはDockerfileの命令によって作成された変更を表現します。

## docker image inspect コマンド
`docker image inspect`コマンドはイメージの詳細情報を確認するために使用します。

### 基本的な使い方
```bash
# イメージIDまたはイメージ名を指定してイメージの詳細情報を表示
docker image inspect [イメージID/イメージ名]
```

### 出力のフィルタリング
```bash
# --format オプションで特定の情報だけを抽出
docker image inspect --format='{{.Config.Env}}' [イメージID]
docker image inspect --format='{{json .Config}}' [イメージID]
```

### 主な確認項目
- イメージレイヤー構造
- 環境変数設定
- コンテナ起動時のデフォルトコマンド
- ボリュームマウントポイント
- ネットワーク設定

## docker container run image-id command
`docker container run`コマンドは指定したイメージからコンテナを作成して実行します。

### 基本的な使い方
```bash
# イメージIDを指定してコンテナを起動し、指定したコマンドを実行
docker container run [イメージID] [コマンド]
```

### よく使用するオプション
```bash
# バックグラウンドで実行
docker container run -d [イメージID] [コマンド]

# コンテナの名前を指定
docker container run --name my-container [イメージID] [コマンド]

# ポートフォワーディング
docker container run -p 8080:80 [イメージID] [コマンド]

# 環境変数の設定
docker container run -e "VAR=value" [イメージID] [コマンド]
```

### 使用例
```bash
# Ubuntuイメージからコンテナを起動し、echoコマンドを実行
docker container run ubuntu echo "Hello Docker"

# Nginxイメージからコンテナをバックグラウンドで起動し、ポート80を8080にマッピング
docker container run -d -p 8080:80 nginx
```

### コマンドの上書き
イメージのデフォルトコマンドは`docker container run`の最後に指定したコマンドで上書きされます。これにより、同じイメージから異なる目的のコンテナを柔軟に作成できます。
