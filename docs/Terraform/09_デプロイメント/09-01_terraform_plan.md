<!-- Space: harukaaibarapublic -->
<!-- Parent: 09_デプロイメント -->
<!-- Title: terraform plan -->

# terraform plan

現在の State と .tf の定義を比較して、何が変わるかをプレビューするコマンド。

---

## 基本的な使い方

```bash
terraform plan
```

---

## plan の出力の読み方

```
Terraform will perform the following actions:

  # aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami           = "ami-0c55b159cbfafe1f0"
      + instance_type = "t3.micro"
    }

  # aws_security_group.old will be destroyed
  - resource "aws_security_group" "old" {
      - name = "old-sg"
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

| 記号 | 意味 |
|---|---|
| `+` | 新規作成 |
| `-` | 削除 |
| `~` | 更新（in-place） |
| `-/+` | 削除してから再作成（replace） |

`-/+` が出たら特に注意。本番リソースが一時的に消える可能性がある。

---

## plan ファイルの保存と利用

```bash
# plan 結果をファイルに保存
terraform plan -out=tfplan

# 保存した plan だけを適用（plan と apply の間に差が出ない）
terraform apply tfplan
```

CI/CD では `plan -out` → レビュー → `apply` の流れで使うのが安全。

---

## よく使うオプション

```bash
# 特定のリソースのみ plan
terraform plan -target=aws_instance.web

# 変数を渡す
terraform plan -var="env=production"

# 変数ファイルを渡す
terraform plan -var-file="production.tfvars"
```
