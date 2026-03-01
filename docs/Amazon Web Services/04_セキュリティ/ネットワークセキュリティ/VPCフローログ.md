<!-- Space: harukaaibarapublic -->
<!-- Parent: ネットワークセキュリティ -->
<!-- Title: VPC フローログ -->

# VPC フローログ

「不審なトラフィックがあったようだが、どの IP からどのポートに通信が来ていたかわからない」——VPC フローログは ENI を通過する IP トラフィックのメタデータを記録する。パケットの中身は記録しないが、「誰がどこにどれだけ通信したか」を把握できる。

---

## 記録される情報

| フィールド | 内容 |
|---|---|
| srcaddr / dstaddr | 送信元・宛先 IP |
| srcport / dstport | 送信元・宛先ポート |
| protocol | プロトコル番号（TCP=6, UDP=17） |
| action | ACCEPT または REJECT |
| bytes | バイト数 |
| start / end | 記録期間（Unix タイムスタンプ） |

---

## フローログの有効化

```bash
# VPC 全体のフローログを S3 に送る
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids vpc-xxxxxxxx \
  --traffic-type ALL \
  --log-destination-type s3 \
  --log-destination arn:aws:s3:::my-flow-logs-bucket/vpc-logs/

# CloudWatch Logs に送る場合
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids vpc-xxxxxxxx \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name /vpc/flowlogs \
  --deliver-logs-permission-arn arn:aws:iam::123456789012:role/flow-logs-role
```

`--traffic-type` は `ACCEPT`（通った通信のみ）、`REJECT`（拒否された通信のみ）、`ALL` の3種類。

---

## CloudWatch Logs Insights でのクエリ例

```
# REJECT された通信を集計（攻撃の検知に使える）
fields srcaddr, dstport, action
| filter action = "REJECT"
| stats count(*) as count by srcaddr, dstport
| sort count desc
| limit 20
```

```
# 特定ポートへの通信量を確認
fields srcaddr, dstaddr, bytes
| filter dstport = 22
| stats sum(bytes) as total_bytes by srcaddr
| sort total_bytes desc
```

---

## Athena でのログ分析

S3 に保存したフローログは Athena でSQLクエリできる。

```sql
-- 送信元 IP ごとの REJECT 件数（ポートスキャン検知）
SELECT srcaddr, COUNT(*) AS reject_count
FROM vpc_flow_logs
WHERE action = 'REJECT'
  AND day = '2024-01-15'
GROUP BY srcaddr
ORDER BY reject_count DESC
LIMIT 20;
```

---

## GuardDuty との連携

GuardDuty は VPC フローログを自動で取り込んで機械学習で異常を検知する。フローログを手動で分析しなくても、GuardDuty が「このインスタンスが外部の C2 サーバーと通信している」などを検知してくれる。

フローログはリアルタイム分析より事後調査向け、GuardDuty はリアルタイム検知向けという使い分け。

---

## コストの注意点

フローログはデータ量に応じて課金される（CloudWatch Logs への取り込み・保存・クエリ）。トラフィックの多い環境では S3 に送って Athena で分析するほうが安くなることが多い。

不要なフローログは無効化するか、S3 のライフサイクルポリシーで定期削除する。
