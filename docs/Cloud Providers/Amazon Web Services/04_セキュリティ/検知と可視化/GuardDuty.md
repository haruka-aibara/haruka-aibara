<!-- Space: harukaaibarapublic -->
<!-- Parent: 検知と可視化 -->
<!-- Title: Amazon GuardDuty -->

# Amazon GuardDuty

「EC2 インスタンスが暗号通貨マイニングをしていた」「漏洩したアクセスキーが別の国から使われた」——こういった異常はログをずっと目で確認していても気づけない。GuardDuty は CloudTrail・VPC フローログ・DNS ログを機械学習で分析して、脅威を自動検知するサービス。有効化するだけで動作し、エージェントのインストールは不要。

---

## 検知できる脅威の例

| カテゴリ | 具体例 |
|---|---|
| 不正アクセス | 漏洩したアクセスキーが異常な場所から使われた |
| 暗号通貨マイニング | EC2 が既知のマイニングプールと通信している |
| マルウェア | EC2 が C2（コマンド＆コントロール）サーバーと通信している |
| 設定ミス悪用 | S3 バケットが公開状態になっていてアクセスされている |
| 内部不正 | 普段使わない AWS リソースへの大量アクセス |
| コンテナ脅威 | EKS クラスター内での不審な操作 |

---

## 有効化

```bash
# GuardDuty を有効化
aws guardduty create-detector \
  --enable \
  --finding-publishing-frequency FIFTEEN_MINUTES

# 組織全体で有効化
aws guardduty enable-organization-admin-account \
  --admin-account-id 123456789012
```

有効化するだけで、CloudTrail・VPC フローログ・Route53 DNS ログの分析が自動で始まる。追加のログ設定は不要。

---

## 検知結果（Finding）の確認

```bash
# 未解決の HIGH 以上の検知結果を確認
aws guardduty list-findings \
  --detector-id <detector-id> \
  --finding-criteria '{
    "Criterion": {
      "severity": {
        "Gte": 7
      }
    }
  }'

# 詳細を確認
aws guardduty get-findings \
  --detector-id <detector-id> \
  --finding-ids <finding-id>
```

---

## 自動対応の仕組み

GuardDuty の検知結果を EventBridge でトリガーして自動対応できる。

```
GuardDuty が "CryptoCurrency:EC2/BitcoinTool.B" を検知
    ↓
EventBridge ルールがマッチ
    ↓
Lambda が対象 EC2 インスタンスを隔離（セキュリティグループを変更）
    ↓
Slack に通知
```

---

## 抑制ルール（Suppression Rules）

正常な操作が誤検知される場合、抑制ルールで特定の検知結果を非表示にできる。

```bash
# テスト環境からのアクセスを抑制
aws guardduty create-filter \
  --detector-id <detector-id> \
  --name "suppress-dev-pentest" \
  --action ARCHIVE \
  --finding-criteria '{
    "Criterion": {
      "resource.instanceDetails.tags.key": {
        "Equals": ["Environment"]
      },
      "resource.instanceDetails.tags.value": {
        "Equals": ["Development"]
      }
    }
  }'
```

---

## コスト

GuardDuty は分析するログの量に応じて課金される。最初の 30 日間は無料トライアルで使えて、有効化後にどれくらいかかるか予測できる。

VPC フローログの分析が最もコストがかかる傾向がある。トラフィックの多い環境では費用を確認してから本番運用に移行する。
