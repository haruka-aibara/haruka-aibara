# クラウドエンジニアから見た SDV の世界

自動車業界が今やっていること——ECU の統合、OTA アップデート、クラウド CI/CD、デジタルツイン——は、Web 系・クラウド系のエンジニアが日常でやっている概念と本質的に同じだ。ただし、ソフトのバグで人が死ぬという制約がある。

---

## 問題：車はいまどんな状態なのか

現代の車には ECU（電子制御ユニット）が 80〜150 個搭載されている。エンジン制御・ブレーキ・エアコン・カーナビ・カメラ——それぞれが別々のサプライヤーが作った別々のコンピュータだ。

これが何を意味するかというと、100 社のサプライヤーが 100 個のソフトウェアをバラバラに開発して、最後に「結合テスト」で問題を発見する、という地獄が毎回発生していた。Web の世界で言えば、マイクロサービスが 100 個あるのに CI/CD もコントラクトテストもなく、全部 stg に繋いでから初めて動作確認するようなものだ。

さらに根本的な問題がある。「車を売ったら終わり」のビジネスモデルでは、ソフトウェアを直す仕組みが存在しない。不具合があれば工場に呼び戻してリコール（物理で対応）、新機能を追加したければ新型車を売る——これが自動車業界の標準だった。

これを根本から覆すのが **SDV（Software Defined Vehicle）** だ。

---

## SDV とは何か

「ソフトウェアが車を定義する」という意味で、Tesla が 2010 年代に証明したモデルを指す。

具体的には次の変化が起きる。

| 従来の車 | SDV |
|---|---|
| 機能はハードウェアで決まる | 機能はソフトウェアで追加・変更できる |
| 80〜150 個の独立した ECU | 5〜20 個のゾーンコントローラー + 中央 HPC |
| 工場に来ないと直せない | OTA アップデートで空中から更新 |
| 売ったら終わり | SaaS 的に継続収益が生まれる |

「機能を後から課金する」「サブスクリプションで月額収益を得る」——車がプラットフォームになる。GM は 2025 年時点で Ultifi（SDV プラットフォーム）から年間 **約 20 億ドルの経常収益**を得ている。これが OEM 各社が本気になっている理由だ。

ある調査では、OEM の 45% が「SDV 移行を最優先戦略事項の第 1 位」と回答した。自動運転（25%）や EV 化（14%）より上だ。

---

## アーキテクチャの話：「ゾーン型 + 中央 HPC」への収束

2026 年時点で、業界の答えは概ね「ゾーン型アーキテクチャ + 中央高性能コンピュータ（HPC）」に収束してきた。

```
[Central HPC]（高性能演算・AI 処理）
├── Hypervisor
│   ├── Safety Partition     ← Classic AUTOSAR + RTOS（タイヤ・ブレーキ等）
│   ├── ADAS Partition       ← Adaptive AUTOSAR on QNX or Linux（自動運転）
│   └── Infotainment Partition ← Android Automotive OS / AGL
│
[Zone Controllers]（車の前後左右に分散）← ECU を地理的に統合
```

重要なのは「全部 Linux にすれば解決」ではない点だ。ブレーキや ABS は「処理が X ミリ秒以内に完了する保証」がなければ人が死ぬ。これをハードリアルタイム保証と呼び、Linux や Android では原則として保証できない。だから安全クリティカルな領域には Classic AUTOSAR（RTOS ベース）が残り、その上に POSIX 準拠の世界が乗る、という積層構造になる。

VW の SSP プラットフォームは ECU を 50% 以上削減・配線 40% 削減を目指している。BMW の Neue Klasse（2026 年の iX3 が第 1 弾）は、SuperBrain と呼ぶ 4 つの HPC を搭載し、配線 600m 削減・車体重量 30% 軽量化を実現した。

---

## クラウドが自動車に入ってきた場面

クラウドベンダーが「自動車専用のサービス」を本格的に打ち出し始めたのが 2024〜2026 年だ。

### AWS

AWS が最も深く食い込んでいる。

**Nissan × AWS（2025 年 12 月）**

「Nissan Scalable Open Software Platform」として、世界 5,000 人以上の開発者が使う統合クラウド開発環境を構築した。テスト実行時間を **75% 削減** したという数字が出ている。

背景にあるのは「クラウド HIL（Hardware-in-the-Loop）」という概念だ。従来は物理的なハードウェアボードを使ってテストしていたが、AWS 上で Virtual ECU を動かし、Software-in-the-Loop（SIL）テストをクラウドで完結させることで、物理試作車がなくてもテストが回せる。Shift-Left そのものだ。

**HERE + AWS「SDV Accelerator」（2025 年 9 月）**

