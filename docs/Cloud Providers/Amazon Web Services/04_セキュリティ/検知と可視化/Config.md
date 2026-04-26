<!-- Space: harukaaibarapublic -->
<!-- Parent: 検知と可視化 -->
<!-- Title: AWS Config -->

# AWS Config

「S3 バケットのパブリックアクセスブロックがいつのまにか無効になっていた」「セキュリティグループに 0.0.0.0/0 のルールが追加されていた」——CloudTrail は操作ログだが、AWS Config はリソースの設定が「現在どうなっているか」「過去どう変わったか」を継続的に追跡する。コンプライアンスルールへの準拠状況もリアルタイムで確認できる。

---

## CloudTrail との違い

| | CloudTrail | AWS Config |
|---|---|---|
| 記録するもの | API 操作（誰が何をしたか） | リソースの設定状態（今どうなっているか） |
| 主な用途 | 操作の監査・追跡 | 設定のコンプライアンス確認・変更履歴 |
| 例 | 「誰がセキュリティグループを変更したか」 | 「セキュリティグループに 0.0.0.0/0 があるか」 |

---

## Config Rules でコンプライアンスを自動チェック

AWS が用意したマネージドルールを使うだけで、一般的なセキュリティ要件の違反を自動検知できる。

よく使うルール：

| ルール名 | チェック内容 |
|---|---|
| `s3-bucket-public-read-prohibited` | S3 パブリック読み取りアクセスの禁止 |
| `restricted-ssh` | SSH（22 番ポート）の全開放禁止 |
| `root-account-mfa-enabled` | root アカウントの MFA 有効化 |
| `access-keys-rotated` | アクセスキーのローテーション（90日） |
| `encrypted-volumes` | EBS ボリュームの暗号化 |
| `rds-storage-encrypted` | RDS の暗号化 |
| `cloudtrail-enabled` | CloudTrail の有効化 |

```bash
# マネージドルールを有効化
aws configservice put-config-rule \
  --config-rule '{
    "ConfigRuleName": "restricted-ssh",
    "Source": {
      "Owner": "AWS",
      "SourceIdentifier": "INCOMING_SSH_DISABLED"
    }
  }'
```

---

## 変更履歴の確認

リソースの設定が過去にどう変わったか追跡できる。

```bash
# リソースの設定変更履歴を確認
aws configservice get-resource-config-history \
  --resource-type AWS::EC2::SecurityGroup \
  --resource-id sg-0abc123def456789
```

---

## 自動修復（Remediation）

違反を検知したら自動的に修正するアクションを設定できる。

```
Config Rule が違反を検知
    ↓
SSM Automation または Lambda で自動修復
    ↓
例: パブリック設定になった S3 バケットを自動でプライベートに戻す
```

---

## 有効化

```bash
# 設定レコーダーを有効化
aws configservice start-configuration-recorder \
  --configuration-recorder-name default

# 配信チャンネルを設定（S3 に記録）
aws configservice put-delivery-channel \
  --delivery-channel '{
    "name": "default",
    "s3BucketName": "my-config-bucket"
  }'
```

Security Hub と連携すると Config の違反を Security Hub のダッシュボードで一元確認できる。
