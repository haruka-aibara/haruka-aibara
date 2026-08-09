# traceroute

ping で「届かない」ことは分かった。次の疑問は「**どこまでは届いているのか**」。宛先までの経路を1ホップずつ可視化して、切れている場所・遅い場所を特定するのが traceroute。

## 仕組み：TTL を1から増やしながら投げる

IP パケットの TTL（Time To Live）は、ルーターを1つ通過するたびに1減り、0になるとそのルーターが「Time Exceeded」（ICMP）を送り返してくる。traceroute は **TTL=1, 2, 3... と増やしながらパケットを投げ、各ホップからの Time Exceeded の送り主を記録する**ことで経路を炙り出す。エラー通知の仕組みを逆手に取った賢いハック。

```bash
traceroute example.com
```

```
 1  10.0.1.1 (10.0.1.1)  0.5 ms  0.4 ms  0.4 ms
 2  203.0.113.1 (203.0.113.1)  2.1 ms  2.0 ms  2.2 ms
 3  * * *
 4  198.51.100.7 (198.51.100.7)  10.3 ms  10.1 ms  10.4 ms
```

各行が1ホップ、3つの数字は3回計測した RTT。

## 読み方の要点

- **`* * *` は必ずしも障害ではない**: そのルーターが Time Exceeded を返さない（ICMP 応答を制限している）だけで、通過はできていることが多い。3行目が `*` でも4行目が応答していれば経路は生きている
- **途中から最後まで全部 `*`**: そこから先で本当に切れているか、宛先側がフィルタしている。最後に応答したホップが「問題の境界」
- **特定ホップから RTT が跳ね上がる**: そこが遅延の発生点。ただしそのルーターの ICMP 処理が遅いだけのこともあるので、**それ以降のホップでも遅いままか**で判断する（1点だけ遅く、その先が速いなら無害）

## プロトコルを変えて試す

デフォルトで Linux の traceroute は UDP を使うが、ファイアウォールに落とされて `*` が続くことがある。相手が Web サーバーなら実際に通る通信と同じプロトコルで測るのが確実：

```bash
traceroute -I example.com       # ICMP echo を使う（要 root。Windows の tracert と同方式）
traceroute -T -p 443 example.com   # TCP SYN で 443 へ（実サービスの経路をなぞる）
mtr example.com                 # ping + traceroute を継続実行して統計を取る（断続ロスの調査に最強）
```

継続的なパケットロスの位置を特定したいときは、1回きりの traceroute より `mtr` で数分流して各ホップの Loss% を見るほうが確度が高い。

なおクラウド内部（VPC 内）の経路はハイパーバイザに隠蔽されていて、traceroute しても意味のあるホップは見えない。VPC 内の到達性調査は Reachability Analyzer など、プラットフォーム側のツールの領分。

## 参考

- [traceroute(8) — man7.org](https://man7.org/linux/man-pages/man8/traceroute.8.html)
- [mtr(8) — man7.org](https://man7.org/linux/man-pages/man8/mtr.8.html)
- [Reachability Analyzer — AWS Documentation](https://docs.aws.amazon.com/vpc/latest/reachability/what-is-reachability-analyzer.html)
