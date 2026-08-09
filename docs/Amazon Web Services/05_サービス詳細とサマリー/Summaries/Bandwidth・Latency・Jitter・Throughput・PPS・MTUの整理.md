# Bandwidth・Latency・Jitter・Throughput・PPS・MTU の整理

## なぜこれを整理するのか

AWS でネットワーク性能に関する問題が起きたとき、「遅い」という事実しかわからない状態では手が打てない。「遅い」にも種類があり、**何が遅いのか**によって原因も対策も変わる。

- ファイル転送が遅い → 帯域幅（Bandwidth）またはスループット（Throughput）の問題
- レスポンスが遅い → レイテンシ（Latency）の問題
- 音声・映像が途切れる → ジッター（Jitter）の問題
- 小さいパケットを大量に送ると詰まる → PPS の上限問題
- フラグメンテーションが起きている → MTU の問題

これらは別の指標で、別の方法で測定し、別のアプローチで改善する。

---

## 各指標の意味と AWS での具体的な場面

### Bandwidth（帯域幅）

**「パイプの太さ」**。単位は bps（bits per second）。1 Gbps のポートなら、理論上 1 秒間に 1 Gbit 分のデータを流せる。

帯域幅はあくまで **上限値**。実際に流れる量（スループット）とは別物。

#### AWS での場面

**EC2 インスタンスのネットワーク帯域幅はインスタンスタイプで決まる。**

| インスタンスタイプ | ネットワーク帯域幅 |
|---|---|
| t3.micro | 最大 5 Gbps |
| m5.xlarge | 最大 10 Gbps |
| c5n.18xlarge | 最大 100 Gbps |

注意点：

- 「最大 N Gbps」はバースト性能であり、持続的に出るとは限らない（特に小インスタンス）
- 同一 AZ 内の通信は全帯域を使えるが、**インターネットへの送信は半分の帯域に制限される**場合がある
- **Enhanced Networking（ENA）** を有効にすることで低レイテンシ・高帯域を実現できる
- Direct Connect のポート速度（1 Gbps / 10 Gbps / 100 Gbps）が物理的な上限になる

---

### Latency（レイテンシ）

**「往復にかかる時間」**。RTT（Round Trip Time）とも呼ぶ。単位はミリ秒（ms）。

パケットが送信元から宛先へ届き、応答が戻ってくるまでの時間。帯域幅がどれだけ広くても、距離・ホップ数・処理時間によってレイテンシは決まる。

#### AWS での場面

**同一 AZ 内 < 同一リージョン異なる AZ < 異なるリージョン**の順にレイテンシが大きくなる。

レイテンシを下げたい場面での選択肢：

| 手段 | 効果 |
|---|---|
| **Cluster Placement Group** | 同一ラックに近い EC2 を配置。インスタンス間の RTT を数十 µs に抑えられる |
| **Enhanced Networking（ENA）** | ハードウェアオフロードにより CPU を介さずパケット処理。レイテンシ削減 |
| **Direct Connect** | インターネット経由の VPN より安定した低レイテンシ。ISP のルーティングに左右されない |
| **Global Accelerator** | AWS のバックボーンネットワークを経由させ、インターネット経由より低レイテンシで転送 |

HPC（高性能計算）や金融トレーディングシステムでは、Cluster Placement Group と Enhanced Networking の組み合わせが基本構成になる。

---

### Jitter（ジッター）

**「レイテンシのばらつき」**。単位はミリ秒（ms）。

レイテンシが常に 10 ms なら安定しているが、10 ms → 30 ms → 5 ms → 50 ms と変動する場合、ジッターが大きいという。

平均レイテンシが低くてもジッターが大きいと、**リアルタイム通信（VoIP、ビデオ会議、オンラインゲーム）**では通話が途切れたり映像がカクついたりする。

#### AWS での場面

インターネット VPN はジッターが出やすい。ISP の混雑状況・ルーティング変更でレイテンシが変動するため。

**Direct Connect はジッターが小さい**。専用線でパスが固定されているため、レイテンシの変動が抑えられる。

VoIP や映像配信のような品質要件が厳しいワークロードをオンプレミスから AWS へ移行する場合、インターネット VPN では要件を満たせないことがある。この場合は Direct Connect を検討する根拠になる。

---

### Throughput（スループット）

**「実際に転送できているデータ量」**。単位は bps または Bps（バイト/秒）。

帯域幅（Bandwidth）が「パイプの太さ」なら、スループットは「実際に流れている水の量」。帯域幅が上限で、スループットはそれを下回る実測値。

#### スループットが帯域幅より低くなる原因

- **パケットロス**：TCP は再送するためスループットが落ちる
- **TCP ウィンドウサイズ**：送受信双方のバッファ設定が小さいと帯域を使い切れない
- **RTT（レイテンシ）**：RTT が長いほど TCP の性能が出にくい（BDP の問題）
- **ネットワーク機器のボトルネック**：NAT ゲートウェイ・セキュリティグループ処理

#### AWS での場面

S3 への大量アップロードでスループットが出ない場合、よくある原因は：

