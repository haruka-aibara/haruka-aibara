<!-- Space: harukaaibarapublic -->
<!-- Parent: 検知と可視化 -->
<!-- Title: Bedrock ログと AI セキュリティ監視 -->

# Bedrock ログと AI セキュリティ監視

「社員が Bedrock を使い始めた。でも誰がどんなプロンプトを送ったか、機密情報を AI に貼り付けていないか、Guardrails が無効化されていないか——何かあったとき追える状態になっているか？」

生成 AI ツールを社内展開するとき、セキュリティエンジニアが最初に確認すべきはここ。**Bedrock のログはデフォルトでは半分しか取れていない。**

---

## Bedrock のログは 2 層構造になっている

| ログの種類 | 何を記録するか | デフォルト |
|---|---|---|
| **CloudTrail** | 管理操作（誰が何を設定したか） | **有効** |
| **Model Invocation Logging** | 推論の内容（何を聞いて何が返ってきたか） | **無効** |

CloudTrail は「誰が Guardrails を変更したか」「誰が Bedrock を有効化したか」といった管理操作を記録する。一方 Model Invocation Logging は推論リクエストとレスポンスの中身を記録する。

**後者を有効化しないと、誰が何を AI に聞いたか永遠にわからない。**

---

## CloudTrail が記録するもの（管理操作）

デフォルトで有効。追加設定なしで記録される。

```bash
# Bedrock 関連の CloudTrail イベントを確認
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventSource,AttributeValue=bedrock.amazonaws.com \
  --max-results 20
```

管理操作として記録される主なイベント：

| イベント名 | 意味 |
|---|---|
| `PutGuardrail` / `DeleteGuardrail` | Guardrails の作成・削除 |
| `PutModelInvocationLoggingConfiguration` | 推論ログの設定変更 |
| `DeleteModelInvocationLoggingConfiguration` | 推論ログの削除 |
| `CreateModelCustomizationJob` | モデルのファインチューニング開始 |
| `InvokeModel` | モデルの呼び出し（誰がいつ、どのモデルを） |

ただし `InvokeModel` の CloudTrail ログには**プロンプトとレスポンスの中身は含まれない**。リクエスト先のモデル ID とメタデータだけ。

---

## Model Invocation Logging を有効化する

推論の中身（プロンプト・レスポンス・メタデータ）を記録するには別途有効化が必要。送り先は S3・CloudWatch Logs のどちらか（または両方）。

### S3 に送る場合

コンプライアンス要件や長期保存、Athena での分析が目的なら S3。

```bash
# S3 バケットポリシーに Bedrock からの書き込み許可を追加（必須）
# ACL は無効化されている必要がある

# ログ設定を有効化
aws bedrock put-model-invocation-logging-configuration \
  --logging-config '{
    "s3Config": {
      "bucketName": "my-bedrock-logs-bucket",
      "keyPrefix": "bedrock-invocation-logs"
    },
    "textDataDeliveryEnabled": true,
    "imageDataDeliveryEnabled": true,
    "embeddingDataDeliveryEnabled": false
  }'
```

**S3 バケットポリシーの例：**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AmazonBedrockLogsWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "bedrock.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::my-bedrock-logs-bucket/bedrock-invocation-logs/*",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "123456789012"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:bedrock:ap-northeast-1:123456789012:*"
        }
      }
    }
  ]
}
```

### CloudWatch Logs に送る場合

リアルタイムでのアラートや CloudWatch Logs Insights でのクエリが目的なら CloudWatch。

```bash
# Bedrock 用の IAM ロールを作成（CloudWatch Logs への書き込み用）
aws iam create-role \
  --role-name bedrock-logging-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "bedrock.amazonaws.com"},
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {"aws:SourceAccount": "123456789012"},
        "ArnLike": {"aws:SourceArn": "arn:aws:bedrock:ap-northeast-1:123456789012:*"}
      }
    }]
  }'

