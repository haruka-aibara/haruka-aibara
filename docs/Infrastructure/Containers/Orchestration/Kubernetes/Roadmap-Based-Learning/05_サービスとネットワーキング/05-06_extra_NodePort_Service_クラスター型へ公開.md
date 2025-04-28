# Kubernetes NodePort Service

## 概要
NodePort Serviceは、Kubernetesクラスター内のPodをクラスター外部に公開するための最も基本的な方法です。

## 主要概念
NodePort Serviceは、クラスター内の各ノードの指定されたポート（NodePort）でサービスを公開し、外部からのアクセスを可能にします。

## NodePort Serviceの基本

### 仕組み
1. クラスター内の全てのノードで特定のポート（NodePort）を開きます
2. そのポートに届いたトラフィックを適切なPodに転送します
3. ポート範囲は通常30000-32767の間で設定されます

### YAML定義例

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: NodePort
  selector:
    app: my-app
  ports:
    - port: 80          # クラスター内部からアクセスするためのポート
      targetPort: 8080  # コンテナのポート
      nodePort: 30007   # 外部公開用ポート（省略可能、省略時は自動割り当て）
```

### 主な特徴

- **アクセス方法**: `<ノードのIP>:<NodePort>` の形式でアクセス可能
- **自動的な負荷分散**: 複数のPodがある場合は自動的に負荷分散される
- **ポートの自動割り当て**: `nodePort`を指定しない場合、30000-32767の範囲で自動的に割り当てられる
- **全ノードで同じポート**: クラスター内の全てのノードで同じポートが開放される

### ユースケース

- 開発環境やテスト環境での利用
- シンプルなアプリケーションの公開
- LoadBalancerが利用できない環境での代替手段

### 制限事項

- ポート範囲が限られている（30000-32767）
- ノードのIPアドレスが変わると接続先も変更する必要がある
- 本番環境では一般的にLoadBalancer ServiceやIngressの使用が推奨される

### NodePort Serviceのデバッグ

問題が発生した場合のチェックポイント:

1. サービスの状態確認: `kubectl get svc <サービス名>`
2. エンドポイントの確認: `kubectl get endpoints <サービス名>`
3. セレクターとPodのラベルが一致しているか確認
4. ノード上でポートが実際に開いているか確認: `netstat -tlnp | grep <NodePort>`
