<!-- Space: harukaaibarapublic -->
<!-- Parent: 検知と可視化 -->
<!-- Title: AWS Security Hub -->

# AWS Security Hub

GuardDuty・Config・Inspector・Macie などのセキュリティツールを個別に確認していると、どこにどんな問題があるか全体像がつかめない。Security Hub はこれらのサービスからの検知結果を一箇所に集約して、アカウント全体のセキュリティ状況をスコア化して見せてくれる。

---

## Security Hub が集約するもの

| ソース | 内容 |
|---|---|
| Amazon GuardDuty | 不審な通信・操作の脅威検知 |
| AWS Config | リソース設定のコンプライアンス違反 |
| Amazon Inspector | EC2・ECR・Lambda の脆弱性 |
| Amazon Macie | S3 の機密データ検出 |
| AWS Firewall Manager | WAF・セキュリティグループのポリシー違反 |
| サードパーティ | Crowdstrike・Palo Alto など |

---

## セキュリティ基準

Security Hub には業界標準のセキュリティ基準が組み込まれていて、自分のアカウントがどれだけ準拠しているかスコアで確認できる。

| 基準 | 内容 |
|---|---|
| AWS Foundational Security Best Practices | AWS 推奨のセキュリティ設定 |
| CIS AWS Foundations Benchmark | CIS（Center for Internet Security）ガイドライン |
| PCI DSS | クレジットカード業界のセキュリティ基準 |
| NIST SP 800-53 | 米国政府のセキュリティフレームワーク |

---

## 有効化

```bash
# Security Hub を有効化（東京リージョン）
aws securityhub enable-security-hub \
  --region ap-northeast-1 \
  --enable-default-standards

# 組織全体で有効化（管理アカウントから）
aws securityhub enable-organization-admin-account \
  --admin-account-id 123456789012
```

---

## 検知結果の確認

```bash
# HIGH / CRITICAL の検知結果を一覧
aws securityhub get-findings \
  --filters '{
    "SeverityLabel": [
      {"Value": "HIGH", "Comparison": "EQUALS"},
      {"Value": "CRITICAL", "Comparison": "EQUALS"}
    ],
    "WorkflowStatus": [
      {"Value": "NEW", "Comparison": "EQUALS"}
    ]
  }'
```

---

## EventBridge との連携でアラートを飛ばす

HIGH / CRITICAL の検知結果が出たら Slack や PagerDuty に通知する。

```json
{
  "source": ["aws.securityhub"],
  "detail-type": ["Security Hub Findings - Imported"],
  "detail": {
    "findings": {
      "Severity": {
        "Label": ["HIGH", "CRITICAL"]
      },
      "Workflow": {
        "Status": ["NEW"]
      }
    }
  }
}
```

このルールを EventBridge に設定し、ターゲットに SNS または Lambda を指定する。

---

## マルチアカウント環境での活用

Organizations と連携して、全アカウントの検知結果を管理アカウントの Security Hub に集約できる。

```
管理アカウント（Security Hub 管理者）
├── 本番アカウント → 検知結果を集約
├── 開発アカウント → 検知結果を集約
└── データアカウント → 検知結果を集約
```

個別アカウントを確認しなくても、全体のセキュリティ状況を把握できる。
