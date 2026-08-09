# Docker bridgeネットワーク内通信

## 概要
Dockerのbridgeネットワークは、コンテナ間の内部通信を可能にする重要な機能で、分離された安全な環境でのアプリケーション連携を実現します。

## bridgeネットワークの基本概念
bridgeネットワークはDockerホスト上に作成される仮想ネットワークで、各コンテナにプライベートIPを割り当て、コンテナ間の通信を仲介します。

## プライベートIPでの通信

### プライベートIPの基本
コンテナが作成されると、Dockerはbridgeネットワーク内で一意のプライベートIPアドレス（通常は172.17.0.0/16範囲内）を各コンテナに自動的に割り当てます。このIPアドレスはDockerホスト内部でのみ有効です。

### コンテナ間通信の仕組み
1. **基本的な通信フロー**:
   - コンテナAがコンテナBと通信したい場合、コンテナBのプライベートIPアドレスを使用します
   - 通信パケットはbridgeネットワークを経由して送受信されます
   - bridgeはパケットの転送先を適切なコンテナに振り分けます

2. **通信確認方法**:
   ```bash
   # コンテナのIPアドレスを確認
   docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' コンテナ名
   
   # コンテナ内から別コンテナへの疎通確認
   docker exec コンテナA ping コンテナBのIP
   ```

3. **名前解決**:
   - デフォルトbridgeネットワークでは、IPアドレスで直接指定する必要があります
   - ユーザー定義bridgeネットワークでは、コンテナ名での通信が可能です
   ```bash
   # ユーザー定義ネットワークの作成
   docker network create my-bridge
   
   # ネットワークを指定してコンテナ起動
   docker run --name container1 --network my-bridge -d nginx
   docker run --name container2 --network my-bridge -d nginx
   
   # コンテナ名で通信可能
   docker exec container1 ping container2
   ```

### セキュリティ上の注意点
- bridgeネットワーク内の通信はデフォルトで暗号化されていません
- 重要なデータを扱う場合は、アプリケーションレベルでの暗号化を検討しましょう
- 異なるネットワークをセグメント化することで、不要な通信を制限できます

### トラブルシューティング
1. **通信できない場合の確認点**:
   - コンテナが同じネットワークに接続されているか確認
   ```bash
   docker network inspect bridge
   ```
   - ファイアウォール設定の確認
   - アプリケーションが適切なポートをlistenしているか確認

2. **ネットワーク情報の詳細確認**:
   ```bash
   # ブリッジネットワークの詳細情報
   docker network inspect bridge
   
   # コンテナのネットワーク設定確認
   docker inspect -f '{{json .NetworkSettings}}' コンテナ名 | jq
   ```

### 実践例: WebアプリとDBの連携
```bash
# DBコンテナの起動
docker run --name db --network app-network -d postgres

# WebアプリコンテナをDBと接続
docker run --name webapp --network app-network -e DB_HOST=db -d mywebapp

# この例ではDBコンテナの名前「db」を使ってWebアプリからアクセス可能
```

### まとめ
プライベートIPを使用したDocker bridgeネットワーク内通信は、複数コンテナで構成されるアプリケーションの開発・実行において基本となる重要な概念です。ユーザー定義ネットワークを活用することで、より柔軟で管理しやすい環境構築が可能になります。
