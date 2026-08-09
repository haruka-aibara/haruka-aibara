# Docker

「手元では動くのに本番で動かない」。依存ライブラリ、OS のバージョン、環境変数——環境差異は再現困難なバグの温床で、これを「アプリと依存物一式を1個の不変なイメージに焼き固めて、どこでも同じものを動かす」ことで潰すのが Docker の存在意義。この章の締めくくりとして、これまでの部品（namespace・cgroups・ランタイム）が Docker でどう組み上がっているかを見る。

## VM ではなくプロセス

Docker コンテナは**ホストのカーネルを共有する隔離されたプロセス**。ゲスト OS を丸ごと起動する VM と違い、起動は秒未満・オーバーヘッドはほぼゼロ。隔離の実体はこれまで見てきたカーネル機能で：

- 視界の隔離 = namespaces（コンテナ内では自分が PID 1 に見える）
- 量の制限 = cgroups（`--memory` `--cpus` の実体）
- 実行 = containerd + runc（[16-03](16-03_コンテナランタイム.md)）

ホスト側から `ps aux` すればコンテナ内のプロセスが普通に見える。「カーネルを共有している」ことは、後述のセキュリティの話の前提にもなる。

## 最低限の操作セット

```bash
docker run -d -p 8080:80 --name web nginx   # イメージ取得〜起動まで一発
docker ps                                    # 動いているコンテナ
docker logs -f web                           # ログ（stdout に吐くのがコンテナの流儀）
docker exec -it web bash                     # 動いているコンテナに入って調査
docker stop web && docker rm web             # 停止と削除
```

イメージは Dockerfile でコードとして定義する：

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
USER nobody
CMD ["python", "app.py"]
```

`docker build -t myapp .` でイメージ化。環境構築手順書が Dockerfile というレビュー可能なコードに置き換わる——これが「Infrastructure as Code」のアプリ版としての Docker の価値。

## セキュリティ：既定値のままにしない3点

コンテナは「隔離されているから安全」ではない。カーネル共有という構造上、押さえるべき定番がある：

- **root で動かさない**: コンテナ内の root は、エスケープ時にホストの root に化け得る。Dockerfile に `USER` を書く（上の例の `USER nobody`）
- **イメージの出所と中身**: base イメージは公式・最小(slim/alpine)を選び、ECR の イメージスキャン や Trivy で既知脆弱性を検査してから配る。「動いたからOK」で古い base を焼き込むと、脆弱性ごと不変イメージ化されて配布される
- **`--privileged` と docker.sock マウントは実質ホスト root 献上**: 「とりあえず privileged で動いたからヨシ」は、隔離を自分で全部外した状態。CI ツール等が要求してきたら本当に必要か疑う

## 参考

- [Docker overview — Docker Docs](https://docs.docker.com/get-started/docker-overview/)
- [Dockerfile reference — Docker Docs](https://docs.docker.com/reference/dockerfile/)
- [Docker security — Docker Docs](https://docs.docker.com/engine/security/)
- [Amazon ECR image scanning — AWS Documentation](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html)
