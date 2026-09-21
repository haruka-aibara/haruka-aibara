# Direct Connect VIF（仮想インターフェース）の種類と使い分け

## 「Direct Connect を引いたのに、VPC につながらない」が起きる理由

AWS Direct Connect を契約して物理回線を引いた後、すぐに VPC と通信できるわけではない。Direct Connect の接続（Connection）はあくまで「物理的なパイプ」でしかなく、その上に **Virtual Interface（VIF）** を作って初めてトラフィックが流れる。

VIF には種類があり、何をしたいかによって使うものが変わる。ここを間違えると「回線はあるのに通信できない」という状態になる。

---

## VIF とは何か

VIF（仮想インターフェース）は、Direct Connect 接続の上に張る論理的なレイヤー3接続。BGP セッションを使って、オンプレミスと AWS の間でルート情報を交換する。

1本の Direct Connect 接続に対して、複数の VIF を作れる（ホスト型接続は1本のみ）。

---

## 3種類の VIF と使い分け

| VIF の種類 | 接続先 | 主なユースケース |
|---|---|---|
| **Private VIF** | VPC（Virtual Private Gateway または Direct Connect Gateway 経由） | オンプレミス → VPC 内のリソースへの接続 |
| **Public VIF** | AWS のパブリックエンドポイント | S3・DynamoDB などを Direct Connect 経由でアクセス |
| **Transit VIF** | Transit Gateway（Direct Connect Gateway 経由） | 複数 VPC やマルチアカウントを Transit Gateway で束ねて接続 |

---

## Private VIF：VPC に直接つなぐ

### どんな場面で使うか

オンプレミスから EC2 や RDS など **VPC 内のリソースにアクセスしたい**場面で使う。プライベート IP アドレス（10.x.x.x や 172.x.x.x）を使った通信が前提。

### 接続の仕組み

```
オンプレミス
    ↓ BGP
Direct Connect 接続
    ↓ Private VIF
Virtual Private Gateway（VGW）
    ↓
VPC
```

VGW は VPC にアタッチされる AWS 側のゲートウェイ。Private VIF は VGW に関連付ける。

### 重要な制約

**1 つの Private VIF は 1 つの VGW にしか関連付けられない。**

つまり、VPC が複数ある場合、VPC の数だけ Private VIF を作ることになる。これが大規模構成で問題になる。

```
Private VIF (VPC-A 用)  →  VGW-A  →  VPC-A
Private VIF (VPC-B 用)  →  VGW-B  →  VPC-B
Private VIF (VPC-C 用)  →  VGW-C  →  VPC-C
```

このスケールの問題を解消するのが **Direct Connect Gateway**。

---

## Direct Connect Gateway との組み合わせ（推奨構成）

複数 VPC や複数リージョンに接続したい場合は、Private VIF を Direct Connect Gateway（DGW）に向ける。

```
オンプレミス
    ↓ BGP
Direct Connect 接続
    ↓ Private VIF（1本）
Direct Connect Gateway
    ↓（Association）
VGW-A → VPC-A（東京リージョン）
VGW-B → VPC-B（大阪リージョン）
VGW-C → VPC-C（バージニアリージョン）
```

**Private VIF 1本で、複数リージョンの複数 VPC に接続できる**のが最大のメリット。

### DGW を使う場合の制約

- 1つの DGW に関連付けられる VGW は最大 **10個**
- VPC 間（VPC-A ↔ VPC-B）の通信はできない（あくまでオンプレミス ↔ VPC の通信のみ）
- 関連付ける VGW が持つ VPC の CIDR はそれぞれ重複できない

---

## Public VIF：AWS のパブリックサービスに接続する

### どんな場面で使うか

S3 や DynamoDB、SES などの **AWS パブリックエンドポイント**へのアクセスを、インターネットを経由せずに Direct Connect 経由で行いたい場面。

データの機密性が高く、インターネットを通したくない場合や、帯域を安定させたい場合に使う。

### 仕組みの注意点

Public VIF は AWS のパブリック IP アドレス空間（AWS が BGP でアドバタイズするプレフィックス）に到達する。

**VPC の中には入れない**。VPC のプライベートリソースへのアクセスは Private VIF（または Transit VIF）を使う。

