<!-- Space: harukaaibarapublic -->
<!-- Parent: 21_Terraformのスケーリング -->
<!-- Title: Terragrunt -->

# Terragrunt

Terragrunt は Terraform のラッパーツール。DRY（Don't Repeat Yourself）原則を実現し、複数環境・複数アカウントの管理を効率化する。

---

## Terraform 単体での課題

環境（dev/staging/prod）ごとに同じような設定を繰り返す問題。

```
# Terraform だけだと各環境に同じバックエンド設定が必要
dev/
├── backend.tf    # bucket = "my-state", key = "dev/..."
├── main.tf       # コピー
└── variables.tf
prod/
├── backend.tf    # bucket = "my-state", key = "prod/..."
├── main.tf       # コピー
└── variables.tf
```

---

## Terragrunt の解決策

`terragrunt.hcl` で設定を DRY にまとめる。

```
infra/
├── terragrunt.hcl           # 共通設定（ルート）
├── dev/
│   ├── terragrunt.hcl       # dev 固有の変数
│   └── app/
│       └── terragrunt.hcl
└── prod/
    ├── terragrunt.hcl       # prod 固有の変数
    └── app/
        └── terragrunt.hcl
```

### ルートの terragrunt.hcl

```hcl
# infra/terragrunt.hcl

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = "my-terraform-state"
    key    = "${path_relative_to_include()}/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
```

### 環境ごとの terragrunt.hcl

```hcl
# infra/dev/terragrunt.hcl

include "root" {
  path = find_in_parent_folders()   # ルートの設定を継承
}

inputs = {
  environment    = "dev"
  instance_type  = "t3.micro"
}
```

---

## 複数モジュールの一括実行

```bash
# infra/dev 配下の全モジュールを一括で plan
terragrunt run-all plan --terragrunt-working-dir infra/dev

# 依存関係を解決しながら一括 apply
terragrunt run-all apply --terragrunt-working-dir infra/dev
```

`run-all` は依存グラフを解析して適切な順序で実行する。

---

## 採用基準

| 状況 | Terragrunt の効果 |
|---|---|
| 環境が2〜3個 | メリットは小さい。Terraform workspace で十分 |
| 環境が4個以上 | DRY 化の恩恵が大きい |
| マルチアカウント | アカウントごとの設定管理が楽になる |
| モジュールの依存関係が複雑 | `run-all` が役立つ |

導入コストがあるので、まず Terraform 本体でどこまでできるか試してから検討する。
