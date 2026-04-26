<!-- Space: harukaaibarapublic -->
<!-- Parent: Summaries -->
<!-- Title: SD-WAN と AWS 接続の考え方 -->

# SD-WAN と AWS 接続の考え方

拠点が増えてくると「本社・各拠点・AWS を全部つなぎたい」という要件が出てくる。MPLS 専用線で全拠点をハブスポーク接続するのが従来の答えだったが、コストが高く、クラウドへの通信をわざわざ本社経由でバックホールする非効率も生まれる。SD-WAN はこの問題を解くために出てきた。

## 従来の WAN で何が辛いか

MPLS 専用線の構成では：

- **回線コストが高い**：拠点数が増えるほど線形にコストが上がる
- **クラウドへの通信が非効率**：各拠点 → 本社 → インターネット → AWS というパスになり、本社がボトルネック
- **設定変更が遅い**：ルーター設定は手動。新拠点の開通に数週間かかる
- **回線種別が固定**：MPLS がダウンしたときの冗長をインターネット VPN で組もうとすると管理が複雑になる

## SD-WAN が解決すること

SD-WAN（Software-Defined WAN）はコントロールプレーン（経路制御）とデータプレーン（実際のパケット転送）を分離し、複数回線（MPLS・インターネット・LTE 等）を束ねてソフトウェアで制御する。

| 課題 | SD-WAN での解決策 |
|---|---|
| 回線コストが高い | 安価なインターネット回線を MPLS と組み合わせるか置き換える |
| クラウドへの通信が非効率 | 各拠点から直接クラウドに抜けるローカルブレイクアウト |
| 設定変更が遅い | コントローラーから全拠点に一括展開 |
| 回線冗長が複雑 | 複数回線をアクティブ-アクティブで使い、品質に応じて自動切り替え |

### ローカルブレイクアウト

SD-WAN の要の機能。アプリケーション（SaaS・クラウド等）を識別し、クラウド向けトラフィックは拠点から直接インターネットに出す。本社経由のバックホールを不要にする。

```
【従来】
拠点 → MPLS → 本社 → インターネット → AWS

【SD-WAN ローカルブレイクアウト】
拠点 → インターネット → AWS
拠点 → MPLS          → 社内システム（本社・DC）
```

## AWS との接続パターン

### パターン 1：SD-WAN エッジ → Site-to-Site VPN → Transit Gateway

最もシンプルな構成。SD-WAN のエッジルーター（拠点側）と AWS Transit Gateway の間で IPsec VPN トンネルを張る。

```
拠点 SD-WAN エッジ
    └─ IPsec VPN ─→ AWS Transit Gateway
                         ├─ VPC A
                         ├─ VPC B
                         └─ VPC C
```

- Transit Gateway は BGP（動的ルーティング）に対応しているため、SD-WAN 側のルート情報を自動交換できる
- ECMP（Equal Cost Multi-Path）を有効にすると複数トンネルで帯域を束ねられる（トンネルあたり最大 1.25 Gbps）

```bash
# Transit Gateway で ECMP を有効化
aws ec2 create-transit-gateway \
  --options VpnEcmpSupport=enable
```

### パターン 2：SD-WAN クラウドゲートウェイ（PoP 接続）

主要 SD-WAN ベンダー（Cisco Viptela、VMware SD-WAN、Palo Alto Prisma SD-WAN 等）は AWS 上にクラウドゲートウェイ（PoP）を持っている。拠点は最寄りの PoP に接続し、PoP から AWS VPC へはバックボーンで転送される。

```
拠点 → SD-WAN PoP（AWS 上の EC2）→ VPC
```

AWS Marketplace でベンダーの仮想アプライアンスをデプロイし、Transit Gateway に接続する形が多い。

### パターン 3：AWS Cloud WAN

AWS のマネージド SD-WAN 的サービス。拠点・VPC・Direct Connect・VPN を単一のグローバルネットワークとして管理できる。

- **コアネットワーク**：AWS のグローバルバックボーンを使ったプライベートネットワーク
- **セグメント**：トラフィックを論理的に分離（本番/開発/管理など）
- コンソールとポリシーで全拠点の接続を管理

ベンダー製 SD-WAN と Cloud WAN は競合するのではなく、既存 SD-WAN 環境に Cloud WAN を組み合わせる構成も公式にサポートされている。

## SD-WAN 導入時に AWS 側で考えること

### BGP コミュニティによるルート制御

Transit Gateway は BGP コミュニティをサポートしている。SD-WAN 側から特定のルートに優先度を付けて広告し、TGW 側で受け取ることで経路を細かく制御できる。

### アプライアンスモード

SD-WAN のファイアウォール機能（ステートフル検査）を VPC 内のアプライアンスで実装する場合、Transit Gateway のアタッチメントに **アプライアンスモードを有効化**する必要がある。有効にしないと AZ をまたいでパケットが転送されセッションが壊れる。

### ECMP と帯域

IPsec トンネルは 1 本あたり上限 1.25 Gbps。より大きな帯域が必要なら：
- ECMP で複数トンネルを束ねる（TGW 側で `VpnEcmpSupport=enable`）
- Direct Connect と VPN を併用する（DX をメイン、VPN をバックアップ）

## SD-WAN を選ぶ判断軸

| 構成 | 向いている場面 |
|---|---|
| Site-to-Site VPN のみ | 拠点数が少ない・シンプルさ優先 |
| SD-WAN + VPN/DX | 拠点数が多い・回線種別が混在・ポリシー一元管理が必要 |
| AWS Cloud WAN | AWS ネイティブで完結させたい・マルチリージョン VPC 間接続も含めて統合管理したい |

## 参考

- [AWS Transit Gateway - VPN ECMP support](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-transit-gateways.html#tgw-ecmp)
- [AWS Cloud WAN - What is AWS Cloud WAN?](https://docs.aws.amazon.com/network-manager/latest/cloudwan/what-is-cloudwan.html)
- [SD-WAN integration with AWS Transit Gateway](https://aws.amazon.com/blogs/networking-and-content-delivery/integrating-sd-wan-devices-with-aws-transit-gateway-and-aws-direct-connect/)
- [Transit Gateway アプライアンスモードとは](Transit%20Gateway%20アプライアンスモードとは.md)
