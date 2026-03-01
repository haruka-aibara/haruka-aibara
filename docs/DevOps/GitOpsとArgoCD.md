# GitOps と ArgoCD

## 問題

CI/CD パイプラインが kubectl apply や helm upgrade を直接叩いてクラスターにデプロイする構成がよくある。これには問題がある。

- 誰かが手でクラスターを変更すると、Git との乖離（ドリフト）が検知されない
- デプロイの「正しい状態」が CI/CD ツール側にしか記録されていない
- 何かトラブルが起きたとき「今クラスターに何がデプロイされているか」が git を見ても分からない

GitOps はこれを逆転させる。**Git が唯一の真実の源（Single Source of Truth）**。パイプラインがクラスターを直接更新するのではなく、クラスター側が Git を常に監視して自分から同期する。

---

## GitOps の仕組み

```
開発者 → git push → GitHub (マニフェスト)
                          ↑ 監視
                    ArgoCD (クラスター内で動く)
                          ↓ 自動同期
                    Kubernetes クラスター
```

ArgoCD はクラスター内で動き、Git リポジトリを定期的にポーリングする。Git と現在のクラスター状態を比較して差分があれば自動で適用（または通知）する。

---

## ArgoCD の基本

### インストール

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f \
  https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Application リソース

ArgoCD の中心概念は `Application`。「どの Git リポジトリのどのパスを、どのクラスターのどの Namespace にデプロイするか」を定義する。

```yaml
# application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/myorg/myapp-manifests
    targetRevision: main
    path: k8s/production
  destination:
    server: https://kubernetes.default.svc
    namespace: myapp
  syncPolicy:
    automated:
      prune: true      # Git から削除されたリソースはクラスターからも削除
      selfHeal: true   # 手動変更を検知したら Git の状態に戻す
```

`syncPolicy.automated` を設定すると自動同期になる。設定しなければ手動承認フローにできる（本番環境向け）。

### App of Apps パターン

マイクロサービスが増えてきたら、`Application` 自体を管理する親 `Application` を作る。

```
argocd/
├── apps.yaml           ← 親 Application（これだけ手動で apply）
└── apps/
    ├── frontend.yaml   ← 各サービスの Application
    ├── backend.yaml
    └── database.yaml
```

---

## GitHub Actions との組み合わせ

CI（ビルド・テスト）は GitHub Actions、CD（デプロイ）は ArgoCD と役割を分ける。

```
GitHub Actions:
  1. テスト実行
  2. Docker イメージをビルド・push
  3. マニフェストリポジトリの image タグを更新（git push）

ArgoCD:
  4. マニフェストリポジトリの変更を検知
  5. クラスターに自動同期
```

GitHub Actions は kubectl を実行しない。マニフェストの更新（image タグ書き換え）だけをする。

---

## GitOps を使うメリット

- **監査ログが git log** — デプロイの履歴がすべて git の commit 履歴になる
- **ロールバックが git revert** — 問題が起きたら前のコミットに戻すだけ
- **ドリフト検知** — クラスターの状態が Git と乖離したら即座に通知・修正
- **クラスターへの直接アクセス権が不要** — 開発者は Git にプッシュするだけ
