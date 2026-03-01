<!-- Space: harukaaibarapublic -->
<!-- Parent: 検知と可視化 -->
<!-- Title: ログ集約と SIEM 選定 -->

# ログ集約と SIEM 選定

「インシデントが起きてから調べようとしたら、ログがバラバラで何も追えなかった」「GuardDuty のアラートは出るけど、それが本当に危険なのか判断できない」——ログを一元管理して怪しい動きを検知する仕組みを作ろうとすると、選択肢が多すぎて何から手をつければいいか分からなくなる。

2025〜2026 年時点での現実解をまとめる。

---

## まず絶対やること：Amazon Security Lake の有効化

SIEM を何にするかより先に、**Security Lake を有効化することが全員一致の推奨**。

Security Lake は AWS ログを OCSF（Open Cybersecurity Schema Framework）形式に正規化して自分の S3 バケットに溜めるサービス。対象は CloudTrail・VPC Flow Logs・Route53 クエリログ・Security Hub findings・GuardDuty 等。

```bash
# 有効化（マネジメントコンソールからでも可）
aws securitylake create-data-lake \
  --configurations '[{"region":"ap-northeast-1","encryptionConfiguration":{"kmsKeyId":"alias/aws/s3"}}]'
```

なぜこれが最初かというと、**ここに溜めたログは SIEM を後で変えても消えない**から。SIEM は乗り換えられるが、生ログは乗り換えられない。Security Lake を入れておけばベンダーロックインを避けながら好きな SIEM を選べる。また、Athena でそのままクエリもできるので SIEM が不要な場面の分析にも使える。

---

## AWS ネイティブ検知レイヤー

Security Lake の上に GuardDuty と Security Hub を乗せるのが AWS ネイティブの基本構成。

**GuardDuty**：ML ベースの脅威検知。CloudTrail の異常・VPC Flow の不審通信・DNS ベースの C2 検知などを設定ゼロで行う。EC2・EKS・S3・RDS・Lambda への保護オプションもある。カスタム検知ルールは書けない（AWS の検知ロジックを使う形）。

**Security Hub**：GuardDuty・Inspector・Macie・Config・IAM Access Analyzer の findings を一箇所に集約する。CSPM 的な用途にも使える。EventBridge と組み合わせて Slack への通知ルーティングに使う。

この2つだけでも相当なカバレッジになるが、**複数サービスをまたいだ相関分析・カスタム検知ルール・非 AWS ソースのログ取り込み**は別途 SIEM が必要になる。

---

## SIEM 選定：Gartner 2025 MQ と現場の実態

### Gartner Magic Quadrant 2025 の Leader

| ベンダー | 特徴 |
|---|---|
| Google Chronicle | ビジョン評価が全ベンダー中トップ。Mandiant 脅威インテル込み |
| Microsoft Sentinel | コストパフォーマンスが強い。Microsoft E5 ユーザーは大幅割引 |
| Splunk Enterprise Security | 最も成熟した検知コンテンツ。ただし高コストで移行が進んでいる |
| Exabeam・Securonix・Gurucul | UEBA 特化の Leaders |

CrowdStrike Falcon Next-Gen SIEM は 2025 年時点で MQ 対象外だが、成長速度が最も速いベンダーとして注目されている。

---

### 選択肢の比較

#### Google Chronicle（Google Security Operations）
**検知品質・ロードマップで選ぶなら現状ベスト。**

- Mandiant のインシデントレスポンス実績に基づく検知ルールが組み込み済み
- ペタバイト規模でもサブ秒検索
- YARA-L 言語でカスタム検知ルールが書ける
- 独自の SOAR（300 以上の統合）が内蔵、Slack も標準対応
- Security Lake への subscriber 連携あり
- flat-rate 料金（per-GB 課金ではない）

AWS との連携は CloudTrail・GuardDuty のパーサーが用意されているが、Microsoft/GCP ほど seamless ではない。AWS 専業チームより、マルチクラウドや GCP 混在環境に特に刺さる。

IDC の調査では 3 年 ROI が 407%、投資回収 7 ヶ月未満という数字が出ている。

#### Microsoft Sentinel
**コスト重視・大規模環境向け。**

- Microsoft 365・Entra ID・Defender との連携は他の追随を許さない
- E5 ライセンス保有者は大量の無料データ枠が使える
- Logic Apps 経由の Slack 通知は成熟している
- AWS 連携は CloudTrail・GuardDuty・Security Hub のコネクタが存在するが、AWS ネイティブほど洗練されていない
- Cribl と組み合わせて Splunk からの移行先として使われることが多い

Microsoft スタックが中心でない場合はやや割高感があるが、スケールしたときのコスト効率は Splunk に比べて大幅に優れる。

#### Splunk Enterprise Security
2025 年時点でも最も成熟した検知コンテンツと SPL（Splunk Processing Language）の表現力は群を抜くが、**ライセンスコストが問題で移行が加速している**。

