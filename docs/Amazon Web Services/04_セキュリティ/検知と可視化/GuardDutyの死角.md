<!-- Space: harukaaibarapublic -->
<!-- Parent: 検知と可視化 -->
<!-- Title: GuardDuty の死角 -->

# GuardDuty の死角

「GuardDuty を有効化しているから大丈夫」——これは半分正しくて半分間違い。GuardDuty は強力だが、**検知できない攻撃パターンが明確に存在する**。それを知らずに安心しているのが最も危険な状態だ。

GuardDuty が何を見ていて、何を見ていないかを理解することで、対策の穴を埋められる。

---

## GuardDuty が検知できるもの（前提確認）

GuardDuty のデータソースと検知範囲：

| データソース | 検知できること |
|---|---|
| CloudTrail | 異常な API 呼び出し、漏洩クレデンシャルの使用、権限昇格の試み |
| VPC Flow Logs | C2 通信、ポートスキャン、不審な外部通信 |
| DNS ログ | DGA（ドメイン生成アルゴリズム）、既知の悪意あるドメインへのクエリ |
| EKS 監査ログ | Kubernetes の不審な操作 |
| Runtime Monitoring | EC2・ECS・EKS 上のプロセス・ファイル・ネットワーク操作（エージェント必要） |

---

## GuardDuty が検知できない主なパターン

### ① 「正規の操作」に見える内部不正・権限乱用

GuardDuty は異常パターンを検知するが、**正規のクレデンシャルで正規の操作をされると検知できない**。

例：
- 退職予定の社員が辞める前に S3 から全データをダウンロード
- 権限を持つ開発者が本番 DB に直接アクセスしてデータを持ち出す
- 正規の管理者アカウントで設定変更（悪意があっても「正常」に見える）

**対策**：CloudTrail の定期レビュー、IAM Access Analyzer、異常アクセスの手動チェック。「普段やらない操作をしていないか」をベースラインと比較する。

---

### ② 低速・分散型の攻撃（slow and low）

GuardDuty の ML モデルは急激な異常を検知するのが得意。**長期間にわたってゆっくり行われる偵察・データ窃取は検知しにくい**。

例：
- 1日1件ずつ S3 オブジェクトをダウンロードして90日かけて全量を持ち出す
- 週に1回だけ不審な外部 IP に少量のデータを送信
- 数ヶ月かけてゆっくり IAM 権限を昇格させる

**対策**：Security Lake + Athena で長期のトレンドを定期的に分析。異常検知は「瞬間」だけでなく「累積」でも見る。

---

### ③ AWS の管理外リソースからの攻撃

GuardDuty は **AWS リソース内の動きしか見ない**。

例：
- EC2 上で動くアプリの脆弱性（OWASP Top 10）を突いた攻撃
- S3 に置いたファイルに含まれるマルウェア
- RDS や ElastiCache に対する SQL インジェクション
- CloudFront の背後にある Web サーバーへの XSS・CSRF

**対策**：WAF（アプリ層）・Inspector（脆弱性スキャン）・Macie（機密データ検知）と組み合わせる。GuardDuty はインフラ層で、アプリ層は別途対策が必要。

---

### ④ サプライチェーン攻撃

GuardDuty は使っている Lambda 関数・コンテナイメージ・npm パッケージの**中身の安全性は見ない**。

例：
- 依存パッケージに仕込まれたマルウェアが Lambda 上で動く
- ECR にプッシュしたコンテナイメージに脆弱なライブラリが含まれる
- CI/CD パイプラインに悪意あるコードが混入する

**対策**：Inspector（ECR イメージの CVE スキャン）・Dependabot・SBOM（ソフトウェア部品表）の管理。GitHub Actions のサードパーティアクションを SHA で固定する。

---

### ⑤ 設定ミス（Misconfiguration）

GuardDuty は「攻撃者の行動」を見るが、**設定ミスによるリスクは検知しない**。

例：
- S3 バケットがパブリック公開になっている
- セキュリティグループが 0.0.0.0/0 で全ポート開放
- IAM ロールに AdministratorAccess がついている
- RDS がパブリックサブネットに置かれている

**対策**：Security Hub（FSBP）・AWS Config・IAM Access Analyzer。これらは「現在の設定が安全かどうか」を継続的にチェックする。

---

### ⑥ GuardDuty のログが届かない状態

当たり前だが、**GuardDuty が無効化されていたり、対象リージョンをカバーしていなければ検知できない**。

攻撃者が最初にやることの一つが「検知を無効化すること」。

```bash
# CloudTrail で GuardDuty の無効化操作がないか確認
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=DeleteDetector

# 全リージョンで GuardDuty が有効か確認
for region in $(aws ec2 describe-regions --query 'Regions[].RegionName' --output text); do
  status=$(aws guardduty list-detectors --region $region \
    --query 'length(DetectorIds)' --output text)
  echo "$region: $status detector(s)"
done
```

**対策**：CloudTrail Insights で `StopLogging`・`DeleteTrail`・`DeleteDetector` 操作をアラートにする。GuardDuty の無効化操作を EventBridge でリアルタイム検知する。

```json
// EventBridge ルール：GuardDuty 無効化を即時 Slack 通知
{
  "source": ["aws.guardduty"],
  "detail-type": ["GuardDuty Finding"],
  "detail": {
    "type": ["Stealth:IAMUser/CloudTrailLoggingDisabled"]
  }
}
```

---

## GuardDuty を補完する構成

```
GuardDuty          ← 異常な挙動・脅威の検知（インフラ層）
Security Hub       ← 設定ミス・コンプライアンス違反（CSPM）
Inspector          ← 脆弱性（CVE）のスキャン
WAF                ← アプリ層の攻撃（SQLi・XSS・DDoS）
Macie              ← S3 内の機密データ検出・不正アクセス
CloudTrail + Athena ← 長期トレンド分析・手動調査
Config             ← リソース設定の変化の記録と評価
```

GuardDuty が「今何か異常が起きているか」を見るのに対して、それぞれ別のレイヤーをカバーする。これらを組み合わせてはじめてセキュリティの全体像が見える。

---

## 参考

- [GuardDuty Finding Types](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_finding-types-active.html)
- [AWS Security Hub — FSBP](https://docs.aws.amazon.com/securityhub/latest/userguide/fsbp-standard.html)
- [AWS の共有責任モデル](https://aws.amazon.com/compliance/shared-responsibility-model/)
