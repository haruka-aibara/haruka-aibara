<!-- Space: harukaaibarapublic -->
<!-- Parent: 08_フォーマットと検証 -->
<!-- Title: terraform fmt -->

# terraform fmt

HCL コードを標準フォーマットに自動修正するコマンド。

---

## 基本的な使い方

```bash
# カレントディレクトリの .tf ファイルをフォーマット
terraform fmt

# サブディレクトリも含めて再帰的に処理
terraform fmt -recursive

# 変更内容を表示（実際には変更しない）
terraform fmt -check -diff
```

`-check` オプションを使うと、フォーマットが必要なファイルがある場合に exit code 3 で終了する。CI での差分チェックに使える。

---

## CI/CD での使い方

GitHub Actions でフォーマットチェックを行う例：

```yaml
- name: Check formatting
  run: terraform fmt -check -recursive
```

フォーマットが崩れていると CI が失敗するようにしておくと、コードスタイルを統一しやすい。

---

## フォーマット対象の変換例

```hcl
# フォーマット前
resource "aws_instance" "web" {
ami = "ami-xxx"
  instance_type    =  "t3.micro"
tags={Name="web"}
}

# フォーマット後
resource "aws_instance" "web" {
  ami           = "ami-xxx"
  instance_type = "t3.micro"
  tags          = { Name = "web" }
}
```

インデント・イコールの揃え・スペースを自動修正してくれる。
