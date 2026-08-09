# netstat（と ss）

「このサーバー、どのポートで何が待ち受けてる？」「アプリが起動しない。ポートが既に使われているらしい」「見覚えのない外向き接続がないか確認したい」——接続とポートの現状把握はトラブルシューティングの基本動作。その道具が netstat、そして現行の後継が ss。

netstat は古典として今も広く知られているが、非推奨コンパチ扱いで最小インストールには入っていないことも多い。**コマンドは ss で覚え、netstat は「他人の手順書を読めるように」知っておく**のが現在地。オプションはほぼ共通なので片方覚えれば両方使える。

## 一番使う形：何が LISTEN しているか

```bash
sudo ss -tulnp
```

```
Netid State  Local Address:Port  Process
tcp   LISTEN 0.0.0.0:22          users:(("sshd",pid=812,fd=3))
tcp   LISTEN 127.0.0.1:5432      users:(("postgres",pid=1201,fd=7))
tcp   LISTEN 0.0.0.0:80          users:(("nginx",pid=1408,fd=6))
```

オプションの意味：**t**cp / **u**dp / **l**isten のみ / **n**umeric（名前解決しない＝速い）/ **p**rocess（どのプロセスか。要 root）。この5文字はこのまま定型句として覚える。

読み方で重要なのは **Local Address**：

- `127.0.0.1:5432` — ローカルからしか接続できない。「外から DB につながらない」の原因はしばしばこれ（バインド先の設定）
- `0.0.0.0:80` — 全インターフェースで待ち受け。外部公開の意図がないものがここにいたらセキュリティ上の見直し対象

「Address already in use」で起動に失敗したときは `sudo ss -tlnp | grep :8080` で先客を特定する。

## 確立済みの接続を見る

```bash
ss -tnp state established              # いま張られている接続と相手
ss -tn state established '( dport = :443 )'   # 443 宛だけに絞る
ss -s                                  # 状態別のサマリ（TIME-WAIT が異常に多い等の把握）
```

インシデント対応の文脈では、「このホストがどこと通信しているか」の一覧はマルウェアの C2 通信や意図しないデータ持ち出しを疑うときの基本証拠。定常状態を知っていて初めて異常が分かるので、平時に一度眺めておく価値がある。

## netstat しかない環境では

```bash
netstat -tulnp     # ss とほぼ同じ意味で使える
netstat -rn        # ルーティングテーブル（ip route show 相当）
```

## 参考

- [ss(8) — man7.org](https://man7.org/linux/man-pages/man8/ss.8.html)
- [netstat(8) — man7.org](https://man7.org/linux/man-pages/man8/netstat.8.html)
