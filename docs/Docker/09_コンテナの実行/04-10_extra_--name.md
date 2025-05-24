# Docker コンテナの名前付け (--name)

## 概要
`--name` パラメータはコンテナに識別しやすい名前を割り当てるためのもので、コンテナ管理を効率化します。

## 理論的説明
Docker はコンテナ起動時にランダムな名前を自動生成しますが、`--name` オプションを使用することで明示的に名前を指定できます。

## 使用方法

```bash
docker container run --name test1 image
```

上記のコマンドでは:
- `sudo`: 管理者権限でコマンドを実行
- `docker container run`: コンテナを起動するコマンド
- `--name test1`: コンテナに「test1」という名前を付ける
- `image`: 使用するDockerイメージ名

## メリット

- コンテナの識別が容易になる
- 他のコマンドでコンテナIDの代わりに名前が使用できる
- CI/CDパイプラインなどの自動化に役立つ

## 注意点

- 同じ名前のコンテナは作成できない
- 既に同じ名前のコンテナが存在する場合はエラーになる
- コンテナ削除後は同じ名前を再利用できる

## 例: 名前を使ったコンテナ操作

```bash
# コンテナの停止
docker container stop test1

# コンテナの再起動
docker container restart test1

# コンテナの削除
docker container rm test1
```
