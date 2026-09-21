# Docker講義：bridgeネットワーク

## 概要
bridgeネットワークはDockerのデフォルトネットワークドライバーであり、コンテナ間の通信と外部ネットワークへの接続を可能にする重要な機能です。

## 理論的説明
bridgeネットワークはLinuxのブリッジ技術を使用して、独立したネットワーク名前空間を持つDockerコンテナ間の通信を実現します。

## bridgeネットワークの基本操作

### docker network ls
現在のホスト上に存在するすべてのネットワークを一覧表示します。

```bash
$ docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
a1b2c3d4e5f6   bridge    bridge    local
x1y2z3a4b5c6   host      host      local
m1n2o3p4q5r6   none      null      local
```

### docker network inspect
指定したネットワークの詳細情報を表示します。

```bash
$ docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "a1b2c3d4e5f6...",
        "Created": "2023-04-01T12:00:00.000000000Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
```

### docker network create
カスタムブリッジネットワークを作成します。

```bash
# 基本的なブリッジネットワークの作成
$ docker network create my-bridge-network

# サブネットとゲートウェイを指定したブリッジネットワークの作成
$ docker network create --subnet=192.168.100.0/24 --gateway=192.168.100.1 my-custom-bridge
```

## コンテナをブリッジネットワークで起動する

### docker container run --network
特定のネットワークを指定してコンテナを起動します。

```bash
# デフォルトのブリッジネットワークでコンテナを起動
$ docker container run -d --name web-default nginx

# カスタムブリッジネットワークでコンテナを起動
$ docker container run -d --name web-custom --network my-bridge-network nginx
```

### 既存コンテナをネットワークに接続/切断する

```bash
# コンテナをネットワークに接続
$ docker network connect my-bridge-network container-name

# コンテナをネットワークから切断
$ docker network disconnect my-bridge-network container-name
```

## bridgeネットワークの特徴

- デフォルトではすべてのコンテナが`bridge`ネットワークに接続されます
- 同じブリッジネットワーク上のコンテナ同士はIPアドレスで通信可能です
- カスタムブリッジネットワークではDNSによる名前解決が自動的に機能します
- ポートマッピング（-p オプション）によりホストとコンテナ間の通信が可能になります
