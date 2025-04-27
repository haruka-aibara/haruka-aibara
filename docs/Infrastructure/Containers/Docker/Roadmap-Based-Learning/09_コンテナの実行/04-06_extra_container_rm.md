# Docker コンテナの削除

Dockerコンテナは、アプリケーションとその依存関係を含む軽量な実行環境であり、異なる環境間での一貫した動作を保証します。

`docker container rm`コマンドは、不要になったコンテナを削除するために使用されるDockerの基本的なコマンドです。

## コマンド構文

```
docker container rm [オプション] コンテナID/コンテナ名 [コンテナID/コンテナ名...]
```

## 主なオプション

- `-f, --force`: 実行中のコンテナを強制的に削除します
- `-v, --volumes`: コンテナに関連付けられた匿名ボリュームも削除します
- `-l, --link`: 指定したリンクを削除します

## 基本的な使用例

### 単一のコンテナを削除する

```bash
docker container rm コンテナID
```

または

```bash
docker container rm コンテナ名
```

### 複数のコンテナを削除する

```bash
docker container rm コンテナID1 コンテナID2 コンテナID3
```

### 実行中のコンテナを強制的に削除する

```bash
docker container rm -f コンテナID
```

### コンテナと関連する匿名ボリュームを削除する

```bash
docker container rm -v コンテナID
```

## 注意点

- 実行中のコンテナは`-f`オプションなしでは削除できません
- 削除されたコンテナは元に戻せません
- コンテナを削除しても、コンテナから作成されたイメージは削除されません
- 名前付きボリュームは`-v`オプションを使用しても自動的には削除されません

## 実践例

1. すべての停止中のコンテナを削除する：
```bash
docker container prune
```
または
```bash
docker container rm $(docker container ls -aq -f status=exited)
```

2. 特定のパターンに一致するコンテナを削除する：
```bash
docker container rm $(docker container ls -a | grep "パターン" | awk '{print $1}')
```

## エラー対処

- **コンテナが見つからない場合**：コンテナ名またはIDが正しいか確認します
- **実行中のコンテナを削除できない場合**：`-f`オプションを使用するか、先に`docker container stop`で停止させてから削除します
- **ボリュームが削除できない場合**：名前付きボリュームは`docker volume rm`コマンドで個別に削除する必要があります
