# Dockerのブリッジネットワークでの名前解決

## 概要
Dockerのブリッジネットワークにおける名前解決は、コンテナ間の通信を簡素化し、IPアドレスを覚える必要なく他のコンテナに接続できる重要な機能です。

## 理論的説明
Dockerのブリッジネットワークは、コンテナ間の通信を可能にする仮想ネットワークで、組み込みのDNSサーバーを使用してコンテナ名からIPアドレスへの名前解決を行います。

## ブリッジネットワークとは
ブリッジネットワークはDockerのデフォルトのネットワークドライバーです。コンテナを起動すると、特に指定しない限り「bridge」という名前のデフォルトブリッジネットワークに接続されます。

```bash
# デフォルトのブリッジネットワークを確認
$ docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
xxxxxxxxxxxx   bridge    bridge    local
xxxxxxxxxxxx   host      host      local
xxxxxxxxxxxx   none      null      local
```

## デフォルトブリッジネットワークの名前解決の制限

デフォルトのブリッジネットワーク (`bridge`) には重要な制限があります：

- コンテナ名による自動名前解決が**機能しません**
- コンテナ間の通信にはIPアドレスを使用するか、`--link`オプションを使用する必要があります（ただし`--link`は非推奨）

```bash
# デフォルトのブリッジネットワークでコンテナを起動
$ docker run -d --name web nginx
$ docker run -d --name db postgres

# 同じデフォルトブリッジネットワーク上でも名前解決できない
$ docker exec web ping db
ping: db: Name or service not known
```

## カスタムブリッジネットワークでの名前解決

ユーザー定義のカスタムブリッジネットワークを作成すると、**自動名前解決**が有効になります：

```bash
# カスタムブリッジネットワークの作成
$ docker network create mynetwork

# カスタムネットワークにコンテナを接続
$ docker run -d --name web --network mynetwork nginx
$ docker run -d --name db --network mynetwork postgres

# 名前解決が機能する
$ docker exec web ping db
PING db (172.18.0.3) 56(84) bytes of data.
64 bytes from db (172.18.0.3): icmp_seq=1 ttl=64 time=0.086 ms
...
```

## 名前解決の仕組み

1. Dockerは組み込みのDNSサーバー（127.0.0.11）を使用
2. コンテナ内の`/etc/resolv.conf`にDNSサーバーが設定される
3. コンテナ名がホスト名としてIPアドレスに解決される

```bash
# コンテナ内のDNS設定を確認
$ docker exec web cat /etc/resolv.conf
nameserver 127.0.0.11
options ndots:0
```

## エイリアスを使用した名前解決

同じネットワーク内のコンテナにエイリアス（別名）を付けることも可能です：

```bash
# エイリアスを指定してコンテナを起動
$ docker run -d --name db --network mynetwork --network-alias database postgres

# エイリアスでアクセス可能
$ docker exec web ping database
PING database (172.18.0.3) 56(84) bytes of data.
...
```

## 複数ネットワークへの接続

コンテナは複数のネットワークに接続でき、それぞれのネットワーク内で名前解決できます：

```bash
# 別のネットワークを作成
$ docker network create frontend

# 既存のコンテナを別のネットワークに追加接続
$ docker network connect frontend web

# webコンテナは両方のネットワークでアクセス可能
```

## よくある問題と解決策

1. **名前解決が機能しない場合**
   - デフォルトのブリッジではなく、カスタムネットワークを使用しているか確認
   - コンテナが同じネットワークに接続されているか確認

2. **同じ名前のコンテナが存在する場合**
   - エイリアスを使用して区別する

3. **コンテナの再起動後にIPアドレスが変わる**
   - 名前解決に依存することで、IPアドレスの変更に対応できる

## まとめ

カスタムブリッジネットワークを使用することで：
- コンテナ間の通信が簡素化される
- IPアドレスを意識せずにコンテナ名で通信できる
- 複数のネットワークを分離しつつ必要な接続を確保できる

以上の機能を活用することで、複雑なマルチコンテナアプリケーションも効率的に構築できます。
