# Terraform から Vault のシークレットを使う

## 問題

Terraform で DB や外部サービスのパスワードを扱うとき、どこに書くか迷う。

- `terraform.tfvars` に書く → Git に入れたら終わり
- 環境変数で渡す → CI/CD のシークレット管理が必要で結局散らかる
- ハードコード → 論外

Vault に一元管理しておいて、Terraform の実行時に動的に取得するのが答え。

---

## Vault Provider の設定

```hcl
# versions.tf
terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
}

provider "vault" {
  address = "https://your-vault-cluster.hashicorp.cloud:8200"
  # トークンは VAULT_TOKEN 環境変数から読む
}
```

認証トークンはコードに書かずに環境変数 `VAULT_TOKEN` で渡す。

---

## KV v2 からシークレットを取得する

```hcl
# Vault からシークレットを読む
data "vault_kv_secret_v2" "db" {
  mount = "secret"
  name  = "myapp/prod/database"
}

# 読んだ値をリソースで使う
resource "google_sql_user" "app" {
  instance = google_sql_database_instance.main.name
  name     = data.vault_kv_secret_v2.db.data["username"]
  password = data.vault_kv_secret_v2.db.data["password"]
}
```

`data["key名"]` で各フィールドを取り出せる。

---

## plan/apply 時の認証

ローカルから実行する場合：

```bash
# Vault にログインしてトークンを取得
vault login -method=userpass username=haruka

# Terraform を実行（VAULT_TOKEN が自動でセットされる）
terraform plan
```

HCP Terraform（リモート実行）から使う場合：

```
HCP Terraform のワークスペース → Variables → Environment variable
VAULT_TOKEN = <トークン値>  # Sensitive にチェック
VAULT_ADDR  = https://your-vault-cluster.hashicorp.cloud:8200
```

---

## Vault で動的クレデンシャルを発行して使う（上級）

DB の静的パスワードを Vault に置くのではなく、Vault 自体が DB の一時ユーザーを発行するパターン。

```hcl
# Vault の Database シークレットエンジンから動的クレデンシャルを取得
data "vault_database_secret_backend_creds" "db" {
  backend = "database"
  role    = "myapp-role"
}

# 発行された一時クレデンシャルを使う
output "db_username" {
  value     = data.vault_database_secret_backend_creds.db.username
  sensitive = true
}
```

`terraform apply` のたびに新しい一時ユーザーが発行され、TTL が切れると自動削除される。長期間有効なパスワードが存在しないのでリスクが下がる。

---

## 注意点

- `vault_kv_secret_v2` の中身は Terraform の state に平文で保存される。state 自体も暗号化・アクセス制御が必要
- Vault のトークンには最小限のポリシーだけ付ける（Terraform が読む必要があるパスだけ `read` を許可）
- HCP Terraform から使う場合、Vault トークンの TTL が長すぎると危険、短すぎると expired になる。適切な TTL か periodic token を使う
