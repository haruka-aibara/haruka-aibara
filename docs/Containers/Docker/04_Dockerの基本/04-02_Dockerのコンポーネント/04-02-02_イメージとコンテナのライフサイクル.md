# Dockerイメージとコンテナのライフサイクル

## 概要
Dockerイメージとコンテナのライフサイクルを理解することは、効率的なコンテナ管理と運用の基礎となります。

## イメージとコンテナの基本概念
イメージはアプリケーションとその依存関係を含む読み取り専用のテンプレートであり、コンテナはそのイメージの実行可能インスタンスです。

## イメージの入手
イメージを入手する方法は主に以下の2つがあります：

### 1. Docker Hubからのプル
```bash
docker pull イメージ名[:タグ]
```
例：
```bash
docker pull nginx:latest
```

### 2. Dockerfileからのビルド
```bash
docker build -t イメージ名[:タグ] パス
```
例：
```bash
docker build -t myapp:1.0 .
```

## コンテナのステータス

### 1. created
コンテナが作成されたが、まだ起動していない状態です。

```bash
# コンテナを作成するが起動しない
docker create --name mycontainer nginx:latest

# createdステータスのコンテナを確認
docker ps -a | grep created
```

### 2. up（実行中）
コンテナが実行中の状態です。

```bash
# コンテナを起動する
docker start mycontainer
# または新規に実行する
docker run --name newcontainer -d nginx:latest

# 実行中(up)のコンテナを確認
docker ps
```

### 3. exited（停止）
コンテナが実行を完了または停止した状態です。

```bash
# 実行中のコンテナを停止
docker stop mycontainer

# exitedステータスのコンテナを確認
docker ps -a | grep Exited
```

## ライフサイクル管理コマンド

### コンテナの詳細情報確認
```bash
docker inspect コンテナID/コンテナ名
```

### コンテナのログ確認
```bash
docker logs コンテナID/コンテナ名
```

### 不要なコンテナの削除
```bash
# 停止中のコンテナを削除
docker rm コンテナID/コンテナ名

# 強制削除（実行中でも）
docker rm -f コンテナID/コンテナ名
```

### 不要なイメージの削除
```bash
docker rmi イメージID/イメージ名[:タグ]
```

## ステータス遷移図

```
Pull/Build → イメージ → docker create → created → docker start → up(実行中) → docker stop → exited → docker rm → 削除
                                                                 ↑                 ↓
                                                                 └─── docker restart ─┘
```
