<!-- Space: harukaaibarapublic -->
<!-- Parent: ネットワークセキュリティ -->
<!-- Title: MACsec：Direct Connect の L2 暗号化と CKN/CAK/LAG -->

# MACsec：Direct Connect の L2 暗号化と CKN/CAK/LAG

## なぜ Direct Connect でも暗号化が必要か

Direct Connect は「インターネットを通らない専用線」という売り文句だが、物理的には AWS の Direct Connect ロケーション（コロケーション施設）を経由する。この施設は AWS が単独で管理しているわけではなく、複数のテナントが同じ建物の中に設備を置く。

「専用線だから盗聴されない」という前提は成立しない。物理層では盗聴・タッピングのリスクがゼロではないし、コンプライアンス上「伝送経路はすべて暗号化していること」を求められる環境もある。

このニーズを満たすのが **MACsec（IEEE 802.1AE）**。L2（イーサネットフレーム）レベルで暗号化するため、IPsec や TLS より下のレイヤーで透過的に動く。

---

## MACsec が何をしているか

MACsec はイーサネットフレームを**ホップ間**で暗号化する。

```
【MACsec なし】
[Customer Router] ─────────────────── [AWS DX Router]
  イーサネットフレームが平文で流れる

【MACsec あり】
[Customer Router] ══════════════════ [AWS DX Router]
  フレームが暗号化されて流れる（AES-256-GCM）
```

「ホップ間」という点が重要で、MACsec は点と点の間だけを暗号化する。ルーターを中継するたびに復号→再暗号化が起きる。これは IPsec（エンドツーエンド）とは異なる動作モデルで、**同じ物理リンクでつながる 2 機器の間だけを守る**設計になっている。

暗号化後のフレーム構造：

```
| Destination MAC | Source MAC | 802.1Q (optional) | MACsec Tag (SecTAG) | 暗号化ペイロード | ICV（認証タグ）|
```

- **SecTAG**: MACsec ヘッダー。暗号化に使ったキーの識別子（SCI/AN）を含む
- **ICV（Integrity Check Value）**: 改ざん検知用の認証タグ（GCM の認証タグ）

---

## CKN と CAK：2 種類のキー

MACsec のキー管理は **MKA（MACsec Key Agreement）** プロトコルが担う。MKA は 2 つの要素で認証と鍵導出を行う。

### CAK（Connectivity Association Key）

接続の信頼関係を証明するための**マスターキー**。実際の暗号化には使わず、SAK（Session Authentication Key）を導出するために使う。

- 128 bit または 256 bit の 16 進数文字列
- 両端（Customer Router と AWS）で同じ値を設定する
- 定期的に自動ローテーションされる（SAK レベルで）

### CKN（Connectivity Association Key Name）

CAK を識別するための**名前（識別子）**。

- 1〜64 バイトの 16 進数文字列
- CAK と対になって使われる
- どの CAK を使って接続を確立するかを相互に識別するために必要

CKN/CAK のペアを「事前共有鍵」のように扱い、両端に同じペアを設定することで MKA が鍵合意を完了させ、MACsec セッションが確立する。

```
Customer Router                    AWS DX Router
  CKN: abc123...                     CKN: abc123...  ← 一致
  CAK: def456...                     CAK: def456...  ← 一致
        ↓                                  ↓
      MKA で相互認証・SAK 導出
        ↓
  MACsec セッション確立（SAK で暗号化）
```

### AWS での設定例

AWS CLI で Direct Connect 接続に MACsec を設定する場合、CKN と CAK を AWS Secrets Manager に保存してから接続に関連付ける。

```bash
# シークレットを作成（CKN と CAK のペア）
aws directconnect associate-mac-sec-key \
  --connection-id dxcon-xxxxxxxx \
  --ckn "a1b2c3d4e5f6..." \
  --cak "0102030405060708..."
```

設定後、接続の `macSecCapable` が `true`、`encryptionMode` が `must_encrypt` になっていることを確認する。

---

## LAG（Link Aggregation Group）と MACsec

### LAG とは

