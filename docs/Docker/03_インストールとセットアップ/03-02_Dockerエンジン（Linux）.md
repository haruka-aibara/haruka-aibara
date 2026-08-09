# Dockerエンジン（Linux）

Linux サーバーに Docker を入れるとき、GUI 付きの Docker Desktop は不要で、**Docker Engine 単体**を入れる（こちらは OSS・無料でライセンス問題もない）。ただし「apt install docker.io で入れたら古かった」「sudo なしで動かない」「再起動したら Docker ごと止まってた」という定番のつまずきがあるので、正しい手順とセットで押さえる。

## 公式リポジトリから入れる

ディストリビューション標準リポジトリの Docker は古いことが多く、**Docker 公式の apt/dnf リポジトリを追加して入れる**のが公式推奨。Ubuntu の場合の骨子：

```bash
# 公式リポジトリの署名鍵とリポジトリ定義を追加（詳細は公式手順）
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

リポジトリ追加の一般論（署名鍵の意味を含む）は [パッケージリポジトリ](../../Linux/10_パッケージ管理/10-01_パッケージリポジトリ.md) を参照。動作確認は：

```bash
sudo docker run --rm hello-world
```

## インストール後の定番セットアップ

**1. サービスの自動起動を確認**

Docker デーモンは systemd のサービスとして動く。サーバー再起動後に Docker ごと止まっていた、を防ぐ：

```bash
sudo systemctl enable --now docker
systemctl is-enabled docker   # enabled ならOK
```

**2. sudo なしで使えるようにする（トレードオフを理解した上で）**

```bash
sudo usermod -aG docker $USER   # 再ログインで反映
```

docker グループへの追加は実質 root 権限の付与と同義（[00-02_ユーザとグループの権限](../00_前提条件/00-02_ユーザとグループの権限.md)）。CI サーバーや共用マシンでは誰をこのグループに入れるかがそのまま権限設計になる。より厳密にやるなら rootless モード（デーモン自体を一般ユーザで動かす）という選択肢もある。

**3. ログの上限設定**

デフォルトではコンテナのログ（json-file）が無限に育ち、ディスクを食い潰す事故が定番。`/etc/docker/daemon.json` で上限を入れておく：

```json
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" }
}
```

設定後は `sudo systemctl restart docker`。この1手間を初期構築に入れておくと、数ヶ月後の「ディスクフル障害」を1つ潰せる。

## 参考

- [Install Docker Engine on Ubuntu — Docker Docs](https://docs.docker.com/engine/install/ubuntu/)
- [Linux post-installation steps — Docker Docs](https://docs.docker.com/engine/install/linux-postinstall/)
- [Configure logging drivers — Docker Docs](https://docs.docker.com/engine/logging/configure/)
