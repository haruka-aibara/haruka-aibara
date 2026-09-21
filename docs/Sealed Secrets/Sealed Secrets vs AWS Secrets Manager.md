# Sealed Secrets vs AWS Secrets Manager：AWSメインでもSealed Secretsを使う理由

## Sealed Secretsとは

[Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)は、KubernetesのSecretを暗号化してGitに安全にコミットできるようにするツール。Bitnami（現VMware/Broadcom）が開発しOSS公開している。

仕組みは単純：

1. クラスター上でコントローラーが動いており、公開鍵/秘密鍵ペアを管理する
2. `kubeseal` CLIで公開鍵を使ってSecretを暗号化 → `SealedSecret` リソースを生成
3. `SealedSecret` をGitにコミットしてOK
4. クラスターに適用されるとコントローラーが秘密鍵で復号 → 通常の `Secret` を自動生成

---

## 「AWS Secrets Managerじゃだめなの？」という疑問

だめじゃない。ただ、**用途が少し違う**。

Secrets ManagerはAWSサービス全般（Lambda、ECS、EC2、RDSなど）で使う秘密情報の中央管理に向いている。一方Sealed SecretはKubernetesのGitOpsワークフローに特化している。

---

## AWS環境でSealed Secretsを使うメリット

### 1. GitOpsと相性が抜群

ArgoCDやFlux を使っているとマニフェストはすべてGitで管理したくなる。でも普通のKubernetes Secretは平文（base64エンコードなだけ）なのでGitに上げられない。

Sealed SecretsならGitに暗号化済みの `SealedSecret` をコミットするだけで、「Gitがすべての真実」を維持できる。Secrets ManagerはGit外の管理になるのでGitOpsと相性が悪い。

```yaml
# これをGitにコミットできる（復号できるのはクラスターのみ）
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: db-credentials
  namespace: production
spec:
  encryptedData:
    password: AgBy3i4OJSWK+PiTySYZZA9rO43cGDEq...
```

### 2. IRSAの設定が不要

Secrets Managerを使う場合、EKS上のPodからアクセスするには **IRSA（IAM Roles for Service Accounts）** の設定が必要になる。

- IAMロールを作る
- Service Accountにアノテーションを付ける
- PodがそのSAを使うように設定する
- KubernetesとAWS側の両方を管理する

Sealed Secretsはクラスター内で完結するのでこれが要らない。開発者がAWS IAMを意識せずにSecretを扱える。

### 3. マルチクラスター・マルチクラウドに強い

オンプレのkubeadmクラスターやGKEなど、AWSじゃない環境にもデプロイする場合、Secrets Managerは使えない。Sealed Secretsはクラウド非依存なので同じ仕組みで動く。

### 4. 追加コストがかからない

Secrets Managerは1シークレットあたり約$0.40/月 + APIコール課金。シークレット数が増えると地味に効いてくる。Sealed SecretsはOSSで追加コストゼロ。

### 5. Podへの受け渡しがKubernetesネイティブ

Secrets Managerから値を取得するには、サイドカー（External Secrets Operator など）かアプリ側でSDKを使う実装が必要。Sealed Secretsは最終的に通常のKubernetes Secretになるので、既存のPod定義をそのまま使える。

```yaml
# 普通のSecretと同じように参照できる
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: password
```

---

## Secrets Managerのほうが向いているケース

Sealed Secretsが万能というわけではない。こういうときはSecrets Managerのほうが合っている：

| ケース | 理由 |
|---|---|
| LambdaやECS、EC2など複数のAWSサービスで同じシークレットを共有したい | Kubernetes外からは参照できない |
| シークレットの自動ローテーションが必要（DBパスワードなど） | Secrets Managerに組み込み機能がある |
| 監査ログをCloudTrailに集約したい | Secrets ManagerはCloudTrailと統合済み |
| AWSリソース（RDS/ElastiCacheなど）のパスワード管理 | マネージドサービスとの統合が楽 |
| KubernetesをほとんどつかっていないAWSシステム | 導入メリットがない |

---

## 両方使うハイブリッド構成もあり

現実的な構成として **両方使い分ける** のも普通。

```
AWS Secrets Manager
  └── RDSのマスターパスワード（ローテーション付き）
  └── サードパーティAPIキー（Lambda・ECS共用）

Sealed Secrets
  └── EKSのPodが使うシークレット（GitOps管理）
  └── TLS証明書などKubernetes専用のもの
```

ただし「External Secrets Operator」を使えばSecrets ManagerからKubernetes Secretに同期することもできる。どちらか一方に統一したい場合のオプション。

---

## まとめ

| | Sealed Secrets | AWS Secrets Manager |
|---|---|---|
| GitOps対応 | ◎ Gitに暗号化済みでコミット可 | △ Git外管理になる |
| AWS以外でも使える | ◎ クラウド非依存 | ✕ AWSのみ |
| コスト | ◎ 無料 | △ シークレット数×$0.40/月 |
| シークレットローテーション | △ 自前実装 | ◎ 組み込み |
| Kubernetes外との共有 | ✕ | ◎ |
| IRSA設定 | 不要 | 必要 |

AWSをメインで使っていても、**EKSでGitOpsしているなら**Sealed Secretsには十分な存在価値がある。「Secrets Managerでいいじゃん」は半分正解で、Kubernetesのマニフェスト管理の文脈では話が変わる。
