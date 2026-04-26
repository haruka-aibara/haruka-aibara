<!-- Space: harukaaibarapublic -->
<!-- Parent: ネットワークセキュリティ -->
<!-- Title: AWS WAF -->

# AWS WAF

「ログを見たら SQL インジェクションを繰り返している IP があった」「ボットが API を叩き続けてレートが跳ね上がった」——セキュリティグループは IP とポートしか制御できない。WAF は HTTP/HTTPS のリクエスト内容を見てフィルタリングできる。

---

## WAF でできること

| 機能 | 内容 |
|---|---|
| IP ブロック | 特定 IP/CIDR からのリクエストを遮断 |
| マネージドルール | AWS や Marketplace が用意したルールセットを適用 |
| レートリミット | 同一 IP から一定時間内のリクエスト数を制限 |
| ジオブロック | 特定の国からのアクセスをブロック |
| カスタムルール | ヘッダー・クエリ文字列・URI パスでの条件指定 |
| Bot Control | ボットのスクレイピング・クローラーを識別・制御 |

---

## 適用できるリソース

- CloudFront
- ALB（Application Load Balancer）
- API Gateway
- AppSync
- Cognito User Pool

---

## マネージドルールグループの適用

```bash
# WAF Web ACL の作成
aws wafv2 create-web-acl \
  --name my-web-acl \
  --scope REGIONAL \
  --default-action Allow={} \
  --rules '[
    {
      "Name": "AWSManagedRulesCommonRuleSet",
      "Priority": 1,
      "OverrideAction": {"None": {}},
      "Statement": {
        "ManagedRuleGroupStatement": {
          "VendorName": "AWS",
          "Name": "AWSManagedRulesCommonRuleSet"
        }
      },
      "VisibilityConfig": {
        "SampledRequestsEnabled": true,
        "CloudWatchMetricsEnabled": true,
        "MetricName": "CommonRuleSet"
      }
    }
  ]' \
  --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName=my-web-acl \
  --region ap-northeast-1
```

---

## よく使うマネージドルールセット

| ルールセット | 内容 |
|---|---|
| AWSManagedRulesCommonRuleSet | OWASP Top 10 相当の一般的な脅威 |
| AWSManagedRulesSQLiRuleSet | SQL インジェクション |
| AWSManagedRulesKnownBadInputsRuleSet | ログ4j（Log4Shell）など既知の攻撃パターン |
| AWSManagedRulesAmazonIpReputationList | AWS が把握している悪意ある IP |
| AWSManagedRulesBotControlRuleSet | ボット識別（有料） |

---

## レートリミットの設定

```json
{
  "Name": "RateLimitRule",
  "Priority": 2,
  "Action": {"Block": {}},
  "Statement": {
    "RateBasedStatement": {
      "Limit": 1000,
      "AggregateKeyType": "IP"
    }
  }
}
```

5分間に同一 IP から 1000 リクエストを超えたらブロック。API への大量アクセス・クレデンシャルスタッフィング攻撃への対策に使える。

---

## WAF ログの有効化

```bash
# CloudWatch Logs にログを送る
aws wafv2 put-logging-configuration \
  --logging-configuration '{
    "ResourceArn": "arn:aws:wafv2:ap-northeast-1:123456789012:regional/webacl/my-web-acl/xxxx",
    "LogDestinationConfigs": [
      "arn:aws:logs:ap-northeast-1:123456789012:log-group:aws-waf-logs-my-app"
    ]
  }'
```

ログ先のロググループ名は `aws-waf-logs-` で始まる必要がある。

---

## カウントモードで始める

最初から Block にすると正常なリクエストまで弾いてしまうリスクがある。まず Count（カウントのみ）で動かして、どんなリクエストがルールにマッチするか確認してから Block に切り替える。

```
Count モード: ルールにマッチしたリクエストを記録するだけ（通す）
Block モード: ルールにマッチしたリクエストを 403 で返す
```

新しいルールは必ず Count → 確認 → Block の順で適用する。
