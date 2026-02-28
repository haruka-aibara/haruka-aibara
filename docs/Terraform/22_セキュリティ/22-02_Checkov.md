<!-- Space: harukaaibarapublic -->
<!-- Parent: 22_セキュリティ -->
<!-- Title: Checkov -->

# Checkov

Terraform コードのセキュリティ・コンプライアンス問題を静的解析するツール。Bridgecrew（Palo Alto Networks）が開発。

---

## インストール

```bash
pip install checkov
# または
brew install checkov
```

---

## 基本的な使い方

```bash
# カレントディレクトリの .tf をスキャン
checkov -d .

# 特定ファイルをスキャン
checkov -f main.tf

# JSON 形式で出力
checkov -d . -o json
```

---

## 出力例

```
Check: CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
    FAILED for resource: aws_s3_bucket.example
    File: /main.tf:1-10

Check: CKV_AWS_78: "Ensure that ECR image scanning on push is enabled"
    PASSED for resource: aws_ecr_repository.app
    File: /main.tf:20-25

Passed checks: 15, Failed checks: 3, Skipped checks: 0
```

---

## チェックのスキップ

特定チェックをスキップする場合はコメントで指定する。

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-bucket"
  #checkov:skip=CKV_AWS_18:アクセスログは別途 CloudTrail で収集している
}
```

---

## GitHub Actions への組み込み

```yaml
- name: Checkov scan
  uses: bridgecrewio/checkov-action@v12
  with:
    directory: .
    framework: terraform
    soft_fail: false
```

`soft_fail: false` にするとチェック失敗時に CI が止まる。最初は `soft_fail: true` で結果を確認してから段階的に有効化するのが現実的。
