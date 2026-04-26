<!-- Space: harukaaibarapublic -->
<!-- Parent: AWSセキュリティ成熟度モデル -->
<!-- Title: AWS Organizations 初期セキュリティ設定チェックリスト -->

# AWS Organizations 初期セキュリティ設定チェックリスト

新しい AWS 環境を引き継いだとき、あるいはゼロからセキュリティを整備し始めるとき、「何から手をつければいいか」が分かりにくい。

これは「Quick Wins フェーズで最初の 2 週間でやること」を具体的な手順とともにまとめたもの。順番通りに実行すれば、最低限の安全な状態に持っていける。

---

## 前提：管理アカウントと委任管理者の役割分担

AWS Organizations では**管理アカウント（マスターアカウント）は極力触らない**のが鉄則。

- 管理アカウントには SCP が適用されない（＝最強の権限を持つ）
- 日常業務は委任管理者アカウント（専用セキュリティアカウントや監査アカウント）で行う
- 管理アカウントへのアクセスは MFA + 記録（CloudTrail）が必須

```bash
# Security Hub の委任管理者を設定する（管理アカウントで実行）
aws organizations enable-aws-service-principal \
  --service-principal securityhub.amazonaws.com

aws securityhub enable-organization-admin-account \
  --admin-account-id 123456789012  # セキュリティ専用アカウントの ID
```

---

## チェックリスト

### Week 1：検知の基盤を作る

#### ① 管理アカウントのルート MFA を設定する
最初にやること。クレデンシャルが漏洩したときの被害が最大になるのが管理アカウントのルート。

- [ ] 管理アカウントのルートアカウントに MFA デバイスを登録（ハードウェアキー推奨）
- [ ] MFA デバイスをセキュアな場所に保管（個人スマホではなく会社管理のデバイス）
- [ ] ルートアクセスキーが存在する場合は即座に削除

```bash
# ルートアクセスキーの存在確認（管理アカウントのルートで実行）
aws iam get-account-summary \
  --query 'SummaryMap.AccountAccessKeysPresent'
# 1 が返ってきたら即削除する
```

#### ② 組織レベルの CloudTrail を有効化する

個々のアカウントではなく、**組織全体をカバーする証跡**を1つ作る。

```bash
# 組織レベルの CloudTrail を作成（管理アカウントで実行）
aws cloudtrail create-trail \
  --name org-cloudtrail \
  --s3-bucket-name my-cloudtrail-bucket \
  --is-organization-trail \
  --is-multi-region-trail \
  --enable-log-file-validation

aws cloudtrail start-logging --name org-cloudtrail
```

CloudTrail の S3 バケットには以下を設定する：
- バケットポリシー：CloudTrail サービスプリンシパルからのみ書き込み可
- S3 パブリックアクセスブロック：全項目 ON
- バケット削除保護：オブジェクトロック（WORM）推奨

#### ③ GuardDuty を組織全体で有効化する

```bash
# GuardDuty の委任管理者を設定
aws guardduty enable-organization-admin-account \
  --admin-account-id 123456789012

# 委任管理者アカウントで：全メンバーアカウントを自動有効化
aws guardduty update-organization-configuration \
  --detector-id xxxx \
  --auto-enable-organization-members ALL
```

**全リージョンで有効化されていることを確認する**：

```bash
for region in $(aws ec2 describe-regions --query 'Regions[].RegionName' --output text); do
  status=$(aws guardduty list-detectors --region $region \
    --query 'length(DetectorIds)' --output text 2>/dev/null || echo "0")
  echo "$region: $status detector(s)"
done
```

#### ④ Security Hub を有効化して FSBP を有効にする

```bash
aws securityhub enable-security-hub \
  --enable-default-standards

# 組織内の新規アカウントに自動適用
aws securityhub update-organization-configuration \
  --auto-enable \
  --auto-enable-standards DEFAULT
```

---

### Week 1（続き）：攻撃面の最小化

#### ⑤ 使っていないリージョンを SCP で無効化する