地図情報の HERE が Arm・Elektrobit などと組んで、AWS 上でマッピング技術と AI をワンパッケージで提供する SDV 開発環境。

### Microsoft Azure

CES 2026 で複数のパートナーシップを発表。AMD の車載スタックを Azure で動かし、仮想開発環境とシステムレベルシミュレーションを実現した。Microsoft は SDV 向けの DevOps 参照アーキテクチャも公開しており、Kubernetes ベースで ARM64 + GPU + FPGA の異種アーキテクチャを Azure 上でサポートする設計になっている。

### Google Cloud

Google Cloud の動きは「OS とクラウドをセットで囲い込む」という戦略が軸になっている。

#### AAOS SDV（2026 年 3 月発表）

Google が「Android Automotive OS for SDV（AAOS SDV）」を発表した。これまでの Android Automotive はインフォテインメント（カーナビ・音楽）に限定されていたが、AAOS SDV ではシート制御・計器クラスタ・空調・照明・カメラ・テレメトリまで車全体に拡張した。AOSP でオープンソース化済み。

Renault が採用を発表（2026 年末の Trafic e-Tech で生産開始）。Qualcomm は CES 2026 で「Snapdragon vSoC on Google Cloud」を発表し、物理ハードウェアなしで AAOS SDV を Google Cloud 上で開発・検証できる環境を提供した。

#### Google Cloud Horizon

