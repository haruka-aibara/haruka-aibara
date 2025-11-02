# HCP Terraform での Google Cloud デプロイ: シークレット管理

HCP Terraform から Google Cloud にデプロイする際に、認証情報などの機密情報を安全に管理する方法を説明します。VCS統合やワークスペースの作成は完了していることを前提とします。

## シークレット管理の概要

HCP Terraform では、以下のような方法でシークレットを管理できます：

- **ワークスペース変数**: 変数を「Sensitive」としてマークすることで暗号化保存
- **Variable Sets**: 複数のワークスペースで共有できる変数セット
- **Google Cloud サービスアカウントキー**: GCP認証用のJSONキーファイル

## Google Cloud サービスアカウントキーの発行

### 1. Google Cloud Console でのサービスアカウント作成

```bash
# サービスアカウントの作成
gcloud iam service-accounts create terraform-sa \
  --display-name="Terraform Service Account" \
  --project=YOUR_PROJECT_ID
```

### 2. 必要な権限の付与

```bash
# 基本的な権限セット
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/editor"

# より細かい権限制御の例（必要に応じて）
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountAdmin"
```

### 3. サービスアカウントキーの生成

```bash
# JSONキーファイルの生成
gcloud iam service-accounts keys create terraform-sa-key.json \
  --iam-account=terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com \
  --project=YOUR_PROJECT_ID
```

生成された `terraform-sa-key.json` ファイルには、以下のような情報が含まれています：

```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "terraform-sa@your-project-id.iam.gserviceaccount.com",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "..."
}
```

**重要**: このファイルは機密情報を含むため、Gitリポジトリにはコミットしないでください。

## HCP Terraform へのシークレット登録

### 方法1: ワークスペース変数として登録（推奨）

#### UI での登録方法

1. HCP Terraform のワークスペースページに移動
2. 左サイドバーの「Variables」をクリック
3. 「Add variable」ボタンをクリック
4. 以下のように設定：
   - **Key**: `GOOGLE_CREDENTIALS`（Terraform変数名）
   - **Value**: JSONキーファイルの内容全体をコピー＆ペースト
   - **Type**: Terraform variable
   - **Category**: Environment variable
   - **Sensitive**: ✅ チェックを入れる（必須）
   - **Description**: （任意）「Google Cloud サービスアカウントキー」

#### サービスアカウントキーJSON全体を登録する場合

```bash
# JSONファイルの内容を取得して登録用に準備
cat terraform-sa-key.json
```

この内容全体を HCP Terraform の変数値として設定します。

### 方法2: 環境変数として分割して登録

より細かい制御が必要な場合、サービスアカウントキーを分割して登録することもできます：

- `GOOGLE_PROJECT_ID`: プロジェクトID
- `GOOGLE_CREDENTIALS`: サービスアカウントキーJSON全体
- または、`GOOGLE_APPLICATION_CREDENTIALS` として使用

### 方法3: Variable Sets を使用（複数ワークスペースで共有）

複数のワークスペースで同じ認証情報を使用する場合：

1. HCP Terraform で「Settings」→「Variable Sets」を選択
2. 「Create variable set」をクリック
3. Variable Set の名前を設定（例: `gcp-credentials`）
4. 変数を追加：
   - **Key**: `GOOGLE_CREDENTIALS`
   - **Value**: JSONキーファイルの内容
   - **Sensitive**: ✅ チェック
5. 「Add variable」をクリック
6. 「Workspaces」タブで、このVariable Setを適用するワークスペースを選択

## Terraform コードでの使用方法

### 基本的な設定

```hcl
# versions.tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# provider.tf
provider "google" {
  project = var.project_id
  region  = var.region
  # credentials は環境変数 GOOGLE_CREDENTIALS から自動的に読み込まれる
}
```

### 環境変数の参照方法

HCP Terraform で設定した環境変数は、Terraform の実行時に自動的に利用可能になります。明示的に参照する場合：

```hcl
# variables.tf
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-northeast1"
}

# GOOGLE_CREDENTIALS は環境変数として自動的に使用されるため、
# 明示的な変数定義は不要
```

### 実行時の認証フロー

1. HCP Terraform が Plan/Apply を実行
2. ワークスペース変数 `GOOGLE_CREDENTIALS` が環境変数として注入される
3. Google Provider が環境変数から認証情報を読み込む
4. Google Cloud API への認証が行われる

## 代替方法: サービスアカウントキーファイルのパス指定

JSONキーの内容ではなく、ファイルパスを使う場合（通常は推奨されません）：

```hcl
provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.google_credentials_path)
}
```

ただし、HCP Terraform の実行環境にファイルが存在しないため、この方法は使用できません。

## ベストプラクティス

### 1. 最小権限の原則

サービスアカウントには、必要な最小限の権限のみを付与：

```bash
# 例: Compute Engineのみ管理する場合
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.admin"
```

### 2. 環境ごとのサービスアカウント分離

開発・ステージング・本番環境で異なるサービスアカウントを使用：

```bash
# 開発環境用
terraform-sa-dev@project-dev.iam.gserviceaccount.com

# 本番環境用
terraform-sa-prod@project-prod.iam.gserviceaccount.com
```

### 3. キーのローテーション

定期的にサービスアカウントキーをローテーション：

```bash
# 古いキーを削除
gcloud iam service-accounts keys list \
  --iam-account=terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com

gcloud iam service-accounts keys delete KEY_ID \
  --iam-account=terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com

# 新しいキーを生成
gcloud iam service-accounts keys create terraform-sa-key-new.json \
  --iam-account=terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

生成後、HCP Terraform の変数を更新してください。

### 4. Variable Sets の活用

複数のワークスペースで同じ認証情報を使用する場合、Variable Sets を使用することで一元管理が可能です。

### 5. .gitignore の設定

サービスアカウントキーファイルが誤ってコミットされないように：

```gitignore
# .gitignore
*.json
!terraform.tfstate.json
terraform-sa-key*.json
```

## トラブルシューティング

### 認証エラーが発生する場合

1. **サービスアカウントキーの形式確認**
   - JSON形式が正しいか確認
   - 改行文字（`\n`）が正しくエスケープされているか確認

2. **権限の確認**
   ```bash
   gcloud projects get-iam-policy YOUR_PROJECT_ID \
     --flatten="bindings[].members" \
     --filter="bindings.members:serviceAccount:terraform-sa@*"
   ```

3. **HCP Terraform の変数設定確認**
   - 変数が「Sensitive」としてマークされているか
   - 変数名が正しいか（`GOOGLE_CREDENTIALS`）

4. **プロジェクトIDの確認**
   ```hcl
   # variables.tf で定義した project_id が正しいか確認
   variable "project_id" {
     type = string
   }
   ```

### 環境変数が読み込まれない場合

- HCP Terraform の実行ログで環境変数が設定されているか確認
- Variable Sets が正しくワークスペースに適用されているか確認
- 変数の「Category」が「Environment variable」になっているか確認

## まとめ

HCP Terraform で Google Cloud にデプロイする際のシークレット管理の要点：

1. **サービスアカウントキーの生成**: `gcloud` コマンドでJSONキーを生成
2. **HCP Terraform への登録**: ワークスペース変数または Variable Sets に「Sensitive」として登録
3. **Terraform コード**: `GOOGLE_CREDENTIALS` 環境変数が自動的に使用される
4. **ベストプラクティス**: 最小権限、環境分離、キーローテーション

これにより、認証情報を安全に管理しながら、HCP Terraform から Google Cloud へのデプロイが可能になります。

