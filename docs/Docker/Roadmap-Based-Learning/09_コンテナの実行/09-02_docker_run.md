# Docker Container講義

## コンテナの概要と重要性
Dockerコンテナはアプリケーションとその依存関係をひとまとめにした軽量な実行環境で、開発環境と本番環境の一貫性を保証します。

## コンテナの主要概念
コンテナはDockerイメージのインスタンスであり、分離された環境でプロセスを実行する軽量な仮想化技術です。

## コンテナの基本操作

### コンテナの起動 (docker container run)

```bash
# 基本的なコンテナ起動コマンド
docker container run <イメージ名>

# 例: Nginxコンテナを起動
docker container run nginx

# バックグラウンドで実行 (-d オプション)
docker container run -d nginx

# ポートマッピング (-p オプション)
docker container run -d -p 8080:80 nginx

# コンテナに名前をつける (--name オプション)
docker container run -d --name my-nginx nginx

# 環境変数を設定 (-e オプション)
docker container run -e MYSQL_ROOT_PASSWORD=password -d mysql

# ボリュームマウント (-v オプション)
docker container run -v /host/path:/container/path -d nginx
```

### コンテナの一覧表示 (docker container ls)

```bash
# 実行中のコンテナのみ表示
docker container ls

# すべてのコンテナを表示 (-a オプション)
docker container ls -a

# コンテナIDのみ表示 (-q オプション)
docker container ls -q

# フィルターを適用 (--filter オプション)
docker container ls --filter "status=running"
docker container ls --filter "name=nginx"

# サイズ情報を表示 (-s オプション)
docker container ls -s
```

## 実行例と出力結果

### docker container run の実行例
```bash
$ docker container run -d -p 8080:80 --name web-server nginx
a72d44d45f9b89e861e7e28a58311cf633607c123a641019f979a3e41d140a5c
```

### docker container ls の実行例
```bash
$ docker container ls
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                  NAMES
a72d44d45f9b   nginx     "/docker-entrypoint.…"   5 seconds ago   Up 3 seconds   0.0.0.0:8080->80/tcp   web-server
```

## よくある問題とトラブルシューティング

- **エラー: ポートがすでに使用されています**  
  別のコンテナまたはホストプロセスが既にそのポートを使用しています。別のポート番号を指定してください。

- **コンテナがすぐに終了する**  
  フォアグラウンドプロセスがないコンテナは終了します。-d オプションを使用するか、インタラクティブシェル(-it オプション)を使用してください。

- **権限エラー**  
  Dockerコマンドの実行には管理者権限が必要な場合があります。`sudo` を使用するか、ユーザーをdockerグループに追加してください。
