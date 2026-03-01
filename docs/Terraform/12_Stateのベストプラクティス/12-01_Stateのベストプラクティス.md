<!-- Space: harukaaibarapublic -->
<!-- Parent: 12_Stateのベストプラクティス -->
<!-- Title: State のベストプラクティス -->

# State のベストプラクティス

State の扱いを間違えると「チームで State が共有できない」「機密情報が Git に入る」「誰かが apply 中に別の人が apply して State が壊れる」といった問題が起きる。最初から正しい設定にしておけば後で困らない。

---

## 1. 必ずリモートバックエンドを使う

ローカルの `terraform.tfstate` はチーム開発には不向き。S3 + DynamoDB を使う。

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

`terraform.tfstate` には DB パスワードなどの機密情報が平文で含まれる。`.gitignore` に追加する。

```gitignore
*.tfstate
*.tfstate.backup
.terraform/
```

---

## 3. バージョニングと暗号化を有効にする

誤操作で State を壊しても復元できるように。

```hcl
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration { status = "Enabled" }
}
```

`encrypt = true` でサーバーサイド暗号化も有効にする。

---

## 4. 環境・コンポーネントで State を分割する

全リソースを1つの State に詰め込まない。影響範囲が広がり、apply も遅くなる。

```
state/
├── network/terraform.tfstate    # VPC, Subnet など（変更頻度低）
├── database/terraform.tfstate   # RDS など
└── app/terraform.tfstate        # ECS, ALB など（変更頻度高）
```

分割することで plan が速くなり、ロックの競合も減り、権限管理もしやすくなる。

---

## 5. State への直接操作の前にバックアップを取る

`terraform state rm` や `terraform state mv` は不可逆な操作。必ずバックアップしてから。

```bash
terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate
```
