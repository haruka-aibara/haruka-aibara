# HCP Terraform から Google Cloud へデプロイするときの認証

## 問題

HCP Terraform でリモート実行（Remote Execution）を使うと、plan/apply はクラウド上のエフェメラルなコンテナで動く。ローカルの `~/.config/gcloud` も `terraform.tfvars` も、そこには存在しない。

「じゃあ GCP への認証情報をどう渡すか」がこのページのテーマ。

---

## 解決策：HCP Terraform の Sensitive Variable に登録する

HCP Terraform のワークスペースに環境変数として `GOOGLE_CREDENTIALS` を登録すると、plan/apply の実行時に自動で注入される。Google Provider はこの環境変数を見て認証する。

### 手順

**1. サービスアカウントと JSON キーを作る**

```bash
gcloud iam service-accounts create terraform-sa \
  --project=YOUR_PROJECT_ID

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/editor"

gcloud iam service-accounts keys create terraform-sa-key.json \
  --iam-account=terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

権限は `roles/editor` より必要なロールだけに絞るのが望ましい。

**2. HCP Terraform のワークスペースに変数を登録する**

- Variables → Add variable
- Key: `GOOGLE_CREDENTIALS`
- Value: `terraform-sa-key.json` の中身をまるごとペースト
- Category: **Environment variable**
- Sensitive: **必ずチェック**（以後 UI から値は見えなくなる）

**3. Terraform コードは特に変更不要**

```hcl
provider "google" {
  project = var.project_id
  region  = "asia-northeast1"
  # credentials は GOOGLE_CREDENTIALS 環境変数から自動で読まれる
}
```

---

## 複数ワークスペースで同じ認証情報を使うなら Variable Sets

dev/staging/prod で同じサービスアカウントを使う場合、ワークスペースごとに変数を登録するのは面倒。Variable Sets を使うと一元管理できる。

Settings → Variable Sets → Create variable set → 変数を追加 → 対象ワークスペースを選択

---

## よくあるエラー

| エラー | 原因と対処 |
|--------|-----------|
| `invalid_grant` / 認証エラー | JSON の改行が崩れている。ファイルをそのままペーストしているか確認 |
| `Permission denied` | サービスアカウントに必要なロールが付いていない |
| 変数が効かない | Category が `Terraform variable` になっている。`Environment variable` に直す |

---

## JSON キーを使いたくない場合

サービスアカウントキー（長期間有効なクレデンシャル）はリスクがある。Workload Identity Federation を使えばキーレスで認証できる。HCP Terraform の場合は TFC の OIDC トークンを使った方法がある（設定はやや複雑）。
