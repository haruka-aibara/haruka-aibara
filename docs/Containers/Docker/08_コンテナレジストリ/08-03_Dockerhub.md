# Docker Hub

`docker pull nginx` と打ったとき、どこから何が落ちてくるのか。レジストリを指定しなければ **Docker Hub**——Docker のデフォルトレジストリ——から取得している。最も使われるレジストリだからこそ、イメージの信頼性の見分け方とレート制限は知っておく必要がある。

## イメージ名の読み方

```
docker pull nginx                  # 実体: docker.io/library/nginx:latest
docker pull grafana/grafana        # docker.io/grafana(組織)/grafana
docker pull myregistry.example.com/team/app   # Docker Hub 以外はホスト名から書く
```

名前空間なし（`nginx`, `postgres`, `python`）は `library/` 配下の **Docker Official Image**。それ以外はユーザー・組織名前空間になる。

## 信頼性の3段階を見分ける

Docker Hub は誰でも push できる場なので、イメージの信頼性はピンキリ。目印は3つ：

- **Docker Official Image**：Docker 社がレビュー・維持する公式イメージ群。ベースイメージ（OS、言語ランタイム、主要ミドルウェア）はまずここから選ぶ
- **Verified Publisher**：ベンダー自身が公開している検証済みアカウント（`grafana/`, `bitnami/` 等）
- **それ以外**：一般ユーザーの公開物。タイポスクワッティング（公式に似せた名前）でマルウェア入りイメージを配る攻撃は実際に繰り返し観測されているので、**スターの数や名前の雰囲気で信頼しない**。Dockerfile が公開されているか、誰が維持しているかを確認する

社内では「ベースイメージは Official / Verified のみ、それを社内レジストリにミラーして使う」のような統制を敷くのが定石（サプライチェーン対策）。

## レート制限：CI が突然壊れる定番原因

Docker Hub は匿名ユーザーの pull に回数制限があり、上限に達すると `toomanyrequests` エラーで pull が失敗する。**共有 IP から大量に pull する CI 環境で突発的に発火する**のが典型で、「昨日まで通っていた CI が全部落ちた」の定番原因のひとつ。対策：

- CI に Docker Hub アカウントでログインさせる（認証済みは上限が上がる）
- クラウド側のミラー／pull-through cache を使う（ECR の pull through cache 等）
- 頻用イメージは自組織のレジストリに複製しておく

## push する側として

```bash
docker login
docker tag myapp:1.2.0 myaccount/myapp:1.2.0
docker push myaccount/myapp:1.2.0
```

無料プランのリポジトリは基本パブリックで、**push した瞬間に全世界に公開される**。イメージには環境変数や設定ファイルが焼き込まれがちなので、社内アプリを「とりあえず Docker Hub に」は事故のもと。業務では組織のプライベートレジストリ（[08-02](08-02_その他（ghcr、ecr、acr、gcr等）.md)）を使う。

## 参考

- [Docker Hub — Docker Docs](https://docs.docker.com/docker-hub/)
- [Docker Hub usage and limits — Docker Docs](https://docs.docker.com/docker-hub/usage/)
