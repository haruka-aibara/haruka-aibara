# Kubernetes

compose で複数コンテナは動かせる。ではなぜ Kubernetes が要るのか——答えは「**複数のホストにまたがって**、コンテナを宣言どおりの状態に保ち続けたい」から。1台で足りるうちは要らない、という裏返しでもある。

## Docker（compose）との役割の違い

compose は「1台のホストで複数コンテナを定義どおり起動する」道具。対して Kubernetes は：

- **複数ノードへの配置**：どのサーバーで動かすかをスケジューラが決める。ノードが死ねば別ノードで起動し直す
- **宣言的な自己修復**：「このイメージのレプリカを3つ」という**あるべき状態**を宣言すると、現実をそこに収束させ続ける（コンテナが死んだら勝手に補充）
- **サービスディスカバリと負荷分散**：レプリカ群への振り分け、ローリングアップデート、オートスケールが組み込み

Docker 学習との接続で言えば、**イメージ・レジストリ・コンテナの概念はそのまま通用する**。Pod（コンテナの最小配置単位）の中で動いているのは同じ OCI イメージで、ランタイムが containerd に変わるだけ（[01-04](../01_Docker_イントロダクション/01-04_DockerとOCI.md)）。compose の service 定義の感覚は Deployment + Service にほぼ写像できる。

## 最小の語彙

- **Pod**: 1個以上のコンテナの組。K8s が起動・停止する単位
- **Deployment**: 「この Pod を N 個維持せよ」という宣言。ローリングアップデートもここ
- **Service**: Pod 群への安定した接続口（Pod は使い捨てで IP が変わるため）
- **Ingress / Gateway**: 外からの HTTP(S) をどの Service に流すかのルーティング

```yaml
apiVersion: apps/v1
kind: Deployment
metadata: { name: api }
spec:
  replicas: 3
  selector: { matchLabels: { app: api } }
  template:
    metadata: { labels: { app: api } }
    spec:
      containers:
        - name: api
          image: 123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/myapp:a1b2c3d
          resources:
            limits: { memory: 512Mi, cpu: "1" }
```

compose との対応（image、resources ≒ --memory/--cpus）が見えれば、学習の連続性がわかる。

## 採用判断：本当に要るか

Kubernetes は強力さと引き換えに運用コストが大きい（クラスタのバージョンアップ、ネットワーク・権限モデル、監視の複雑さ）。実務の分岐はだいたい：

- 単一ホスト・小規模 → compose ＋ [PaaS](13-01_PaaSオプション.md)
- AWS 内で「複数コンテナをちゃんと運用」→ ECS/Fargate が Kubernetes より低コストな中間解
- マルチチーム・大規模・エコシステム（Helm、ArgoCD、service mesh）が必要 → EKS 等のマネージド Kubernetes

「業界標準だから」で選ぶと運用で支払うことになる。詳細な学習は `Kubernetes/` を参照。

## 参考

- [Kubernetes Documentation — kubernetes.io](https://kubernetes.io/docs/concepts/overview/)
- [Amazon EKS — AWS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
