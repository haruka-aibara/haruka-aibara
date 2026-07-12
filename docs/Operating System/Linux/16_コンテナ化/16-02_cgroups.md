# cgroups

コンテナに `--memory 512m` と付けたら、超過時に OOMKilled になった。Kubernetes の Pod に resources.limits を書いたら CPU が頭打ちになった。この「制限が実際に効く」仕組みの正体がカーネルの cgroups（control groups）で、コンテナの資源制御を1枚めくると必ずこれが出てくる。

## 何をするものか

cgroups は**プロセスをグループにまとめ、グループ単位で資源（CPU・メモリ・ディスクI/O・プロセス数）を計測・制限する**カーネル機能。ulimit が「プロセス1個の上限」なのに対し、cgroups は「この一団でメモリ 512MB まで」という**集団への割当**ができる。

コンテナの「隔離」は2つのカーネル機能の分業で成り立っている：

- **namespaces**: 見える世界を分ける（プロセス一覧、ネットワーク、ファイルシステム）
- **cgroups**: 使える量を分ける（CPU、メモリ、I/O）

「コンテナは軽量VM」ではなく「namespace で視界を絞り、cgroups で量を絞った、ただのプロセス」——この理解がコンテナのトラブルシューティングの土台になる。

## 実物を見る

cgroups はファイルシステム（cgroup v2 では `/sys/fs/cgroup` に一元化）として見え、ファイルの読み書きで操作できる。systemd はすべてのサービスを cgroup に入れて管理しているので、コンテナがなくても実は毎日使っている：

```bash
systemd-cgls                     # cgroup ツリーを一覧（サービスごとにグループ化されている様子が見える）
systemd-cgtop                    # cgroup 単位のリソース使用量 top
cat /sys/fs/cgroup/system.slice/nginx.service/memory.current   # nginx グループの現在メモリ
```

手で cgroup を切るより、実務では systemd 経由で制限を書くのが現実的：

```ini
# ユニットファイルの [Service] に
MemoryMax=512M
CPUQuota=50%
```

これだけで「このサービスはメモリ 512MB・CPU 半コアまで」が効く。**コンテナ化していないサービスにも資源制限をかけられる**のは意外と知られていない実用ポイント。

## トラブルシューティングでの接点

- **コンテナが突然死んだ**: メモリ制限超過なら cgroup の OOM Kill。`dmesg` に「Memory cgroup out of memory」と残る（ホスト全体の OOM とはメッセージが違う）
- **CPU制限下で性能が出ない**: 制限は「使用率を超えたら待たされる（スロットリング）」として効く。`/sys/fs/cgroup/.../cpu.stat` の `nr_throttled` で発生回数が見える
- **コンテナ内の `free` や `top` がホスト全体の値を出す**: 古いツールは cgroup を知らないため。コンテナ内の実際の割当は cgroup ファイルを見るのが確実

なお現在は cgroup v2 が主流（Ubuntu 22.04+、RHEL 9+ はデフォルト）。古い記事の `/sys/fs/cgroup/memory/...`（v1 の階層）とパスが違うのは、バージョン差なので惑わされないように。

## 参考

- [Control Group v2 — kernel.org documentation](https://docs.kernel.org/admin-guide/cgroup-v2.html)
- [cgroups(7) — man7.org](https://man7.org/linux/man-pages/man7/cgroups.7.html)
- [systemd.resource-control(5) — freedesktop.org](https://www.freedesktop.org/software/systemd/man/latest/systemd.resource-control.html)
