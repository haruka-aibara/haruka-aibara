<!-- Space: harukaaibarapublic -->
<!-- Parent: IAM -->
<!-- Title: SCP で組織の安全ネットを張る -->

# SCP で組織の安全ネットを張る

GuardDuty や Security Hub は「やらかしてから検知する」仕組みだ。一方で SCP（Service Control Policy）は「そもそもやらかせない状態にする」——これが**予防的コントロール**の考え方。

「個々のアカウントで IAM 設定を頑張る」より「組織レベルで特定の操作を物理的に不可能にする」ほうが強い。SCP はその仕組みで、**ルートアカウントを含むすべての IAM ユーザー・ロールに上位から適用される**。

---

## SCP の基本的な考え方

SCP は「許可の上限」を定めるもの。IAM ポリシーで Allow していても、SCP で Deny されていれば操作できない。

```
実際に操作できる権限 = SCP で許可された範囲 ∩ IAM ポリシーで許可された範囲
```

重要な特性：
- **管理アカウントには SCP が適用されない**（だから管理アカウントはほぼ触らない運用にする）
- ルートユーザーにも適用される（IAM ポリシーでは制御できないが SCP は効く）
- Organizations の OU 単位で適用できる

---

## 組織全体に張るべき安全ネット

### ① GuardDuty・CloudTrail・Security Hub の無効化を禁止する

攻撃者が侵入後に最初にやることの一つが「証拠隠滅（ログの無効化）」。SCP でそもそも無効化できなくする。

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyDisableSecurityServices",
      "Effect": "Deny",
      "Action": [
        "guardduty:DeleteDetector",
        "guardduty:DisassociateFromMasterAccount",
        "guardduty:StopMonitoringMembers",
        "cloudtrail:DeleteTrail",
        "cloudtrail:StopLogging",
        "cloudtrail:UpdateTrail",
        "securityhub:DisableSecurityHub",
        "securityhub:DeleteMembers",
        "config:DeleteConfigurationRecorder",
        "config:StopConfigurationRecorder"
      ],
      "Resource": "*"
    }
  ]
}
```

攻撃者がクレデンシャルを奪っても、検知の仕組みを消せない状態を作る。

---

### ② 特定リージョン以外での操作を禁止する

使っていないリージョンで EC2 を起動されてクリプトマイニングされる、というのがよくある被害パターン。使うリージョンだけに絞る。

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyNonApprovedRegions",
      "Effect": "Deny",
      "NotAction": [
        "iam:*",
        "organizations:*",
        "support:*",
        "sts:*",
        "route53:*",
        "cloudfront:*",
        "waf:*",
        "budgets:*"
      ],
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": [
            "ap-northeast-1",
            "us-east-1"
          ]
        }
      }
    }
  ]
}
```

`NotAction` でグローバルサービス（IAM・Route53・CloudFront 等）は除外する。

---

### ③ ルートアカウントの使用を禁止する

ルートアカウントは日常業務で使う必要がない。SCP で明示的に制限する。

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyRootUser",
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:PrincipalArn": "arn:aws:iam::*:root"
        }
      }
    }
  ]
}
```

---

### ④ Organizations 自体の変更を制限する

メンバーアカウントが Organizations から脱退したり、信頼関係を変更するのを防ぐ。

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyLeavingOrg",
      "Effect": "Deny",
      "Action": [
        "organizations:LeaveOrganization",
        "organizations:DeleteOrganization"
      ],
      "Resource": "*"
    }
  ]
}
```

---

### ⑤ S3 パブリックアクセスのブロック解除を禁止する

メンバーアカウントが S3 のパブリックアクセスブロックを外せないようにする。

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyS3PublicAccess",
      "Effect": "Deny",
      "Action": [
        "s3:PutBucketPublicAccessBlock",
        "s3:DeletePublicAccessBlock"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "s3:DataAccessPointArn": "*"
        }
      }
    }
  ]
}
```

より確実にするなら、アカウントレベルのパブリックアクセスブロック設定の変更も Deny する。

---

## SCP の適用方法

```bash
# SCP を Organizations に作成
aws organizations create-policy \
  --name "SecurityBaseline" \
  --description "組織全体のセキュリティベースライン" \
  --content file://scp.json \
  --type SERVICE_CONTROL_POLICY

# 取得したポリシー ID を OU またはアカウントにアタッチ
aws organizations attach-policy \
  --policy-id p-xxxxxxxx \
  --target-id r-xxxx  # ルート OU に適用すると全アカウントに効く
```

---

## SCP を入れる前に確認すること

SCP は即時適用される。**テストなしで本番に入れると正規の業務も止まる**。

手順：
1. テストアカウント（sandbox 等）の OU に先に適用して影響を確認する
2. `aws iam simulate-principal-policy` で影響を事前にシミュレートする
3. 段階的に OU 単位で適用していく

```bash
# SCP 適用前に影響をシミュレート
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::123456789012:role/my-role \
  --action-names cloudtrail:StopLogging \
  --resource-arns "*"
```

---

## 検知（GuardDuty）と予防（SCP）の使い分け

| | 検知（GuardDuty・Security Hub） | 予防（SCP） |
|---|---|---|
| タイミング | やらかした後に気づく | そもそもやらかせない |
| カバレッジ | 幅広い異常を検知できる | 明示的に設定した操作だけ防げる |
| 運用コスト | アラート対応が必要 | 一度設定すれば基本メンテ不要 |
| 適用範囲 | アカウント単位 | 組織全体（OU 単位） |

両方を組み合わせるのが正解。SCP で「絶対にやってはいけないこと」を物理的に防ぎ、GuardDuty で「SCP が防げない範囲の異常」を検知する。

---

## 参考

- [AWS Organizations SCP リファレンス](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html)
- [SCP の例（AWS 公式）](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps_examples.html)
- [AWS セキュリティ成熟度モデル — 予防的コントロール](https://maturitymodel.security.aws.dev/en/2.-foundational/preventive-controls/)
