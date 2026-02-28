<!-- Space: harukaaibarapublic -->
<!-- Parent: 12_Stateのベストプラクティス -->
<!-- Title: State のベストプラクティス -->

# State のベストプラクティス

---

## 1. 必ずリモートバックエンドを使う

ローカルの `terraform.tfstate` はチーム開発には不向き。S3 + DynamoDB（AWS）や GCS（GCP）を使う。

```hcl
terraform {
  backend "s3" {
    bucket         = "my-tfstate"
    key            = "prod/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
```

---

## 2. State を Git にコミットしない

`terraform.tfstate` には機密情報（DB パスワード等）が含まれる場合がある。`.gitignore` に追加する。

```gitignore
*.tfstate
*.tfstate.backup
.terraform/
```

---

## 3. State を暗号化する

S3 バックエンドでは `encrypt = true` を設定し、バケットの SSE も有効にする。

---

## 4. State ファイルのバージョニング

S3 バケットのバージョニングを有効にしておくと、誤操作で State を壊しても復元できる。

---

## 5. 環境・コンポーネントで State を分割する

一つの State に全リソースを詰め込まない。

```
state/
├── network/terraform.tfstate    # VPC, Subnet, etc.
├── database/terraform.tfstate   # RDS, etc.
└── app/terraform.tfstate        # EC2, ALB, etc.
```

分割することで：
- 影響範囲が小さくなる（plan/apply が速くなる）
- ロックの競合が減る
- 部分的な権限付与がしやすくなる

---

## 6. State への直接操作は慎重に

`terraform state rm` や `terraform state mv` は State を直接変更する。バックアップを取ってから実行する。

```bash
# バックアップ
terraform state pull > backup.tfstate

# 操作
terraform state rm aws_instance.old
```
