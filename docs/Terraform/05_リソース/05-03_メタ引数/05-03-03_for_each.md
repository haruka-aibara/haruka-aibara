<!-- Space: harukaaibarapublic -->
<!-- Parent: 05-03_メタ引数 -->
<!-- Title: for_each -->

# for_each

マップまたはセットを元に複数のリソースを作成するメタ引数。`count` より柔軟で安全。

---

## マップを使う場合

```hcl
variable "buckets" {
  default = {
    logs    = "ap-northeast-1"
    backups = "us-east-1"
  }
}

resource "aws_s3_bucket" "example" {
  for_each = var.buckets
  bucket   = "myapp-${each.key}"

  tags = {
    Region = each.value
  }
}
```

`each.key` でキー、`each.value` で値を参照。リソース ID は `aws_s3_bucket.example["logs"]` のようになる。

---

## セットを使う場合

```hcl
resource "aws_iam_user" "devs" {
  for_each = toset(["alice", "bob", "carol"])
  name     = each.key
}
```

---

## 生成されたリソースの参照

```hcl
output "bucket_arns" {
  value = { for k, v in aws_s3_bucket.example : k => v.arn }
}
```

---

## count との使い分け

- リソースを名前（文字列キー）で識別したい → `for_each`
- 途中のリソースを削除する可能性がある → `for_each`（インデックスずれが発生しない）
- 単純に N 個作るだけ → `count`

実務では `for_each` を使う場面が多い。