AAOS 開発者向けの CI/CD・ビルド・テスト環境。Accenture との共同イニシアティブで、**AAOS のビルド時間を最大 95% 削減**する。OSS として GitHub に公開済み（[GoogleCloudPlatform/horizon-sdv](https://github.com/GoogleCloudPlatform/horizon-sdv)）。

AWS でいう「SDV Accelerator」に相当するが、AAOS に特化している分、OS を採用した OEM には強い引力がある。

#### Automotive AI Agent（Gemini on Vertex AI ベース）

車載 AI アシスタント構築基盤。Google Maps Platform（2.5 億件 POI）との統合が標準で入っており、Mercedes-Benz が 2025 年 1 月に MBUX Virtual Assistant への統合を発表した。AWS には同等の地図サービスがないため、ここは Google の独自優位点だ。

#### OEM との契約状況

| OEM | 内容 |
|---|---|
| Renault | Google を「Preferred Cloud Supplier（優先クラウドサプライヤー）」に指定。SDV 設計・デジタルツイン・開発環境を Google Cloud に統合 |
| Toyota / Woven by Toyota | 自動運転 ML ワークロードを Google Cloud AI Hypercomputer で実行。TCO **50% 削減**を達成 |
| Subaru | EyeSight（ADAS）の AI 開発に Vertex AI・Dataflow を採用。前処理時間を「数日 → 30 分」に短縮 |
| Mercedes-Benz | Automotive AI Agent を MBUX に統合（2025 年 1 月発表） |

日本メーカーでは Toyota と Subaru が AI 開発基盤として Google Cloud を選んでいる。

---

### AWS vs Google Cloud：何が違うのか

**AWS の強み（Google Cloud に対して）：**

- **AWS IoT FleetWise**：車両テレメトリ収集専用サービス。カメラ・LiDAR・レーダーデータの条件付きフィルタリングに対応しており、Google Cloud に直接対応するサービスがない
- **Connected Mobility Solution（CMS）on AWS**：OTA・フリート管理・認証をバンドルしたリファレンスアーキテクチャ
- **SDV 開発ツールのエコシステム**：dSPACE・Luxoft・HERE Technologies 等の自動車 SI パートナー網が厚い
- **HERE + AWS SDV Accelerator**（2025 年 9 月）：地図・位置情報 + クラウド SDV 開発環境をワンパッケージで提供

**Google Cloud の強み（AWS に対して）：**

- **OS との垂直統合**：AAOS SDV を採用した OEM は、Horizon（ビルド）・Vertex AI・Maps Platform・GCP を一気に使うインセンティブが生まれる。AWS にはこのレイヤーがない
- **Gemini + Google Maps の組み合わせ**：AI アシスタント × 地図の統合は Google 固有の優位性
- **TPU アクセス（AI Hypercomputer）**：大規模 ML 訓練のコスト効率で Woven by Toyota が TCO 50% 削減を達成している

---

### AWS から Google Cloud への切り替えは起きるか

結論から言うと、**全面切り替えより「使い分け」が業界標準になりつつある**。

典型例が VW だ。製造・SDV 開発は AWS、コネクティビティは Azure、AI アシスタントは Google Cloud という分業構成を取っている。2025 年 11 月には AWS と Google Cloud が「AWS Interconnect」（マルチクラウド接続）をプレビュー公開した——両社が競合しながら共存を認めた格好だ。

唯一「スイッチ」に近いのが Renault のケースで、SDV 戦略全体を Google Cloud に賭けた形だが、これは「AWS から乗り換えた」というより「新しいアーキテクチャを Google で設計した」という経緯に近い。

**現場で乗り換え話が出やすいパターンは一つある：車両 OS として AAOS SDV を採用する判断が社内で決まったとき。** Horizon（ビルド・CI/CD）・Vertex AI（モデル開発）・Maps Platform がセットでついてくるため、「じゃあ開発環境も Google Cloud で」という流れが自然発生しやすい。逆に言えば、AAOS SDV を採用しない限りは、SDV 開発ワークロードで AWS から Google Cloud に積極的に乗り換える理由は現時点では薄い。

---

## グローバルの競争マップ：誰がリードしているか

| プレイヤー | 強み | 現状 |
|---|---|---|
| Tesla | OTA の成熟度、集中アーキテクチャの実績 | 依然リード、AI 更新が他社と段違い |
| BMW | Neue Klasse アーキテクチャ、プレミアム市場 | 欧州勢で最も具体的な実装が進んでいる |
| VW | 規模、マス市場 | CARIAD 失敗 → Rivian JV で再起動中（2027 年量産予定） |
| GM | Ultifi プラットフォーム、経常収益化 | 既に SDV で稼いでいる |
| Huawei / 中国勢 | 速度、エコシステム、価格 | 圧倒的に速い |

**Huawei の戦略が面白い。**

Huawei は「Auto Wintel」を目指している。Intel（チップ）と Windows（OS）が PC 業界を支配したように、車業界の「チップ + OS」を Huawei が握るという戦略だ。Qiankun ADS（自動運転）+ HarmonyOS Cockpit（車内体験）+ 自社チップをフルスタックで提供し、Seres・BAIC・奇瑞などの OEM に展開する。AITO M9 は発売 27 日で 4 万台確約注文を受けた。

一般的に「中国の開発速度は欧米の 3〜4 年分を圧縮している」と評価されている。Ford の CEO が 2025 年に中国を訪問した後「コストと品質が西側を凌駕している」と発言したのが象徴的だ。

---

## 日本の現状

日本政府は 2024 年に「2030 年までに SDV グローバルシェア 30%（1,200 万台）」という目標を掲げた。Toyota・Nissan・Honda が半導体・生成 AI の共同開発で連携する方針も示されている。

**Toyota（Woven by Toyota が開発した Arene OS）**

2025 年 5 月、RAV4 に Arene OS が量産搭載されて初めて世界デビューした。2025 年 9 月には Woven City（静岡県裾野市の実験都市）が正式オープンし、SDV のリアルワールドテスト環境として機能し始めている。

**Honda（ASIMO OS）**

Honda 独自の車両 OS を「ASIMO OS」と命名。2026 年型 Honda 0 Series に Domain Centralized E/E Architecture を初採用し、2026 年前半に北米発売開始。スマートフォン OS のように OTA で新機能を追加できる設計。Renesas と将来の Honda 0 用 SoC を共同開発する協定も 2025 年 1 月に結んだ。

日本が抱える本質的な課題は速度だ。中国 EV メーカーは「発表から量産まで 18 カ月以内」が普通だが、日本の開発サイクルは 4〜5 年。製造品質の強みを持ちながら、ソフトウェアの価値へのシフトで後手に回るリスクがある。

---

## クラウドエンジニア視点でのまとめ

自動車業界がやろうとしていることを、クラウドの概念で言い換えると：

- **ECU 統合** = マイクロサービスをモノリスに整理して依存関係を減らす話
- **OTA アップデート** = SaaS のデプロイパイプライン（ただし安全制約あり）
- **Virtual ECU / クラウド HIL** = テスト環境のコンテナ化 + CI/CD の Shift-Left
- **デジタルツイン** = ステージング環境を本番と完全に同期させる話
- **Huawei の Auto Wintel 戦略** = AWS が IaaS + PaaS + エコシステムで囲い込む話の車版

違いは「ソフトのバグで人が死ぬ可能性がある」という一点だ。それがハードリアルタイム制約・AUTOSAR・ISO 26262（機能安全規格）という形で技術に現れている。

---

## 参考

- [IoT Analytics: Software-defined Vehicles Adoption - 4 Dimensions & Leading OEMs](https://iot-analytics.com/software-defined-vehicles-adoption-4-dimensions-leading-oems/)
- [BMW Group: Four Superbrains for the Neue Klasse](https://www.bmwgroup.com/en/news/general/2025/superbrains.html)
- [Woven by Toyota: Arene Debuts in Toyota's All-New RAV4](https://woven.toyota/en/our-latest/20250521/)
- [Honda: ASIMO OS for Software Defined Vehicles](https://global.honda/en/tech/Honda_SDV_ASIMO_OS/)
- [Amazon Press: Nissan Accelerates SDV Development with AWS](https://press.aboutamazon.com/aws/2025/12/nissan-accelerates-software-defined-vehicle-development-and-strengthens-ai-development-environment-with-new-aws-powered-platform)
- [AWS: Software-Defined Vehicle](https://aws.amazon.com/automotive/software-defined-vehicle/)
- [Google Android Developers Blog: Beyond Infotainment - AAOS SDV（2026年3月）](https://android-developers.googleblog.com/2026/03/Beyond-Infotainment-Extending-Android-Automotive-OS-for-Software-defined-Vehicles.html)
- [Google Cloud: Automotive Solutions](https://cloud.google.com/solutions/automotive)
- [Google Cloud Blog: Google Cloud Horizon - AAOS ビルド時間 95% 削減](https://cloud.google.com/blog/topics/manufacturing/slash-android-automotive-os-build-times-and-get-to-market-faster-with-horizon-on-google-cloud)
- [GitHub: GoogleCloudPlatform/horizon-sdv](https://github.com/GoogleCloudPlatform/horizon-sdv)
- [Google Cloud Blog: Renault の SDV を Google Cloud で構築](https://cloud.google.com/blog/products/application-development/renault-groups-software-defined-vehicles-built-on-google-cloud/)
- [Google Cloud Blog: Toyota が Cloud Storage FUSE で AI トレーニングを高速化](https://cloud.google.com/blog/products/storage-data-transfer/toyota-cuts-ai-training-time-with-cloud-storage-fuse-file-cache/)
- [Google Cloud: Subaru の ADAS AI 開発事例](https://cloud.google.com/customers/subaru)
- [Google Cloud Press: Mercedes-Benz × Google Cloud Automotive AI Agent（2025年1月）](https://www.googlecloudpresscorner.com/2025-01-13-Mercedes-Benz-and-Google-Partner-on-AI-powered-Conversational-Search-within-Navigation-Systems)
- [Qualcomm: CES 2026 - Snapdragon vSoC on Google Cloud](https://www.qualcomm.com/news/releases/2026/01/qualcomm-expands-decade-long-collaboration-with-google-for-autom)
- [The New Stack: AWS と Google Cloud がマルチクラウド接続を構築（2025年11月）](https://thenewstack.io/aws-google-build-a-multicloud-bridge/)
- [AWS: IoT FleetWise](https://aws.amazon.com/iot-fleetwise/)
- [AWS Blog: Stellantis の Virtual Engineering Workbench](https://aws.amazon.com/blogs/industries/stellantis-sdv-transformation-with-the-virtual-engineering-workbench-on-aws/)
- [Microsoft: CES 2026 - Powering the Next Frontier in Automotive](https://www.microsoft.com/en-us/industry/blog/manufacturing-and-mobility/2026/01/07/ces-2026-powering-the-next-frontier-in-automotive/)
- [Microsoft Learn: SDV DevOps Reference Architecture](https://learn.microsoft.com/en-us/industry/mobility/architecture/software-defined-vehicle-reference-architecture-content)
- [S&P Global: Huawei Powers Chinese Automakers' Smart EV Ambitions](https://www.spglobal.com/automotive-insights/en/blogs/2025/10/huawei-powers-chinese-automakers-smart-ev-ambitions)
- [GM: Centralized Vehicle Computing Platform（2025年10月）](https://news.gm.com/home.detail.html/Pages/news/us/en/2025/oct/1022-SDV-GM-centralized-vehicle-computer-platform-electric-gas-vehicles.html)
- [HERE + AWS SDV Accelerator（2025年9月）](https://www.globenewswire.com/news-release/2025/09/09/3146727/0/en/HERE-and-AWS-Reimagine-the-Future-of-Automotive-Software-Development-with-SDV-Accelerator.html)
- [ADT Media: Why 2026 Could Mark a Turning Point for SDVs](https://www.adt.media/software-defined-vehicles/why-2026-could-mark-a-turning-point-for-softwaredefined-vehicles/2603804)
- [Promwad: Zonal Architecture in Automotive 2026](https://promwad.com/news/zonal-architecture-automotive-2026-practical-implementation)
- [S&P Global: Scaling SDVs - From Build to Organizational Readiness（2026年1月）](https://www.spglobal.com/automotive-insights/en/blogs/2026/01/scaling-software-defined-vehicles)
