# Docker コンテナのクリーンアップ: prune / --rm / rm -f

## 概要
Dockerコンテナの適切なクリーンアップは、ディスク容量の管理とシステムリソースの最適化に不可欠です。

## 理論的説明
Dockerは停止したコンテナを自動的に削除せず、明示的なクリーンアップコマンドが必要です。

## docker container prune

`docker container prune`コマンドは、停止状態のすべてのコンテナを一括で削除します。

```bash
# すべての停止中コンテナを削除
docker container prune

# 確認なしで削除する場合
docker container prune -f
```

**使用例:**
```
$ docker container prune
WARNING! This will remove all stopped containers.
Are you sure you want to continue? [y/N] y
Deleted Containers:
9c52f3787b16
75fb401da7c3

Total reclaimed space: 27.5MB
```

**注意点:**
- 実行中のコンテナには影響しません
- 一度削除したコンテナは復元できません
- `-f`オプションを使うと確認なしで削除します

## docker container run --rm

`--rm`フラグは、コンテナ実行後に自動的にコンテナを削除するオプションです。

```bash
# コンテナ終了後に自動削除
docker container run --rm ubuntu ls
```

**使用例:**
```
$ docker container run --rm ubuntu ls
bin
boot
dev
etc
home
lib
...
```

**利点:**
- 一時的な作業に最適
- コンテナの後片付けが自動化される
- システムリソースを無駄に消費しない

## docker container rm -f

`docker container rm -f`コマンドは、実行中のコンテナを強制的に停止して削除します。

```bash
# 実行中のコンテナを強制削除
docker container rm -f container-id
```

**使用例:**
```
$ docker container ls
CONTAINER ID   IMAGE     COMMAND   ...
abc123def456   nginx     "/docker-entrypoint.…"   ...

$ docker container rm -f abc123def456
abc123def456
```

**注意点:**
- `-f`（force）フラグがなければ実行中のコンテナは削除できない
- 実行中プロセスが強制終了するので、データ損失の可能性がある
- 複数のコンテナIDを指定して一括削除も可能
