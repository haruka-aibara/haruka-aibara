# AWS クラウドセキュリティエンジニアが自動車業界で求められること

自動車業界が SDV（Software Defined Vehicle）へ移行する中で、「車とクラウドが繋がる」場所が爆発的に増えている。その接続点を守るのがクラウドセキュリティエンジニアの仕事になる。自動車専門知識より先に、「車がクラウドに何を求めているか」「それが今の仕事とどう重なるか」を整理しておく。

---

## AWS は自動車業界で使われ続けるか

結論から言うと、**当面は AWS が主軸であり続ける**。

現時点での主要採用例：

- **Nissan**：SDV 開発の統合クラウド環境を AWS に構築。世界 5,000 人以上の開発者が使用（2025 年 12 月発表）
- **Stellantis**（Jeep・RAM・Fiat 等）：「Virtual Engineering Workbench」を AWS 上に構築し、SDV 開発の中枢として運用
- **Volkswagen**：工場の製造クラウド基盤として AWS と 5 年契約を延長（2025 年）
- **HERE + AWS SDV Accelerator**：地図・位置情報と AWS AI を組み合わせた SDV 開発環境（2025 年 9 月）

Google Cloud（Toyota Woven・Renault・Subaru）や Azure（GM/Cruise・BMW）にも採用例はあるが、**SDV 開発インフラとコネクテッドビークルの IoT 領域では AWS が最も厚いエコシステムを持っている**。

ただし「全部 AWS」にはならない。VW は製造が AWS、コネクティビティが Azure、AI アシスタントが Google Cloud という分業構成だ。マルチクラウドが業界標準になりつつある中で、AWS が「SDV 開発基盤と車両データ処理の主軸」というポジションを維持する可能性が高い。

---

## 自動車顧客が AWS クラウドセキュリティに持ち込む固有の要件

### 1. OTA アップデートパイプラインのセキュリティ

車のファームウェアを空中から更新する OTA（Over The Air）は、SDV の核心機能だ。そしてこの OTA パイプラインには、**UN R156（国連規制）が法的なセキュリティ要件を課している**。

2024 年 7 月から EU で販売される全車種に適用が拡大されており、グローバル展開する OEM は全社対応が必須になった。日本・韓国も順次国内法に反映している。

OTA パイプラインで要求されること：

| 要件 | 内容 | AWS での実装例 |
|---|---|---|
| ファームウェアの完全性検証 | 配信するバイナリへの電子署名と、車両側での署名検証 | AWS Signer + S3 オブジェクト整合性 |
| 通信の暗号化・認証 | 車両とバックエンド間の TLS 相互認証 | AWS IoT Core + ACM Private CA |
| 配信の監査ログ | 「いつ・何のバージョンを・どの車両に配信したか」の完全な記録 | CloudTrail + CloudWatch Logs + S3 |
| ロールバック機能 | 更新失敗時の旧バージョン復旧 | S3 バージョニング + IoT Jobs のロールバック機能 |
| 配信対象の検証 | 更新ファイルと車両の互換性チェック | IoT Fleet Indexing + カスタム検証ロジック |

Web サービスの CI/CD パイプラインと構造は同じだが、**「規制要件を満たしていることを証明できること」が追加される**。型式認証の審査資料として監査ログが提出されるため、ログの保全・改ざん防止がセキュリティ要件になる。

### 2. PKI と証明書管理：数百万台のスケール

コネクテッドビークルでは、車両 1 台 1 台が「識別可能なデバイス」としてクラウドに接続する。これは IoT セキュリティの問題だが、自動車特有のスケールと制約がある。

**台数のスケール**：1 つの OEM が保有する車両フリートは数百万〜数千万台。この規模の PKI 運用は、エンタープライズ IT の証明書管理とは桁が違う。

**ライフサイクルの長さ**：スマートフォンは 2〜5 年で買い替えるが、車は 10〜15 年使われる。2026 年に発行した証明書の有効期限管理と、アルゴリズムの陳腐化（2040 年に SHA-256 が安全かどうか）を設計段階から考える必要がある。

