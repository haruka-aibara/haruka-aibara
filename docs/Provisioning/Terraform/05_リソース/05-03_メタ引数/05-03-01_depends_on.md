<!-- Space: harukaaibarapublic -->
<!-- Parent: 05-03_メタ引数 -->
<!-- Title: depends_on -->

# depends_on

リソース間の明示的な依存関係を指定するメタ引数。

---

## 使いどころ

Terraform は属性の参照から依存関係を自動解決するが、依存関係がコードに現れない場合に `depends_on` で明示する。

**例**: IAM ロールのポリシーアタッチが完了してから EC2 を起動したい。

```hcl
resource "aws_iam_role_policy_attachment" "example" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_instance" "app" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  depends_on = [aws_iam_role_policy_attachment.example]
}
```

---

## 注意

- `depends_on` は apply の順序を制御するだけで、属性の参照ではない
- 過剰に使うと Terraform の並列処理が制限されてデプロイが遅くなる
- 属性参照で依存関係を表現できる場合は `depends_on` を使わない

---

## モジュールへの depends_on

モジュールにも `depends_on` を指定できる（Terraform v0.13+）。モジュール内の全リソースに依存関係が適用される。

```hcl
module "app" {
  source = "./modules/app"

  depends_on = [module.network]
}
```
