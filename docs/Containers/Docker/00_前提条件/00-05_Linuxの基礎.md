# 前提知識：Linuxの基礎

コンテナは「軽量なVM」ではなく **Linux カーネルの機能で隔離されたプロセス**。だから Docker の理解の深さは、そのまま Linux の理解の深さに比例する。トラブルシューティングで「Docker の問題」に見えるものの多くは、実は Linux の問題。

## Docker 学習に直結する Linux 知識

| Docker で起きること | 背後にある Linux 知識 |
|---|---|
| コンテナが OOMKilled で死ぬ | メモリ管理、cgroups、OOM Killer |
| `docker stop` で止まらないコンテナ | プロセスとシグナル（SIGTERM/SIGKILL）、PID 1 の特殊性 |
| ポートが競合して起動しない | ソケット、`ss` での LISTEN 確認 |
| マウントしたファイルが Permission denied | ファイルパーミッション、UID/GID |
| イメージが肥大化する | ファイルシステム、ディレクトリ構造 |
| コンテナ間で通信できない | ネットワーク（IP、DNS、ルーティング） |

つまり Docker のエラーメッセージを読み解く語彙は、ほぼ Linux 側にある。

## 学習リソース

このリポジトリの Linux 章がそのまま前提知識になる。全部やる必要はなく、Docker との関連が深いのは以下：

- [プロセス管理](../../../Operating%20System/Linux/07_プロセス管理/)（シグナル、フォーク）
- [サービス管理（Systemd）](../../../Operating%20System/Linux/09_サービス管理（Systemd）/)（Docker デーモン自体の管理）
- [ネットワーク](../../../Operating%20System/Linux/13_ネットワーク/)
- [コンテナ化](../../../Operating%20System/Linux/16_コンテナ化/)（ulimit、cgroups、ランタイム——コンテナの土台そのもの）

特に [コンテナ化](../../../Operating%20System/Linux/16_コンテナ化/) の4記事は、この Docker 章の 02_基盤技術 と直接つながっている。

## 参考

- [Docker overview — Docker Docs](https://docs.docker.com/get-started/docker-overview/)
