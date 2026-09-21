# Docker講義: execコマンド

## 概要
Docker execコマンドは実行中のコンテナ内でコマンドを実行するための機能で、デバッグやメンテナンス作業に不可欠です。

## 基本概念
execコマンドはコンテナの外部から、稼働中のコンテナ内部でコマンドを実行するためのインターフェースを提供します。

## コマンドの基本構文

### 基本的な使い方
```
docker container exec <コンテナID> <実行したいコマンド>
```

実行例:
```
docker container exec 7dc9a37e54cb ls -la
```
このコマンドでは、指定したコンテナ内で「ls -la」コマンドを実行し、結果を表示します。

### インタラクティブモード
```
docker container exec -it <コンテナID> <実行したいコマンド>
```

オプション説明:
- `-i`: インタラクティブモードを有効にします（標準入力を開いたままにする）
- `-t`: 疑似TTY（ターミナル）を割り当てます

実行例:
```
docker container exec -it 7dc9a37e54cb /bin/bash
```
このコマンドでは、コンテナ内でシェル（/bin/bash）を起動し、対話的に操作できるようになります。

## 使用例
- コンテナ内のファイル確認：`docker container exec mycontainer ls /app`
- コンテナ内のデータベースに接続：`docker container exec -it mysql-container mysql -u root -p`
- 設定ファイルの編集：`docker container exec -it nginx-container vi /etc/nginx/nginx.conf`
