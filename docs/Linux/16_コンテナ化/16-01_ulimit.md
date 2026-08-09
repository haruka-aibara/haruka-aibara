# ulimit

高負荷時にアプリが「Too many open files」を吐いて死んだ。コードのバグではなく、**プロセスが開けるファイル数の上限**に当たった音。この「プロセス単位のリソース上限」を司るのが ulimit で、上限の存在を知らないと原因に永遠にたどり着けない系の障害を起こす。

## 何を制限しているのか

カーネルはプロセスごとに「開けるファイルディスクリプタ数」「作れるプロセス数」「使えるメモリ」などの上限を持っている。暴走した（あるいは乗っ取られた）プロセスがリソースを食い尽くしてホスト全体を道連れにするのを防ぐ仕組み。

```bash
ulimit -a        # 現在のシェルの上限一覧
ulimit -n        # open files の上限だけ（デフォルト 1024 のことが多い）
```

よく問題になるのは2つ：

- **`-n` (open files)**: ソケットもファイル扱いなので、**同時接続数の多いサーバーはここに当たる**。デフォルトの 1024 は現代のサーバーには少ない
- **`-u` (max user processes)**: スレッドもカウントされる。「fork: retry: Resource temporarily unavailable」はこれ

各上限には soft（現在の制限。ユーザーが hard まで引き上げ可）と hard（引き上げの天井。上げるには root）の2段階がある。

## 上限に当たっているかの確認

動いているプロセスの実際の上限と使用量を突き合わせる：

```bash
cat /proc/<PID>/limits              # そのプロセスに効いている上限
ls /proc/<PID>/fd | wc -l           # 実際に開いているFD数
```

使用量が Max open files に張り付いていたら確定。

## 恒久的に上げる場所は「起動経路」で違う

`ulimit -n 65536` はそのシェル限りなので、恒久化は起動経路に合わせて設定する。ここを間違えると「設定したのに効かない」になる：

```bash
# systemd サービス（現代のサーバーアプリはほぼこれ）: ユニットファイルに
[Service]
LimitNOFILE=65536

# SSH ログインユーザー向け: /etc/security/limits.conf に
myapp  soft  nofile  65536
myapp  hard  nofile  65536
```

**systemd 管理のサービスに limits.conf は効かない**（あれは PAM 経由のログインセッション用）。「limits.conf に書いたのに反映されない」の答えは大抵これ。

## コンテナでの位置づけ

コンテナも実体はホスト上のプロセスなので ulimit の対象。Docker はデーモンのデフォルトを継承しつつ、コンテナ単位で上書きできる：

```bash
docker run --ulimit nofile=65536:65536 myapp
```

cgroups（[16-02](16-02_cgroups.md)）が「グループ全体の CPU・メモリ量」を制限するのに対し、ulimit は「プロセス1個が開けるFD数・プロセス数」という別の軸の制限。コンテナのリソース制御はこの2つの合わせ技になっている。

## 参考

- [getrlimit(2) — man7.org](https://man7.org/linux/man-pages/man2/getrlimit.2.html)
- [limits.conf(5) — man7.org](https://man7.org/linux/man-pages/man5/limits.conf.5.html)
- [systemd.exec(5): Process Properties — freedesktop.org](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#Process%20Properties)