---

## Transit VIF：Transit Gateway と組み合わせる

### どんな場面で使うか

多数の VPC（10個を超えるような大規模構成）や、複数 AWS アカウントをまたいだ接続が必要な場面。Transit Gateway（TGW）をハブにしてオンプレミスとつなぐ。

```
オンプレミス
    ↓ BGP
Direct Connect 接続
    ↓ Transit VIF
Direct Connect Gateway
    ↓（Association）
Transit Gateway
    ↓（Attachment）
VPC-A、VPC-B、VPC-C...（制限なし）
```

### Private VIF + DGW との使い分け

| | Private VIF + DGW | Transit VIF + DGW + TGW |
|---|---|---|
| VPC 間通信 | 不可 | TGW のルーティングで可能 |
| 接続できる VPC 数 | 最大 10（VGW 数の上限） | TGW に接続できる数まで |
| コスト | 低め | TGW のアタッチメント料金が追加 |
| 複雑さ | シンプル | 複雑 |

VPC 間通信が不要で VPC 数が少なければ、Private VIF + DGW で十分。VPC 数が多い・VPC 間通信も必要なら Transit VIF + TGW を選ぶ。

---

## アーキテクチャ選択のフローチャート

```
Direct Connect で何に接続したい？
│
├── AWS のパブリックサービス（S3 など）
│       └── Public VIF
│
└── VPC 内のリソース
        │
        ├── VPC が少ない（1〜2個）かつ同一アカウント同一リージョン
        │       └── Private VIF → VGW（シンプル構成）
        │
        ├── VPC が複数 / 複数リージョン / 複数アカウント（VPC間通信不要）
        │       └── Private VIF → Direct Connect Gateway → VGW
        │
        └── VPC 数が多い / VPC間通信も必要
                └── Transit VIF → Direct Connect Gateway → Transit Gateway
```

---

## BGP の設定（Private VIF 作成時に必要なもの）

Private VIF を作成する際に入力が必要な項目：

| 項目 | 内容 |
|---|---|
| VLAN ID | 物理回線上で論理分割するための ID（APN との調整が必要） |
| BGP ASN | オンプレミス側の AS 番号（プライベート ASN: 64512〜65534 も使用可） |
| BGP Auth Key | BGP セッションの認証キー（省略可だが推奨） |
| Amazon side address | AWS 側の /30 アドレス |
| Customer address | オンプレミス側の /30 アドレス |

---

## まとめ

- Direct Connect の「接続（Connection）」だけでは通信できない。その上に VIF を張る必要がある
- **Private VIF**：VPC 内リソースへのアクセス。VGW に関連付ける
- **Public VIF**：S3 などパブリックエンドポイントへのアクセス
- **Transit VIF**：Transit Gateway を使った大規模・マルチアカウント構成
- VPC が複数あるなら **Direct Connect Gateway** を経由させることで VIF を集約できる
- VPC 間通信が必要なら **Transit Gateway** を組み合わせる

VIF の種類を間違えると「物理回線はあるのに通信できない」という状況に陥る。最初にどこに接続したいかを明確にしてから VIF の種類を選ぶこと。

---

## 参考

- [AWS Direct Connect 仮想インターフェイス](https://docs.aws.amazon.com/ja_jp/directconnect/latest/UserGuide/WorkingWithVirtualInterfaces.html)
- [プライベート仮想インターフェイスの作成](https://docs.aws.amazon.com/ja_jp/directconnect/latest/UserGuide/create-vif.html)
- [パブリック仮想インターフェイスの作成](https://docs.aws.amazon.com/ja_jp/directconnect/latest/UserGuide/create-vif.html#create-public-vif)
- [AWS Direct Connect Gateway の使用](https://docs.aws.amazon.com/ja_jp/directconnect/latest/UserGuide/direct-connect-gateways-intro.html)
- [Transit Virtual Interface](https://docs.aws.amazon.com/ja_jp/directconnect/latest/UserGuide/create-vif.html#create-transit-vif)
- [Direct Connect Gateway と Transit Gateway の組み合わせ](https://docs.aws.amazon.com/ja_jp/directconnect/latest/UserGuide/direct-connect-transit-gateways.html)