**制約**：ECU のファームウェア更新と違い、PKI のルート証明書はハードウェアに焼き込まれることが多い。「証明書が漏洩したら全台にセキュリティパッチを配信」ではなく、侵害を前提とした設計が必要だ。

AWS での対応：

- **AWS IoT Core** の X.509 デバイス証明書管理
- **ACM Private CA**（AWS Certificate Manager Private Certificate Authority）でプライベート PKI を構築し、OEM 独自のルート CA 体制を作る
- **AWS IoT Device Defender**：デバイスの異常行動検知（フリート規模での脅威検出）

### 3. 車両データの収集・分析基盤のセキュリティ

コネクテッドビークルは走行中に大量のデータをクラウドへ送信する。位置情報・運転挙動・センサーデータ——これらは個人情報保護法（GDPR・個人情報保護法）と、自動車固有の CSMS（サイバーセキュリティ管理システム）規制の両方が絡む。

**AWS IoT FleetWise** は自動車向けに特化した車両データ収集サービスで、CAN バスのシグナルを条件付きでフィルタリングしながら S3 に収集できる。セキュリティエンジニアとして関わる場面：

- 収集データの分類（個人情報・安全データ・診断データ）と保護レベルの設定
- IAM ポリシーによるデータアクセス制御（開発者がすべての車両データを見られないようにする）
- GDPR 対応：ユーザーが「自分の車のデータ削除」を要求したときの S3 オブジェクト削除フロー
- データの転送元（車両 → TCU → AWS IoT Core）の通信経路全体のセキュリティ確認

### 4. サプライチェーンセキュリティ

自動車は「完成車メーカー（OEM）→ Tier 1 サプライヤー → Tier 2 サプライヤー」という複雑なサプライチェーンで作られる。ECU のファームウェアは Tier 1 が作り、OEM が統合する。このチェーン全体に、UN R155 のセキュリティ要件が流下する。

クラウドセキュリティエンジニアとして求められる場面：

- **SBOM（Software Bill of Materials）管理**：車載ソフトウェアに含まれる OSS コンポーネントの脆弱性追跡。AWS Inspector や Amazon Inspector での SBOM 管理が要件になりつつある
- **Artifact の署名と検証**：サプライヤーが納品するファームウェアイメージの署名検証パイプライン
- **アクセス管理**：Tier 1 サプライヤーが OEM の AWS 環境に接続するときのクロスアカウントアクセス制御

---

## 今後増えそうな案件タイプ

**ケース 1：OTA セキュリティ基盤の設計・構築**

「UN R155/R156 に対応した OTA パイプラインを AWS で作りたい」という要件は、法規制の義務化が進むにつれ確実に増える。ファームウェア署名・配信ログ・ロールバック・車両認証が揃った AWS ベースのリファレンスアーキテクチャを求める案件だ。

**ケース 2：コネクテッドビークルの CSMS 対応**

OEM が UN R155 の型式認証を取るには、CSMS（サイバーセキュリティ管理システム）の組織認証が必要だ。そのバックエンドとして「クラウド上での脆弱性監視・インシデント対応・監査ログ管理」の仕組みを作る案件が出てくる。Security Hub + GuardDuty + CloudTrail の組み合わせが基盤になる。

**ケース 3：フリート規模の IoT セキュリティ監視**

数十万〜数百万台のコネクテッドビークルを「疑わしい通信パターンを持つデバイスが出たらアラートを上げる」体制で監視する。AWS IoT Device Defender の Detect 機能（機械学習ベースの異常検知）の設計・運用が核になる。

**ケース 4：V2X・車外通信の保護**

V2X（Vehicle to Everything：車と車、車とインフラの通信）が普及するにつれ、クラウド側でのメッセージブローカー・PKI 管理・スプーフィング検知が求められる。これは IoT/5G のセキュリティ設計と重なる領域だ。

---

## Google Cloud や Azure に仕事が流れるリスクはあるか

