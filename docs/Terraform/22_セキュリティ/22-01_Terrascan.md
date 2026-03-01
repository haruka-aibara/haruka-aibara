<!-- Space: harukaaibarapublic -->
<!-- Parent: 22_セキュリティ -->
<!-- Title: Terrascan -->

# Terrascan

Terrascan は Terraform・Kubernetes・Helm などの IaC コードに対してセキュリティポリシーを検査するツール。500以上のポリシーを内蔵している。

---

## インストール

```bash
# macOS
brew install terrascan

# Docker
docker pull accurics/terrascan
```

---

## 基本的な使い方

```bash
# Terraform コードをスキャン
terrascan scan -t aws

# 特定のディレクトリをスキャン
terrascan scan -t aws -d ./infra

# JSON で出力
terrascan scan -t aws -o json
```

---

## 検出される問題の例

```
Violation Details:
- Severity: HIGH
- Rule: AWS.S3.DS.H.0001
- Description: S3 バケットのパブリックアクセスブロックが設定されていない
- Resource: aws_s3_bucket.assets
- File: main.tf, Line: 12
```

---

## GitHub Actions への組み込み

```yaml
- name: Run Terrascan
  id: terrascan
  uses: accurics/terrascan-action@main
  with:
    iac_type: terraform
    iac_version: v14
    policy_type: aws
    only_warn: false
    sarif_upload: true

- name: Upload SARIF file
  uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: terrascan.sarif
```

SARIF 形式で出力すると GitHub Security タブに結果が表示される。

---

## Checkov / Trivy との比較

| ツール | 特徴 |
|---|---|
| Terrascan | OPA ポリシーベース。カスタムポリシーを Rego で書ける |
| Checkov | Python 製。ルールが豊富で CI 統合が簡単 |
| Trivy | コンテナ・IaC 両対応。マルチツール不要 |

Terrascan は OPA（Open Policy Agent）ベースのカスタムポリシーを書きたい場合に選ばれることが多い。

---

## カスタムポリシーの例（Rego）

```rego
package accurics.aws.S3.bucketPublicExposure

deny[api] {
  bucket := input.aws_s3_bucket[_]
  bucket.config.acl == "public-read"
  api := {
    "name": "S3 バケットのパブリック ACL を禁止",
    "resource": bucket.name,
  }
}
```

組織独自のルールを Rego で記述して適用できる。
