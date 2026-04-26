<!-- Space: harukaaibarapublic -->
<!-- Parent: 08_フォーマットと検証 -->
<!-- Title: terraform fmt -->

# terraform fmt

複数人で Terraform を書いていると、インデントの幅や `=` の揃え方がバラバラになる。「スタイルの統一」を人間がレビューするのは無駄。`terraform fmt` が自動修正するので、CI で強制しておけばスタイル議論が不要になる。

---

## 基本的な使い方

```bash
# カレントディレクトリの .tf ファイルをフォーマット
terraform fmt

# サブディレクトリも含めて処理
terraform fmt -recursive

# 何が変わるか確認だけ（実際には変更しない）
terraform fmt -check -diff
```

---

## 変換の例

```hcl
# フォーマット前（インデントがバラバラ）
resource "aws_instance" "web" {
ami = "ami-xxx"
  instance_type    =  "t3.micro"
tags={Name="web"}
}

# フォーマット後（自動で整形）
resource "aws_instance" "web" {
  ami           = "ami-xxx"
  instance_type = "t3.micro"
  tags          = { Name = "web" }
}
```

---

## CI でフォーマットを強制する

```yaml
- name: Check formatting
  run: terraform fmt -check -recursive
```

`-check` オプションは、フォーマットが崩れているファイルがあると exit code 3 で終了する。PR に組み込んでおけば「フォーマットが崩れたままマージ」がなくなる。

ローカルでは `terraform fmt -recursive` を実行してからコミットする習慣をつけると、CI で引っかかることがなくなる。
