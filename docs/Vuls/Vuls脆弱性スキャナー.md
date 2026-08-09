# Vuls：Linuxサーバーの脆弱性スキャナー

## Vulsとは

[Vuls](https://github.com/future-architect/vuls)は、LinuxサーバーにインストールされているパッケージのCVEをスキャンしてくれるOSSの脆弱性スキャナー。フューチャー株式会社が開発・OSS公開している。

エージェントレスで動作するのが特徴で、スキャン対象サーバーに何もインストールせずにSSH越しに検査できる。

**対応OS**: RHEL/CentOS/Amazon Linux/Ubuntu/Debian/AlmaLinux/RockyLinux/Fedora など

---

## なぜVulsを使うのか

「パッチ当ててます？」「何の？」「よくわからないけどyum updateしてます」が現場でよくある。

Vulsを使うと：

- インストール済みパッケージとCVEデータベースを突き合わせて **今この瞬間に危ないやつを一覧化** できる
- CVSSスコアで重要度がわかる
- 差分スキャンで「前回から何が増えたか」を追える
- 複数サーバーをまとめてスキャンできる

---

## セットアップ（ローカル or 管理サーバーで動かす）

### 1. Vuls本体のインストール

```bash
# バイナリをダウンロードして配置（例：Linux amd64）
curl -sL https://github.com/future-architect/vuls/releases/latest/download/vuls_linux_amd64.tar.gz \
  | tar xz -C /usr/local/bin/

# バージョン確認
vuls version
```

### 2. 脆弱性DBのダウンロード

VulsはCVEデータをローカルDBとして持つ。`trivy`のように都度ネット参照ではなくローカルで完結するので、エアギャップ環境でも使える。

```bash
# trivy-db形式のDBを使う場合（最近のVulsはtrivy-dbに対応）
mkdir -p /opt/vuls/db
trivy image --download-db-only --db-repository ghcr.io/aquasecurity/trivy-db
```

> **注意**: VulsのバージョンによってDBの取得方法が変わっている。公式READMEのバージョンに合わせて確認すること。

---

## 設定ファイル（config.toml）

```toml
[servers]

[servers.web01]
host    = "192.168.1.10"
port    = "22"
user    = "ec2-user"
keyPath = "/home/user/.ssh/id_rsa"

[servers.web02]
host    = "192.168.1.11"
port    = "22"
user    = "ubuntu"
keyPath = "/home/user/.ssh/id_rsa"
```

EC2なら踏み台経由も書ける：

```toml
[servers.app01]
host    = "10.0.1.20"
port    = "22"
user    = "ec2-user"
keyPath = "/home/user/.ssh/id_rsa"

[servers.app01.sshConfig]
proxy = "bastion"

[servers.bastion]
host    = "203.0.113.10"
port    = "22"
user    = "ec2-user"
keyPath = "/home/user/.ssh/id_rsa"
```

---

## スキャン実行

```bash
# 設定確認（接続テスト）
vuls configtest

# スキャン実行
vuls scan

# レポート表示（ターミナル）
vuls tui
```

`vuls tui` を実行するとターミナル上でインタラクティブに結果を確認できる。サーバー一覧 → パッケージ一覧 → CVE詳細と掘り下げていける。

---

## スキャン結果のイメージ

```
+-----------+------+----------+------+--------+-----+
| SERVER    | PKGS | CRITICAL | HIGH | MEDIUM | LOW |
+-----------+------+----------+------+--------+-----+
| web01     |  312 |        2 |    8 |     15 |  42 |
| web02     |  287 |        0 |    3 |     11 |  38 |
+-----------+------+----------+------+--------+-----+
```

CRITICAL が出たら即確認。パッケージ名とCVSS、パッチが出ているか否かまで教えてくれる。

---

## VulsRepo（WebUI）

`vuls tui` は手元確認用。チームで使うなら [VulsRepo](https://github.com/usiusi360/vulsrepo) というWebUIが使える。

```bash
# スキャン結果をJSONで出力
vuls report -format-json

# VulsRepo（Dockerで起動）
docker run -d \
  -p 5111:5111 \
  -v /path/to/results:/opt/vulsrepo/current/results \
  usiusi360/vulsrepo

# ブラウザで http://localhost:5111 を開く
```

時系列で脆弱性の増減を見れるので、「先月のパッチ適用で何件解消されたか」がわかる。

---

## よくある使い方パターン

### cronで定期スキャン

```bash
# /etc/cron.d/vuls
0 3 * * * root cd /opt/vuls && vuls scan && vuls report -format-json 2>&1 | logger -t vuls
```

### AWS SSM経由でスキャン

SSH不要でSSM Session Manager越しにスキャンできる。踏み台なしでプライベートサブネットのEC2もスキャン対象にできる。

```toml
[servers.private-ec2]
host    = "dummy"  # SSM使用時はダミーでOK
user    = "ec2-user"

[servers.private-ec2.ssmParameters]
instanceId = "i-0123456789abcdef0"
region     = "ap-northeast-1"
```

---

## Trivyとの使い分け

| | Vuls | Trivy |
|---|---|---|
| 対象 | サーバー上のパッケージ | コンテナイメージ・IaC・fs |
| 方式 | エージェントレス（SSH/SSM） | ローカル実行 or CI組み込み |
| 向いてる場面 | 既存サーバーの棚卸し・定期監査 | CI/CDパイプライン・コンテナセキュリティ |

コンテナはTrivy、サーバーはVuls、が現場での定番の組み合わせ。

---

## まとめ

- **エージェントレス**でSSH/SSM越しにスキャン → 既存サーバーに何も入れなくていい
- CVSSスコアで優先順位がつけられる
- **VulsRepo** でチームに共有しやすい
- cronで定期実行してJSONに吐けば監査証跡にもなる

「パッチ当たってますか？」と聞かれたときに「はい、Vulsで確認してます」と言えるようになる。
