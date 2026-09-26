# google-cloud-hands-on

Google Cloud プロジェクトに 2000 円の予算アラートを張るモジュール。予算アラートに必要な API（Cloud Resource Manager / Billing Budget）も有効化する。

旧リポジトリ `google-cloud-hands-on` を履歴ごと取り込んだもの。過去の経緯は `git log -- modules/google-cloud-hands-on` で辿れる。

## 使い方

```hcl
module "google_cloud_hands_on" {
  source = "./modules/google-cloud-hands-on"

  project_id         = var.google_cloud_hands_on_project_id
  billing_account_id = var.google_cloud_hands_on_billing_account_id
}
```

呼び出し側に `google` プロバイダーが要る。認証情報はワークスペースの環境変数 `GOOGLE_CREDENTIALS` から読ませる。