1. シングルスレッドで転送している → **マルチパートアップロード**を使う
2. 接続数が少ない → **並列転送**（aws s3 cp --jobs や aws s3 sync）
3. Transfer Acceleration を使っていない → **S3 Transfer Acceleration** で AWS のエッジ経由に変える

帯域幅に余裕があってもスループットが出ない場合は、TCP の設定やアプリケーション層の並列度を疑う。

---

### PPS（Packets Per Second）

**「1 秒間に処理できるパケット数」**。帯域幅と独立した別の制限。

帯域幅が余っていても PPS の上限に達するとパケットがドロップする。特に**パケットサイズが小さい**ワークロードで問題になりやすい。

#### なぜ PPS が問題になるか

1 Gbps の帯域幅があるとき：

- 1 パケットが 1500 byte（標準 MTU）なら → 約 83,000 PPS で 1 Gbps を使い切る
- 1 パケットが 64 byte（最小フレーム）なら → **約 1,953,000 PPS** 処理しないと 1 Gbps を使い切れない

つまり、小さいパケットを大量に送る場合は、帯域幅ではなく **PPS が先に上限に達する**。

#### AWS での場面

EC2 インスタンスには **PPS の上限**がある。

| インスタンスタイプ | 最大 PPS（目安） |
|---|---|
| t3.medium | 約 150,000 PPS |
| c5.xlarge | 約 250,000 PPS |
| c5n.18xlarge | 約 3,700,000 PPS |

ゲームサーバー・DNS サーバー・DDoS 防御システムなど、小さいパケットを大量に処理するワークロードでは PPS が重要な指標になる。インスタンスタイプを選ぶ際に帯域幅だけ見て PPS を見落とすと、実際のワークロードで性能が出ないことがある。

NAT Gateway も PPS 制限があり（デフォルトで 4,000,000 PPS まで）、大量の小パケットを処理する場合はここがボトルネックになることがある。

---

### MTU（Maximum Transmission Unit）

**「1 パケットで送れる最大サイズ（バイト）」**。

MTU を超えるデータを送ろうとすると、**フラグメンテーション（分割）**が発生する。フラグメンテーションはオーバーヘッドになり性能が落ちる。

| 設定 | MTU |
|---|---|
| イーサネット標準 | 1500 bytes |
| VPC 内（ジャンボフレーム） | 9001 bytes |
| VPN（IPsec） | 通常 1400〜1460 bytes 程度（暗号化ヘッダー分小さくなる） |

#### AWS での場面

**VPC 内はジャンボフレーム（9001 MTU）に対応している**。大量データを転送する場合、MTU を 9001 に設定することでフラグメンテーションを減らし、スループットを改善できる。

ただし、すべてのパスでジャンボフレームが使えるわけではない：

| 接続種別 | ジャンボフレーム対応 |
|---|---|
| 同一 VPC 内（EC2 間） | 対応（9001 MTU） |
| VPC Peering（同一リージョン） | 対応（9001 MTU） |
| VPC Peering（異なるリージョン） | **非対応（1500 MTU）** |
| インターネットゲートウェイ経由 | **非対応（1500 MTU）** |
| Direct Connect | 対応（最大 9001 MTU）|
| VPN（Site-to-Site） | **非対応（1500 MTU 以下）** |

**MTU 不一致によるトラブル**：

送信側が 9001 MTU でパケットを送り、途中の機器が 1500 MTU しか扱えない場合、ICMP タイプ 3（Fragmentation Needed）で通知されるはずが、セキュリティグループや NACL で ICMP をブロックしていると通知されず、パケットがブラックホールになる（接続が中断・タイムアウトする）。

**対策：PMTUD（Path MTU Discovery）が機能するよう ICMP タイプ 3 を許可しておく。**

---

## まとめ：指標と問題の対応表

| 症状 | 疑うべき指標 | AWS での確認・対策 |
|---|---|---|
| 大量データの転送が遅い | Bandwidth / Throughput | インスタンスタイプの帯域幅確認、マルチパート/並列転送 |
| レスポンスが遅い（RTT が高い） | Latency | Placement Group、リージョン選択、Direct Connect |
| 音声・映像が途切れる | Jitter | Direct Connect、Global Accelerator |
| 小パケットを大量に処理すると詰まる | PPS | インスタンスタイプの PPS 上限確認、Enhanced Networking |
| 接続が突然切れる / タイムアウトする | MTU | PMTUD の確認、ICMP 許可設定 |

「遅い」「つながらない」という現象から、どの指標を調べるかを絞り込むことが、AWS ネットワーク問題の最初のステップになる。

---

## 参考

- [Amazon EC2 インスタンスのネットワーク帯域幅](https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/ec2-instance-network-bandwidth.html)
- [AWS でのネットワーク最大伝送単位（MTU）](https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/network_mtu.html)
- [Placement Group](https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/placement-groups.html)
- [Enhanced Networking on Linux](https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/enhanced-networking.html)
- [AWS Direct Connect のネットワーク要件](https://docs.aws.amazon.com/ja_jp/directconnect/latest/UserGuide/network-requirements.html)
- [NAT ゲートウェイのクォータ](https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/vpc-nat-gateway.html#nat-gateway-limits)