**AAOS SDV（Android Automotive OS の車全体への拡張）を採用した OEM が Google Cloud に引き寄せられる**という動きが 2026 年 3 月以降に本格化している（詳細は「クラウドエンジニアから見た SDV の世界」参照）。

ただし **セキュリティ領域に限れば AWS に有利な状況が続く**と見られる理由がある：

- **AWS IoT FleetWise**：車両テレメトリ収集専用サービス。CAN バスのシグナルデコード・条件付き収集まで対応しており、Google Cloud に直接対応するサービスがない
- **Connected Mobility Solution（CMS）on AWS**：OTA・フリート管理・車両認証をバンドルしたリファレンスアーキテクチャ。自動車顧客の出発点になりやすい
- **既存の自動車顧客基盤**：Nissan・Stellantis・VW（製造）という大型案件が AWS に積み上がっており、追加のセキュリティ要件もそのまま AWS に乗る可能性が高い

セキュリティエンジニアとして「Google Cloud や Azure でないと実現できない要件」はほぼない。リスクは技術的な置き換えより「Renault のように Google Cloud を全面採用するプロジェクトにアサインされる」ケースだ。マルチクラウド対応のスキルとして、最低限の Google Cloud セキュリティ（VPC Service Controls・Secret Manager あたり）の理解を持っておくと安心できる。

---

## まとめ：何を押さえておくか

自動車業界でクラウドセキュリティエンジニアとして求められる仕事は、**既存のスキルが「自動車固有の法規制」という文脈で使われる**形になる。新しく覚えることより、今やっていることに「なぜそれが車では法的義務になるのか」という文脈が追加されるイメージだ。

優先度が高い順に：

1. **IoT セキュリティの基礎**（AWS IoT Core・デバイス証明書・IoT Device Defender）——車両接続の核
2. **PKI の設計経験**（ACM Private CA・証明書ライフサイクル）——大規模フリート管理に直結
3. **監査ログ設計**（CloudTrail・S3 保全・CloudWatch）——UN R155/R156 の証拠要件を満たすために必須
4. **サプライチェーンセキュリティ**（SBOM・Artifact 署名・クロスアカウントアクセス）——OEM-サプライヤー間の構造に対応

---

## 参考

- [AWS: Connected Mobility Solution on AWS](https://aws.amazon.com/solutions/implementations/connected-mobility-solution-on-aws/)
- [AWS: IoT FleetWise](https://aws.amazon.com/iot-fleetwise/)
- [AWS: IoT Device Defender](https://aws.amazon.com/iot-device-defender/)
- [Amazon Press: Nissan Accelerates SDV Development with AWS（2025年12月）](https://press.aboutamazon.com/aws/2025/12/nissan-accelerates-software-defined-vehicle-development-and-strengthens-ai-development-environment-with-new-aws-powered-platform)
- [AWS Blog: Stellantis SDV Transformation with Virtual Engineering Workbench](https://aws.amazon.com/blogs/industries/stellantis-sdv-transformation-with-the-virtual-engineering-workbench-on-aws/)
- [AWS Blog: Simulating Automotive E/E Architectures in AWS](https://aws.amazon.com/blogs/industries/simulating-automotive-e-e-architectures-in-aws-part-1-accelerating-the-v-model/)
- [UNECE: UN Regulation No. 155 - Cybersecurity and CSMS](https://unece.org/transport/documents/2021/03/standards/un-regulation-no-155-cybersecurity-and-cybersecurity-management)
- [UNECE: UN Regulation No. 156 - Software Update and SUMS](https://unece.org/transport/documents/2021/03/standards/un-regulation-no-156-software-update-and-software-update)
- [Upstream Security: 2026 Global Automotive Cybersecurity Report](https://upstream.auto/reports/global-automotive-cybersecurity-report/)
- [The New Stack: AWS と Google Cloud がマルチクラウド接続を構築（2025年11月）](https://thenewstack.io/aws-google-build-a-multicloud-bridge/)