LAG は複数の物理リンクを束ねて**1 本の論理リンク**として扱う仕組み（IEEE 802.3ad、別名 LACP）。

```
Physical Link 1 (10G) ─┐
Physical Link 2 (10G) ─┼──→ LAG（論理 30G） ──→ AWS
Physical Link 3 (10G) ─┘
```

目的は 2 つ：帯域の拡張と冗長性。1 本が切れても残りの物理リンクでトラフィックを継続できる。

AWS Direct Connect では、同じ AWS DX ロケーション・同じ帯域の専用接続を LAG にまとめられる（最大 4 本）。

### MACsec + LAG の組み合わせ

MACsec は**物理リンクごとに独立して設定する**。LAG を構成する各物理リンクが個別に MACsec セッションを張る。

```
Physical Link 1 ══ MACsec ══ AWS Port 1 ─┐
Physical Link 2 ══ MACsec ══ AWS Port 2 ─┼── LAG
Physical Link 3 ══ MACsec ══ AWS Port 3 ─┘
```

**LAG に MACsec を設定するとき**、AWS では LAG 全体に対して CKN/CAK を設定する。設定は LAG を構成する各接続に自動的に伝播する。

```bash
# LAG に MACsec キーを設定
aws directconnect associate-mac-sec-key \
  --connection-id dxlag-xxxxxxxx \  ← LAG の ID を指定
  --ckn "a1b2c3d4e5f6..." \
  --cak "0102030405060708..."
```

注意点として、**すべての物理リンクで MACsec が成立しないと LAG が active にならない**設定も可能（`encryptionMode: must_encrypt`）。一部の物理リンクだけ MACsec が失敗している状態を許容したくない場合に使う。

---

## MACsec の対象範囲と限界

MACsec で暗号化されるのは**物理リンク上のイーサネットフレーム**だけ。

```
Customer Datacenter  ──── MACsec ────  DX Location  ──── ??? ────  AWS Region
                      ↑ ここだけ暗号化                  ↑ ここは別の話
```

DX ロケーションから AWS リージョンの間は MACsec の範囲外。AWS 内のバックボーンは物理的に AWS の管理下にあるため、MACsec は不要という設計になっている。

また、**仮想インターフェース（VIF）上を流れるトラフィック自体の暗号化ではない**。アプリケーションの通信内容を守りたいなら、MACsec に加えて TLS や IPsec VPN over Direct Connect を組み合わせる必要がある。MACsec は「物理リンクのタッピング対策」であり、「アプリケーション通信の機密性保護」は別レイヤーの仕事だ。

---

## まとめ：何を守るために使うか

| 脅威 | 対策 | MACsec で解決するか |
|---|---|---|
| DX ロケーションでの物理タッピング | MACsec | ○ |
| 経路上のパケット改ざん | MACsec（ICV による検知） | ○ |
| AWS 内バックボーンでの盗聴 | AWS の物理セキュリティに依存 | △（範囲外） |
| アプリケーション通信の盗聴 | TLS / IPsec | ✗（MACsec の役割ではない） |
| DX 障害時の冗長性 | LAG + バックアップ接続 | ✗（MACsec の役割ではない） |

コンプライアンス要件で「伝送経路の L2 暗号化」が明示されている場合や、金融・医療系で Direct Connect のロケーションを共有する他テナントを脅威として扱う場合に MACsec が実質的な要件になる。

---

## 参考

- [MACsec for Direct Connect - AWS ドキュメント](https://docs.aws.amazon.com/directconnect/latest/UserGuide/MACsec.html)
- [Configure MACsec on Direct Connect connections - AWS ドキュメント](https://docs.aws.amazon.com/directconnect/latest/UserGuide/MACsec_configuring.html)
- [IEEE 802.1AE: MAC Security (MACsec)](https://1.ieee802.org/security/802-1ae/)
- [MACsec Key Agreement (MKA) - RFC 8823](https://www.rfc-editor.org/rfc/rfc8823)
- [Link Aggregation for Direct Connect - AWS ドキュメント](https://docs.aws.amazon.com/directconnect/latest/UserGuide/lags.html)
