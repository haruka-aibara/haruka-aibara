# イーサネットと ARP/RARP

IP アドレスも経路も正しいのに、同じセグメントの隣のマシンに届かない。ping は失敗するが設定はどこも間違っていない——この「一番下の層」の問題を調べる道具が ARP まわりの知識。

## IP の下では MAC アドレスで話している

同一セグメント内の通信は、実際にはイーサネットフレームが **MAC アドレス**（NIC 固有の 48bit の識別子）宛てに飛んでいる。IP アドレスはあくまで論理的な住所で、最後の一区間は物理的な宛先（MAC）が必要になる。

この「IP → MAC」の変換をするのが **ARP**（Address Resolution Protocol）。「10.0.1.5 さん、いたら MAC 教えて」とブロードキャストで叫び、本人が答える、という素朴な仕組み。結果はキャッシュされる。

```bash
ip neigh show        # ARP キャッシュ（近隣テーブル）を表示
```

```
10.0.1.1 dev eth0 lladdr 02:xx:xx:xx:xx:01 REACHABLE
10.0.1.5 dev eth0 FAILED
```

`REACHABLE` は解決済み、`FAILED` は「ARP に誰も答えなかった」。冒頭の症状で FAILED が出ていれば、相手が落ちているか、L2 レベルで分断されている（VLAN 違い、スイッチ設定など）ことが分かる。IP 設定をいくら見直しても解決しない理由がここにある。

RARP（逆方向：MAC から自分の IP を知る）はディスクレスマシンの起動用だった歴史的プロトコルで、役割は DHCP に置き換えられた。名前だけ知っていればよい。

## リンク自体の確認

ARP 以前に、そもそもケーブル／仮想NICが生きているかは `ip link` で見る。

```bash
ip link show eth0
```

`state UP` かどうか、`LOWER_UP`（物理リンクが上がっているか）を確認。ここが DOWN なら上の層を調べても無意味。

## セキュリティの視点：ARP は認証がない

ARP には「答えた者が本人か」を確かめる仕組みがない。攻撃者が「10.0.1.1（ゲートウェイ）の MAC は私です」と偽って答えれば、セグメント内の通信を自分経由に引き込める——これが **ARP スプーフィング**で、同一 LAN 内での中間者攻撃の古典。公衆 Wi-Fi で平文プロトコルを使うなという話の技術的根拠のひとつでもある。クラウドの VPC ではハイパーバイザ側で ARP が仮想化されており、この攻撃は基本的に成立しない（オンプレや物理 LAN 固有のリスク）。

## 参考

- [ip-neighbour(8) — man7.org](https://man7.org/linux/man-pages/man8/ip-neighbour.8.html)
- [RFC 826: An Ethernet Address Resolution Protocol](https://datatracker.ietf.org/doc/html/rfc826)
