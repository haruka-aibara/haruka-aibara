# Argo CD とは

## こういう場面で困っていないか

Kubernetes クラスターへのデプロイを CI パイプラインから `kubectl apply` で行っているとき、こんな問題が起きやすい。

- CI に本番クラスターへの kubeconfig を持たせる必要がある（クレデンシャルの管理が面倒）
- 誰かがローカルから直接 `kubectl apply` して、Git と本番がズレる
- 「今クラスターに何がデプロイされているか」を確認するには、クラスターに聞くしかない

Argo CD はこの問題を「クラスター内に常駐するエージェントが Git を監視して、自分で同期する」という構造で解決する。

---

## Argo CD が何をするか

Git リポジトリに書かれた Kubernetes マニフェストの状態と、実際のクラスターの状態を**常時比較して同期するエージェント**。

```
[開発者] → PR → マージ → [Git リポジトリ]
                                ↑ 常時監視
                         [Argo CD（クラスター内）]
                                ↓ 同期
                         [Kubernetes クラスター]
```

CI から `kubectl apply` を叩く必要がなくなる。クラスターへの変更は Git を経由することが強制される。

---

## HCP Terraform との対比で理解する

Terraform を触ったことがあるなら、「Kubernetes 版の HCP Terraform」と理解するのが早い。

| | HCP Terraform | Argo CD |
|---|---|---|
| 対象 | Terraform コード | Kubernetes マニフェスト |
| やること | Git の状態を AWS/GCP 等に apply | Git の状態をクラスターに sync |
| ドリフト検知 | plan で差分表示 | 常時監視して UI で可視化 |
| 自動修正 | 基本しない（手動 apply） | 設定次第で自動 sync |
| エージェント位置 | 外部サービス（Terraform Cloud） | クラスター内に常駐 |

大きく違うのは最後の行。Argo CD はクラスターの**中**で動くため、外部から直接クラスターを操作する仕組みが不要になる。

---

## Sync Policy：自動か手動か

Argo CD には「Git が更新されたら自動で同期するか」を設定できる。

**手動 sync（デフォルト）**
Git にマージされても自動適用はしない。Argo CD の UI または CLI で sync を実行する。本番環境など、意図せず変更が入ると困る場合に向いている。

**自動 sync**
Git の変更を検知したら自動でクラスターに適用する。開発・ステージング環境など、素早く反映したい場合に向いている。

また、**Self Heal** という設定を有効にすると、誰かがクラスターを直接変更してもArgo CD が Git の状態に戻す。「kubectl apply 禁止」を技術的に強制したい場合に使う。

---

## Application リソース

Argo CD の基本単位は `Application` というカスタムリソース。「どの Git リポジトリのどのパスを、どのクラスターのどの namespace に適用するか」を定義する。

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/example/k8s-manifests
    targetRevision: main
    path: apps/my-app
  destination:
    server: https://kubernetes.default.svc
    namespace: my-app
  syncPolicy:
    automated:
      prune: true      # Git から消えたリソースをクラスターからも削除
      selfHeal: true   # クラスターの直接変更を Git の状態に戻す
```

---

## Helm・Kustomize との関係

マニフェストをそのまま Git に置くだけでなく、Helm chart や Kustomize との組み合わせが一般的。

- **Helm**: `values.yaml` だけ環境ごとに差し替えて、chart は共通化
- **Kustomize**: base + overlay 構成で dev/staging/prod の差分を管理

Argo CD はどちらも標準でサポートしており、`source.helm` または `source.kustomize` で設定できる。

---

## まず何をやるか

1. Kubernetes マニフェストを Git リポジトリで管理する
2. Argo CD をクラスターにインストールする（`kubectl apply` または Helm）
3. `Application` リソースを作成して、Git リポジトリと紐づける
4. UI でクラスターの同期状態を確認する

最初は手動 sync から始めて、動作を確認してから自動 sync に切り替えるのが安全。

---

## 参考

- [Argo CD 公式ドキュメント](https://argo-cd.readthedocs.io/en/stable/)
- [Argo CD - Getting Started](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- [Application CRD リファレンス](https://argo-cd.readthedocs.io/en/stable/operator-manual/application.yaml)