# ログ設定を有効化
aws bedrock put-model-invocation-logging-configuration \
  --logging-config '{
    "cloudWatchConfig": {
      "logGroupName": "/aws/bedrock/model-invocations",
      "roleArn": "arn:aws:iam::123456789012:role/bedrock-logging-role"
    },
    "textDataDeliveryEnabled": true
  }'
```

### S3 か CloudWatch か

| 目的 | 推奨 |
|---|---|
| コンプライアンス・長期保存（1年以上） | S3 |
| インシデント時の即時調査 | S3 + Athena |
| リアルタイムアラート（異常なプロンプトを即検知） | CloudWatch Logs |
| 両方やりたい | 両方設定可能（同時有効化できる） |

---

## ログに含まれる情報

Model Invocation Logging のレコードには以下が含まれる：

```json
{
  "schemaType": "ModelInvocationLog",
  "schemaVersion": "1.0",
  "timestamp": "2025-01-15T10:23:45Z",
  "accountId": "123456789012",
  "identity": {
    "arn": "arn:aws:iam::123456789012:user/alice"
  },
  "region": "ap-northeast-1",
  "requestId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "operation": "InvokeModel",
  "modelId": "anthropic.claude-3-5-sonnet-20241022-v2:0",
  "input": {
    "inputBodyJson": {
      "messages": [{"role": "user", "content": "...プロンプトの内容..."}]
    },
    "inputTokenCount": 150
  },
  "output": {
    "outputBodyJson": {
      "content": [{"text": "...レスポンスの内容..."}]
    },
    "outputTokenCount": 300
  }
}
```

プロンプトとレスポンスの全文が記録される。**機密情報の持ち出し経路になっていないかを後から追跡できる唯一の手段がこのログ**。

---

## GuardDuty で Bedrock の脅威を検知する

GuardDuty は Bedrock に固有の脅威も検知する。

### GuardDuty が検知する Bedrock 固有の脅威

| 検知内容 | 意味 |
|---|---|
| Guardrails の不審な削除 | セキュリティ制御を無効化しようとしている |
| モデル学習データソースの変更 | データポイズニング攻撃の前兆 |
| Model Invocation Logging の無効化 | 証拠を消そうとしている可能性 |
| 新規ロケーションからの Bedrock API 呼び出し | クレデンシャル漏洩後の悪用 |

GuardDuty は追加設定なしに CloudTrail の Bedrock イベントを自動分析する。すでに GuardDuty を有効化していれば Bedrock も対象に入る。

### Lambda Protection と間接的なプロンプトインジェクション

Bedrock Agents を使っている場合、Lambda Protection を有効化する。Agent が外部ソース（ウェブサイト・PDF 等）を参照して処理する際、悪意ある指示が埋め込まれていると Lambda が C2 サーバーに通信するケースがある（間接プロンプトインジェクション）。

```bash
# Lambda Protection を有効化
aws guardduty update-detector \
  --detector-id <detector-id> \
  --features '[{"Name":"LAMBDA_NETWORK_LOGS","Status":"ENABLED"}]'
```

---

## 監視すべき具体的なアラート

### CloudWatch メトリクスフィルタで即時検知する

```bash
# 推論ログの削除を検知（証拠隠滅の試み）
aws logs put-metric-filter \
  --log-group-name "CloudTrail/logs" \
  --filter-name "BedrockLoggingDeleted" \
  --filter-pattern '{ $.eventSource = "bedrock.amazonaws.com" && $.eventName = "DeleteModelInvocationLoggingConfiguration" }' \
  --metric-transformations metricName=BedrockLoggingDeleted,metricNamespace=Security,metricValue=1

# Guardrails の削除を検知
aws logs put-metric-filter \
  --log-group-name "CloudTrail/logs" \
  --filter-name "BedrockGuardrailDeleted" \
  --filter-pattern '{ $.eventSource = "bedrock.amazonaws.com" && $.eventName = "DeleteGuardrail" }' \
  --metric-transformations metricName=BedrockGuardrailDeleted,metricNamespace=Security,metricValue=1
