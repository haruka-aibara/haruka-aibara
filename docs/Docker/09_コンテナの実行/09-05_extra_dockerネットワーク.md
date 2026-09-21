# Docker ネットワーク

## 概要
Dockerネットワークはコンテナ間の通信を可能にし、分散アプリケーションの構築に不可欠な要素です。

## 基本概念
Dockerネットワークはコンテナを互いに、またはホストマシンや外部ネットワークと接続するための仮想ネットワークインフラストラクチャです。

## Docker ネットワークの一覧表示

Dockerで利用可能なネットワークを一覧表示するには、以下のコマンドを使用します：

```bash
docker network ls
```

このコマンドは以下の情報を表示します：
- NETWORK ID: ネットワークの一意の識別子
- NAME: ネットワーク名
- DRIVER: 使用されているネットワークドライバー（bridge、host、overlay、macvlan、noneなど）
- SCOPE: ネットワークのスコープ（local、swarmなど）

例：
```
NETWORK ID     NAME      DRIVER    SCOPE
7b369448c0f1   bridge    bridge    local
c4083b7fbe6c   host      host      local
5e4bb9c6e109   none      null      local
```

デフォルトでは、Docker はインストール時に3つの標準ネットワーク（bridge、host、none）を作成します。

### 注意点：
- `bridge`ネットワークは、単一ホスト上でコンテナ間の通信に使用される標準のネットワークです
- `host`ネットワークは、コンテナがホストのネットワークスタックを直接使用します
- `none`ネットワークは、ネットワーク機能を持たないコンテナ用です
