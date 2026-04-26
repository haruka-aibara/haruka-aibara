<!-- Space: harukaaibarapublic -->
<!-- Parent: Google Cloud -->
<!-- Title: GCP IAM とセキュリティ -->

# GCP IAM とセキュリティ

「GCP のサービスアカウントキーを GitHub に上げてしまった」「誰に何の権限があるか把握できていない」——AWS IAM と考え方は似ているが、GCP 独自の概念を押さえないと事故を起こす。

---

## GCP の IAM モデル

| 概念 | GCP | AWS の対応 |
|---|---|---|
| 誰が | Member（アカウント・SA・グループ） | IAM User / Role |
| 何をできるか | Role（権限の集合） | Policy |
| どのリソースに | Resource（Project・Bucket等） | Resource |

**バインディング:**
```
who（誰が） + role（何をできるか） + resource（どこで）
```

---

## サービスアカウントキーを使わない——Workload Identity Federation

キーファイル（JSON）は漏洩リスクが高い。GitHub Actions や他クラウドからは Workload Identity Federation を使う。

```yaml
# GitHub Actions から GCP へ認証（キーなし）
- uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: 'projects/123/locations/global/workloadIdentityPools/github/providers/github'
    service_account: 'github-actions@myproject.iam.gserviceaccount.com'
```

GCP 側の設定:
```bash
# Workload Identity Pool の作成
gcloud iam workload-identity-pools create "github" \
  --location="global" \
  --display-name="GitHub Actions Pool"

# GitHub OIDC プロバイダーを追加
gcloud iam workload-identity-pools providers create-oidc "github" \
  --location="global" \
  --workload-identity-pool="github" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository"
```

---

## 最小権限ロールの選び方

```
基本ロール（避ける）:     Owner / Editor / Viewer
事前定義ロール（推奨）:   roles/storage.objectCreator 等
カスタムロール（必要時）: 必要な権限だけを集めて作成
```

```bash
# 事前定義ロールの一覧を確認
gcloud iam roles list --filter="name:roles/storage"

# サービスアカウントにロールをバインド（プロジェクトレベル）
gcloud projects add-iam-policy-binding myproject \
  --member="serviceAccount:myapp@myproject.iam.gserviceaccount.com" \
  --role="roles/storage.objectCreator"

# バケットレベルで絞る（推奨）
gcloud storage buckets add-iam-policy-binding gs://my-bucket \
  --member="serviceAccount:myapp@myproject.iam.gserviceaccount.com" \
  --role="roles/storage.objectCreator"
```

---

## VPC Service Controls で機密データを守る

「BigQuery のデータを外部に持ち出されたくない」——VPC Service Controls はサービス境界を作り、境界外へのデータ移動をブロックする。

```bash
# アクセスポリシーの作成
gcloud access-context-manager policies create \
  --organization=123456789 \
  --title="MyPolicy"

# サービス境界の作成（BigQuery・Cloud Storage を保護）
gcloud access-context-manager perimeters create my-perimeter \
  --policy=ACCESS_POLICY_NAME \
  --title="Data Perimeter" \
  --resources="projects/123456789" \
  --restricted-services="bigquery.googleapis.com,storage.googleapis.com"
```

---

## Security Command Center でリスクを一覧する

AWS Security Hub に相当する。misconfig・脆弱性・脅威を一元管理。

```bash
# HIGH/CRITICAL の検知結果を確認
gcloud scc findings list organizations/123456789 \
  --filter="state=ACTIVE AND severity=HIGH OR severity=CRITICAL" \
  --format="table(name,category,resourceName)"
```

有効にしておくべき検出器:
- **Security Health Analytics**: IAM・ネットワーク設定のミスを検知
- **Web Security Scanner**: App Engine・GKE の Web 脆弱性スキャン
- **Container Threat Detection**: GKE のランタイム脅威検知

---

## Cloud Audit Logs で操作を記録する

```bash
# 管理アクティビティログ（デフォルト有効・無効化不可）
# → 誰がいつ何を作成・変更・削除したか

# データアクセスログ（デフォルト無効・有効化推奨）
gcloud projects get-iam-policy myproject --format=json | \
  jq '.auditConfigs'

# BigQuery のデータアクセスを記録する
gcloud projects set-iam-policy myproject policy.json
# policy.json に auditLogConfigs: DATA_READ を追加
```

ログは Cloud Logging に 30 日保存（デフォルト）。長期保存は Cloud Storage または BigQuery にエクスポートする。
