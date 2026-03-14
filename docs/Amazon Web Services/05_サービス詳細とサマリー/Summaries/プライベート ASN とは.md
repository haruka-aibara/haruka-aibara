<!-- Space: harukaaibarapublic -->
<!-- Parent: Summaries -->
<!-- Title: プライベート ASN とは -->

# プライベート ASN とは

## BGP を使う前に「自分の番号」が要る

Direct Connect や Site-to-Site VPN で BGP を設定しようとすると、必ず「ASN を入力してください」という画面に当たる。

**ASN（Autonomous System Number）** は、BGP においてルーター同士が「どの組織のネットワークか」を識別するための番号。BGP セッションを張る両端が、それぞれ異なる ASN を持っていないと動かない。

「じゃあ ASN ってどうやって取るの？」となったとき、多くの企業は **プライベート ASN** を使う。

---

## パブリック ASN とプライベート ASN の違い

| | パブリック ASN | プライベート ASN |
|---|---|---|
| 用途 | インターネット上でルートを広報する | 閉じたネットワーク内（プライベート BGP）で使う |
| 取得 | ARIN / APNIC などに申請・費用がかかる | 申請不要、無料で使える |
| 誰でも取れる？ | 要件あり（自律システムが必要等） | 誰でも使えるが、インターネットには広報できない |

**Direct Connect や VPN は AWS ⇔ オンプレ間の閉じた接続**なので、プライベート ASN で十分に機能する。パブリック ASN を持っていない企業でも、プライベート ASN があれば BGP が使える。

---

## プライベート ASN の範囲

### 2バイト ASN（16ビット）

```
64512 〜 65534
```

もっとも広く使われる範囲。AWS の Virtual Private Gateway（VGW）のデフォルト ASN は **64512**。

### 4バイト ASN（32ビット）

```
4200000000 〜 4294967294
```

2バイトの範囲は 1,023 個しかない。大規模な構成で枯渇が気になる場合は 4 バイト ASN を使う。AWS の Transit Gateway（TGW）はデフォルトで **64512**（作成時に変更可能）。

---

## AWS で ASN が登場する場所

### Virtual Private Gateway（VGW）

Site-to-Site VPN や Direct Connect の終端として VPC にアタッチする機器。VGW 側の ASN と、オンプレ側のルーターの ASN が BGP セッションで対向する。

デフォルトは `64512`。VGW 作成時に変更可能（作成後の変更は不可）。

### Transit Gateway（TGW）

VPN アタッチメントや Direct Connect Gateway 経由で BGP を使う場合、TGW も ASN を持つ。デフォルトは `64512`。TGW 作成時に指定する。

### Direct Connect Virtual Interface（VIF）

プライベート VIF / トランジット VIF では、AWS 側の BGP ASN と顧客側（オンプレ）の BGP ASN を設定する。AWS 側は VGW または TGW の ASN が使われる。

---

## ハマりポイント：両端で同じ ASN を使うと BGP が繋がらない

BGP にはループ防止の仕組みがある。「経路情報に自分の ASN が含まれていたら受け取らない」というルールで、これはデフォルトで動いている。

よくある失敗：

```
VGW の ASN: 64512
オンプレルーター の ASN: 64512  ← 同じにしてしまった
```

この状態では BGP セッションは張れても、ルートが一切受け渡されない（ループと判定されて破棄される）。

**対策：VGW/TGW とオンプレルーターは必ず別の ASN にする。**

例：
```
VGW:          64512
オンプレ:     65000
```

---

## 複数拠点・複数 VGW を使う場合の注意

オフィス A・オフィス B の両方を Direct Connect で接続する構成では、それぞれの接続が別の BGP セッションになる。同じプライベート ASN を両拠点に割り当てると、Transit Gateway で経路が正しく区別されない場合がある。

拠点ごとに ASN を分けておくと、経路制御（どの拠点からのトラフィックか）が明確になる。

```
オフィス A: 65001
オフィス B: 65002
TGW:        64512
```

---

## ピンとくる一文

「プライベート ASN は IP アドレスのプライベートアドレス（10.x.x.x）と同じ考え方。外のインターネットには出ないが、閉じたネットワーク内で BGP を動かすには十分。AWS との接続なら、申請なしで使えるプライベート ASN で問題ない。ただし両端で同じ番号を使うとループ防止で弾かれるので、対向同士は必ず別の ASN にする。」

---

## 参考

- [AWS Virtual Private Gateway の BGP ASN](https://docs.aws.amazon.com/ja_jp/vpn/latest/s2svpn/SetUpVPNConnections.html)
- [Transit Gateway の ASN 設定](https://docs.aws.amazon.com/ja_jp/vpc/latest/tgw/tgw-transit-gateways.html#tgw-create-transit-gateway)
- [Direct Connect Virtual Interface の BGP 設定](https://docs.aws.amazon.com/ja_jp/directconnect/latest/UserGuide/WorkingWithVirtualInterfaces.html)
- [IANA - Private Use AS Numbers](https://www.iana.org/assignments/as-numbers/as-numbers.xhtml)
