<!-- Space: harukaaibarapublic -->
<!-- Parent: 22_セキュリティ -->
<!-- Title: Trivy -->

# Trivy

コンテナイメージ・ファイルシステム・IaC（Terraform 含む）のセキュリティスキャンツール。Aqua Security が開発。OSS。

---

## インストール

```bash
# macOS
brew install aquasecurity/trivy/trivy

# Linux
sudo apt install trivy
```

---

## Terraform コードのスキャン

```bash
# カレントディレクトリをスキャン
trivy config .

# 重要度でフィルタ
trivy config --severity HIGH,CRITICAL .

# JSON 出力
trivy config --format json --output result.json .
```

---

## 出力例

```
main.tf (terraform)

Tests: 42 (SUCCESSES: 38, FAILURES: 4, EXCEPTIONS: 0)
Failures: 4 (HIGH: 2, CRITICAL: 2)

CRITICAL: S3 bucket has versioning disabled
━━━━━━━━━━━━━━━━━━━━━━━━━━
 1 resource "aws_s3_bucket" "example" {
 2   bucket = "my-bucket"
 3 }

HIGH: Security group allows unrestricted ingress on port 22
```

---

## Checkov との違い

| | Trivy | Checkov |
|---|---|---|
| 対応範囲 | コンテナ・IaC・OS・ライブラリ | IaC 専用（Terraform / CloudFormation 等） |
| 用途 | コンテナパイプラインに組み込みやすい | Terraform プロジェクトに特化した詳細チェック |

コンテナと Terraform の両方を扱うプロジェクトでは Trivy 一本でまとめることが多い。

---

## GitHub Actions への組み込み

```yaml
- name: Trivy IaC scan
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: config
    scan-ref: .
    severity: HIGH,CRITICAL
    exit-code: 1
```
