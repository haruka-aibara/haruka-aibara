# cgroups

`docker run --memory 512m` と書いたら、その 512MB は誰がどう強制しているのか。答えがカーネルの **cgroups**。namespace が「視界」を分けるのに対し、cgroups は「使える量」を分ける——2つ合わせてコンテナの隔離が成立する。

cgroups 自体の仕組み（v1/v2、systemd との関係、ファイルシステムとしての操作）は Linux 側の [cgroups](../../../Operating%20System/Linux/16_コンテナ化/16-02_cgroups.md) にまとめてあるので、ここでは **Docker から見た cgroups** に絞る。

## docker run のオプションと cgroups の対応

```bash
docker run -d \
  --memory=512m --memory-swap=512m \   # メモリ上限（swap込み）
  --cpus=1.5 \                          # CPU 1.5コア相当まで
  --pids-limit=100 \                    # fork爆弾対策
  myapp
```

これらのオプションは、コンテナ用に作られた cgroup の設定ファイルに値を書いているだけ。実物は `/sys/fs/cgroup/system.slice/docker-<コンテナID>.scope/` 配下で確認できる。

## 制限に達したときの挙動を知っておく

**メモリ**：上限を超えると cgroup 内で OOM Killer が発動し、コンテナが **OOMKilled**（exit code 137）で死ぬ。

```bash
docker inspect api --format '{{.State.OOMKilled}}'   # true なら確定
```

「コンテナが突然死ぬ」調査ではまずこれを見る。137 = 128 + 9（SIGKILL）という数字も覚えておくと exit code から即座に当たりがつく。

**CPU**：メモリと違って死なない。上限に達すると**スロットリング**（待たされる）になり、症状は「遅くなる」。`docker stats` で CPU% が上限に張り付いていないか、より正確には cgroup の `cpu.stat` の `nr_throttled` で確認できる。

この非対称（メモリは死ぬ・CPUは遅くなる）を知らないと、性能劣化やコンテナ再起動ループの調査で見当違いの場所を掘ることになる。

## 制限を付けるのは「隣人を守るため」

制限なしのコンテナは、ホストのメモリを食い尽くして**同居する全コンテナとホスト自体**を巻き込める。1コンテナの暴走（またはメモリリーク、あるいは DoS を受けた場合）をそのコンテナ内に閉じ込めるのが cgroups の役割で、本番でリソース制限なしのコンテナを動かすのは、ブレーカーなしで電気を引くのに近い。Kubernetes で resources.limits を必須にする運用も同じ思想。

## 参考

- [Runtime metrics and resource constraints — Docker Docs](https://docs.docker.com/engine/containers/resource_constraints/)
- [Control Group v2 — kernel.org documentation](https://docs.kernel.org/admin-guide/cgroup-v2.html)