`$1,800〜$2,500+/GB/day` という価格帯に加え、Cisco に買収（2024 年）されてからのロードマップ不透明感もあり、Sentinel や Chronicle への移行事例が増えている。Cribl を前段に入れてインジェスト量を削減するのが現実的なコスト対策。今から新規に導入する理由は薄い。

#### Datadog Cloud SIEM
**既存の Datadog 環境に追加するなら最もシンプル。**

- CloudTrail・GuardDuty・Security Hub・WAF・S3 アクセスログ等の AWS 連携がネイティブ
- Security Lake の subscriber 連携も対応
- インフラメトリクス・APM トレース・セキュリティシグナルを同じ画面で見られるのが唯一の価値
- Slack 通知はファーストクラスの対応
- Gartner MQ の SIEM Leaders には入っていない。専任 SOC チームには検知アナリティクスの深さが物足りなくなる場面がある

DevOps 寄りのチームが「シフトレフトでセキュリティも見たい」という文脈で使うのが一番フィットする。

#### Elastic Security
**エンジニアリング文化のチームで自由度が欲しいなら。**

- ELK Stack ベースにセキュリティ特化の検知ルールと ML を追加したもの
- 検知ルールが [GitHub でオープン](https://github.com/elastic/detection-rules)で、MITRE ATT&CK マッピング済み
- AWS の CloudTrail・VPC Flow・GuardDuty・EKS 等のコネクタが充実
- クラスターサイズ課金（per-GB ではない）でコストが読みやすい
- Elastic Cloud（SaaS）と自己ホスト（EC2/EKS）を選べる
- Gartner MQ はリーダーに入っていない。チューニングと運用に工数がかかる

#### CrowdStrike Falcon Next-Gen SIEM
**既存で Falcon（EDR）を使っているなら最有力の統合先。**

- Index-free アーキテクチャで従来型 SIEM より高速・低コストをうたう（150 倍高速、50% ストレージ削減）
- 2025 年 11 月に AWS Quick Launch が公開され、CloudTrail・GuardDuty・Security Hub との自動連携が整備された
- AI ベースの UEBA が組み込み
- Falcon SOAR（Fusion）経由で Slack 通知対応
- 検知コンテンツの成熟度は Splunk ES や Chronicle に比べるとまだ発展途上

#### Wazuh + OpenSearch（OSS）
**コスト最小で本番運用したいなら。**

- OSS ライセンスで無償。商用サポートは Wazuh Inc. から別途
- Wazuh 4.12（2025 年 5 月）で ARM 対応・eBPF ファイル整合性監視・AWS Security Hub 統合が追加
- AWS Marketplace に AMI が公開されている
- PCI-DSS・CIS・HIPAA のコンプライアンスフレームワークが組み込み
- Gartner Peer Insights 4.7/5（実務者レビュー）
- 1 ノードあたり約 500 EPS が目安。大規模はマルチノードクラスター構成が必要

#### SIEM on Amazon OpenSearch Service（aws-samples）
**AWS 公式の「自分で建てる SIEM」キット。**

AWS が [GitHub で公開している OSS](https://github.com/aws-samples/siem-on-amazon-opensearch-service)。CloudFormation または CDK で 30 分デプロイするだけで AWS ログ特化の SIEM が立ち上がる。v2.10.4（2025 年 6 月）まで活発にメンテされている。

含まれているもの：
- CloudTrail・VPC Flow Logs・GuardDuty・WAF・ALB/NLB・RDS・Route53・S3・ECS・OS ログ・Okta 等の**ログパーサーがプリビルド済み**（約 30 種類）
- ECS（Elastic Common Schema）で正規化
- GeoIP（MaxMind）と脅威インテル（Tor・Abuse.ch・AlienVault OTX・独自 IoC）エンリッチ
- ログタイプ別の OpenSearch Dashboards がセット済み
- Security Lake・Control Tower との統合あり

**分析でどこまでできるか（正直に）：**

| 機能 | 評価 |
|---|---|
| ログ検索・探索 | ◎ OpenSearch KQL で全ログを横断検索できる |
| 可視化ダッシュボード | ○ ログタイプ別のダッシュボードが最初から付いてくる |
| アラート | △ OpenSearch Alerting プラグインで閾値監視は作れるが、Slack まで繋ぐには Lambda が別途必要 |
| 相関分析 | △ 自動相関エンジンはない。「このIPが5分以内に3サービスに触った」のような相関は自分でクエリを書く必要がある |
| 脅威インテル連携 | ○ IoC エンリッチはインジェスト時に Lambda で自動付与される |
| 異常検知（ML） | △ OpenSearch ML Commons の基本的な異常検知は使えるが、GuardDuty や Splunk MLTK の精度には及ばない |
| UEBA（ユーザー行動分析） | ✗ なし |
| 自動対応（SOAR） | ✗ なし。Lambda を自分で書く |
| インシデント管理 | ✗ なし |

一言でいうと「**ログをまとめて検索・可視化する基盤**」であって、「怪しい動きを自動で発見してくれる SIEM」ではない。GuardDuty が「自動検知」を担い、この SIEM は「調査・探索・ダッシュボード確認」を担う、という役割分担が現実的。

Elastic Security と近い立ち位置だが、Elastic Security のほうが検知ルールのコンテンツ（MITRE 対応済みルール）・ML ジョブ・タイムライン調査 UI が充実している。この aws-samples 版は**AWS ログ特化のパーサーが全部揃った状態でスタートできる**のが差別化点。

**コスト**：OpenSearch クラスター + Lambda + S3 のサービスコストのみ。ライセンス費用なし。ただし本番用には t3.medium より大きいインスタンスが必要。

---

## Cribl：コストを大幅に削減するミドルウェア

Cribl Stream は SIEM ではなくログパイプライン。SIEM に投入する前にフィルタリング・ルーティングを行い、**ingest 量を 40〜80% 削減**する。

```
各ログソース
    ↓
  Cribl Stream  ← ここでフィルタ・正規化・ルーティング
    ├→ SIEM（高頻度・重要ログ）
    └→ Security Lake（全量アーカイブ）
```

per-GB 課金の SIEM（Splunk・Sentinel・Datadog 等）を使っている環境では、Cribl を入れるだけでライセンスコストが激変する。Splunk から Sentinel への移行時に Cribl を中継ぎにすることで、移行期間中の二重コストも抑えられる。

---

## Slack アラートの構成

どの SIEM も Slack 対応しているが、シンプルさでは以下の順：

**AWS ネイティブ（SIEM 不要）**：
```
Security Hub findings → EventBridge → AWS Chatbot → Slack
```
Lambda 不要。ただしメッセージフォーマットのカスタマイズは限定的。

**カスタムフォーマットが必要な場合**：
```
Security Hub findings → EventBridge → Lambda → Slack Webhook
```

各 SIEM を使う場合は、SOAR 機能（Chronicle の SOAR・Splunk SOAR・Falcon Fusion 等）または単純な Webhook 設定で対応する。

---

## 構成まとめ

```
Security Lake（全員必須・ログのホーム）
      ↓
GuardDuty + Security Hub（AWS ネイティブ検知）
      ↓（必要に応じて Cribl でフィルタリング）
SIEM を1つ選ぶ
  ├ 検知品質・ロードマップ最優先  → Google Chronicle
  ├ 既存 Datadog 環境            → Datadog SIEM
  ├ エンジニアリング文化・OSS     → Elastic Security
  ├ 既存 CrowdStrike Falcon 環境  → Falcon Next-Gen SIEM
  ├ Microsoft / 大規模コスト優先  → Microsoft Sentinel
  ├ コスト最小・自己運用可        → Wazuh + OpenSearch
  └ AWS ログ特化・自前構築        → SIEM on Amazon OpenSearch Service
      ↓
Slack アラート（AWS Chatbot または各 SIEM の SOAR）
```

---

## 参考

- [Gartner Magic Quadrant for SIEM 2025 — Google](https://cloud.google.com/blog/products/identity-security/google-is-named-a-leader-in-the-2025-gartner-magic-quadrant-for-siem)
- [Gartner Magic Quadrant for SIEM 2025 — Microsoft](https://www.microsoft.com/en-us/security/blog/2025/10/16/microsoft-named-a-leader-in-the-2025-gartner-magic-quadrant-for-siem)
- [Gartner Magic Quadrant for SIEM 2025 — Splunk](https://www.splunk.com/en_us/form/gartner-siem-magic-quadrant.html)
- [AWS Security Lake ベストプラクティス](https://aws.github.io/aws-security-services-best-practices/guides/security-lake/)
- [AWS Security Maturity Model — SIEM カスタム脅威検知](https://maturitymodel.security.aws.dev/en/3.-efficient/siem-custom-threat-detection/)
- [CrowdStrike Falcon Next-Gen SIEM AWS Quick Launch（2025 年 11 月）](https://aws.amazon.com/about-aws/whats-new/2025/11/automated-integration-crowdstrike-falcon-next-gen/)
- [Cribl によるコスト削減事例（80% 削減）](https://cribl.io/customers/sra/)
- [Wazuh 2025 年の動向](https://hawatel.com/en/blog/why-open-source-siem-xdr-has-gained-popularity-in-2025-the-example-of-wazuh/)
- [Amazon Security Lake サードパーティ統合](https://docs.aws.amazon.com/security-lake/latest/userguide/integrations-third-party.html)
- [SIEM on Amazon OpenSearch Service（aws-samples）](https://github.com/aws-samples/siem-on-amazon-opensearch-service)
