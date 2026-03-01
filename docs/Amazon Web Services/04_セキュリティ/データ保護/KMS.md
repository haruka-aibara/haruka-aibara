<!-- Space: harukaaibarapublic -->
<!-- Parent: データ保護 -->
<!-- Title: AWS KMS -->

# AWS KMS（Key Management Service）

暗号化キーを自分でサーバーに保管して管理するのはリスクが高い——キーとデータが同じ場所にあると、どちらかが漏洩したとき両方アウトになる。KMS は暗号化キーの生成・保管・ローテーションを AWS が管理し、アクセス制御と使用ログを提供するサービス。

---

## CMK（カスタマーマスターキー）の種類

| キーの種類 | 説明 | 用途 |
|---|---|---|
| AWS マネージドキー | AWS サービスが自動で作成・管理 | `aws/s3`, `aws/rds` など。追加設定不要 |
| カスタマーマネージドキー | 自分で作成・管理 | 詳細なアクセス制御・監査が必要な場合 |
| AWS 所有キー | AWS がアカウント横断で管理 | 無料。コントロールなし |

---

## S3 バケットの暗号化

```bash
# バケット作成時に暗号化を設定（KMS）
aws s3api create-bucket \
  --bucket my-secure-bucket \
  --region ap-northeast-1 \
  --create-bucket-configuration LocationConstraint=ap-northeast-1

aws s3api put-bucket-encryption \
  --bucket my-secure-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms",
        "KMSMasterKeyID": "arn:aws:kms:ap-northeast-1:123456789012:key/key-id"
      }
    }]
  }'
```

---

## キーポリシー

KMS キーへのアクセスはキーポリシーで制御する。IAM ポリシーだけでは不十分で、キーポリシーにも明示的な許可が必要。

```json
{
  "Statement": [
    {
      "Sid": "Allow use of the key",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:role/my-app-role"
      },
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## Envelope Encryption（封筒暗号化）

KMS は大きなデータを直接暗号化しない。「データキー」を KMS で生成し、そのデータキーでデータを暗号化する方式（Envelope Encryption）を使う。

```
1. KMS に「データキーを生成して」と依頼
2. KMS がデータキー（平文）と暗号化済みデータキーを返す
3. 平文データキーでデータを暗号化
4. 平文データキーはメモリから破棄
5. 暗号化済みデータキーと暗号化済みデータを保存

※ 復号時は暗号化済みデータキーを KMS で復号してから使う
```

---

## キーローテーション

カスタマーマネージドキーは自動ローテーションを有効にできる（1年ごと）。ローテーション後も古いキーで暗号化されたデータは復号できる。

```bash
aws kms enable-key-rotation --key-id <key-id>
```

---

## CloudTrail での KMS 操作ログ

KMS の全操作は CloudTrail に記録される。誰がいつキーを使ったか追跡できる。

```bash
# KMS の操作ログを確認
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventSource,AttributeValue=kms.amazonaws.com
```

不審なキー使用（通常とは異なる時間帯・IP アドレスからの Decrypt）を GuardDuty が検知できる。
