<!-- Space: harukaaibarapublic -->
<!-- Parent: 09_デプロイメント -->
<!-- Title: terraform plan -->

# terraform plan

apply する前に「何が変わるか」を確認するコマンド。本番環境に apply する前に plan を読む習慣がないと、予期しないリソースの削除や再作成が起きて痛い目に遭う。

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

**`-/+` が出たら特に注意**。本番リソースが一時的に消える。RDS や ALB で出たら、ダウンタイムの覚悟か代替手段が必要。

---

## plan ファイルを保存する

```bash
# plan 結果をファイルに保存
terraform plan -out=tfplan

# 保存した plan を適用（この plan の内容だけが実行される）
terraform apply tfplan
```

CI/CD では `plan -out` → レビュー・承認 → `apply tfplan` の流れが安全。plan と apply の間にコードが変わっても、保存した plan の内容だけが実行される。

---

## よく使うオプション

```bash
# 特定リソースのみ確認
terraform plan -target=aws_instance.web

# 変数を渡す
terraform plan -var-file="production.tfvars"
```