```

### Athena で定期チェックする（週次推奨）

```sql
-- ① Bedrock ログが無効化されたことがないか確認
SELECT eventtime, useridentity.arn, sourceipaddress
FROM cloudtrail
WHERE eventsource = 'bedrock.amazonaws.com'
  AND eventname = 'DeleteModelInvocationLoggingConfiguration'
  AND eventtime > now() - interval '30' day;

-- ② Guardrails が変更・削除されていないか
SELECT eventtime, useridentity.arn, eventname, requestparameters
FROM cloudtrail
WHERE eventsource = 'bedrock.amazonaws.com'
  AND eventname IN ('DeleteGuardrail', 'PutGuardrail')
  AND eventtime > now() - interval '30' day;

-- ③ 普段使わない時間帯や場所からの Bedrock 呼び出し
SELECT eventtime, useridentity.arn, sourceipaddress, requestparameters
FROM cloudtrail
WHERE eventsource = 'bedrock.amazonaws.com'
  AND eventname = 'InvokeModel'
  AND (hour(eventtime) NOT BETWEEN 8 AND 20
       OR sourceipaddress NOT LIKE '10.%')  -- 社内 IP 以外からの呼び出し
  AND eventtime > now() - interval '7' day;

-- ④ 大量のトークンを消費しているユーザー（異常な利用の検知）
SELECT useridentity.arn,
       COUNT(*) AS invocation_count,
       SUM(CAST(JSON_EXTRACT_SCALAR(responseelements, '$.usage.outputTokens') AS BIGINT)) AS total_output_tokens
FROM cloudtrail
WHERE eventsource = 'bedrock.amazonaws.com'
  AND eventname = 'InvokeModel'
  AND eventtime > now() - interval '7' day
GROUP BY useridentity.arn
ORDER BY total_output_tokens DESC;
```

---

## 最低限やること

Bedrock を社内で使い始めたなら、以下を最初にやる。

1. **Model Invocation Logging を有効化する**（S3 への保存が基本）
2. **Guardrails を設定する**（有害コンテンツ・機密情報の出力制御）
3. **CloudWatch アラートを設定する**（Logging 削除・Guardrails 削除の検知）
4. **GuardDuty が有効になっているか確認する**（Bedrock も自動で監視対象に入る）

---

## ビジネス側への伝え方

| 技術的な言い方 | ビジネス側に刺さる言い方 |
|---|---|
| Model Invocation Logging を有効化する | 「社員が AI に何を入力したか」の記録がないと、機密情報の漏洩があっても何がどこに渡ったか調査できない |
| Guardrails を設定する | AI が機密情報を外部に出力しないためのフィルタがないと、「AI を使ったデータ漏洩」への対応手段がない |
| CloudTrail でセキュリティ設定の変更を監視する | Guardrails が誰かに無効化されても、気づくタイミングがない |
| GuardDuty を有効化する | 漏洩したクレデンシャルが AI に悪用されているケースを、検知する仕組みなしに見逃す |

---

## 注意点

- **ログは同じリージョン内にしか送れない**（クロスリージョン送信は非対応）
- **プロンプトの全文がログに残る**ため、ログバケット自体のアクセス制御を厳密にする（誰でも読めてはいけない）
- Model Invocation Logging のログには個人情報が含まれる可能性がある。GDPR・個人情報保護法の観点で保存期間と削除ポリシーを明示しておく
- Bedrock Agents・Knowledge Bases・Flows を使う場合は CloudTrail のデータイベントも有効化すると `InvokeAgent` / `Retrieve` の詳細が記録される（追加課金あり）

---

## 参考

- [Amazon Bedrock — Model invocation logging](https://docs.aws.amazon.com/bedrock/latest/userguide/model-invocation-logging.html)
- [Amazon Bedrock — CloudTrail ログ](https://docs.aws.amazon.com/bedrock/latest/userguide/logging-using-cloudtrail.html)
- [GuardDuty — AI ワークロード保護](https://docs.aws.amazon.com/guardduty/latest/ug/ai-protection.html)
- [AWS Security Playbook — Bedrock インシデント対応](https://github.com/aws-samples/aws-customer-playbook-framework/blob/main/docs/Bedrock_Response.md)