```bash
# 現在どのリージョンにリソースがあるか確認（Resource Explorer を使う場合）
aws resource-explorer-2 search --query-string "region:us-west-1" --output table
```

SCP でリージョン制限（SCP の詳細は「SCP で組織の安全ネットを張る」参照）。

#### ⑥ S3 パブリックアクセスブロックをアカウントレベルで有効化する

```bash
# 全アカウントに適用（CloudFormation StackSets 推奨）
aws s3control put-public-access-block \
  --account-id 123456789012 \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

#### ⑦ セキュリティ連絡先を全アカウントに設定する

Security Hub の Account.1 コントロールの対処。管理アカウントが漏洩したときに AWS から連絡を受け取れる状態にする。

```bash
# セキュリティ連絡先を設定（個人メールではなく配布リスト）
aws account put-alternate-contact \
  --alternate-contact-type SECURITY \
  --name "Security Team" \
  --email-address "security-team@example.com" \
  --phone-number "+81-3-xxxx-xxxx" \
  --title "Security Engineer"
```

---

### Week 2：予防的コントロールを追加する

#### ⑧ GuardDuty・CloudTrail を無効化できないよう SCP を設定する

攻撃者が侵入後に最初にやることが「証拠隠滅（ログの削除）」。SCP で物理的に不可能にする。

```json
{
  "Effect": "Deny",
  "Action": [
    "guardduty:DeleteDetector",
    "cloudtrail:DeleteTrail",
    "cloudtrail:StopLogging",
    "securityhub:DisableSecurityHub"
  ],
  "Resource": "*"
}
```

#### ⑨ Organizations からの脱退を禁止する SCP を設定する

```json
{
  "Effect": "Deny",
  "Action": [
    "organizations:LeaveOrganization"
  ],
  "Resource": "*"
}
```

#### ⑩ IAM Access Analyzer を有効化する

外部に公開されているリソース（S3 バケット、IAM ロール、KMS キー等）を継続的に検出する。

```bash
# 組織レベルのアナライザーを作成（委任管理者アカウントで実行）
aws accessanalyzer create-analyzer \
  --analyzer-name org-analyzer \
  --type ORGANIZATION
```

---

## 設定後の確認：Security Hub スコアを見る

上記を設定した後、Security Hub で現在のスコアを確認する。初回は 30-50% 程度が多い。

```bash
# CRITICAL・HIGH の FAILED コントロールを確認
aws securityhub get-findings \
  --filters '{"SeverityLabel": [{"Value": "CRITICAL", "Comparison": "EQUALS"}, {"Value": "HIGH", "Comparison": "EQUALS"}], "ComplianceStatus": [{"Value": "FAILED", "Comparison": "EQUALS"}]}' \
  --query 'Findings[*].[Title, SeverityLabel]' \
  --output table | head -30
```

CRITICAL と HIGH の FAILED を潰していくのが次のステップ（詳細は「Security Hub FSBP コントロールの優先順位の付け方」参照）。

---

## よくある順序の間違い

**❌ Security Hub より先に Config を個別設定する**

Security Hub を有効化すると自動で Config が有効になる（FSBP に必要なため）。個別に設定する前に Security Hub を先に有効化する。

**❌ GuardDuty を一部リージョンだけ有効化する**

使っていないリージョンでも有効化する。使っていないリージョンで EC2 が起動された（クリプトマイニング）ことを検知できなくなる。

**❌ 委任管理者を設定しないまま管理アカウントで操作する**

管理アカウントへのアクセスが増えるほど、最強のアカウントが攻撃対象になるリスクが上がる。委任管理者を設定して、日常業務は別アカウントで行う。

---

## 参考

- [AWS Organizations のベストプラクティス](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_best-practices.html)
- [AWS マルチアカウントセキュリティ戦略](https://docs.aws.amazon.com/whitepapers/latest/organizing-your-aws-environment/security-ou-and-accounts.html)
- [AWS セキュリティ成熟度モデル — Quick Wins フェーズ](https://maturitymodel.security.aws.dev/en/1.-quick-wins/)
