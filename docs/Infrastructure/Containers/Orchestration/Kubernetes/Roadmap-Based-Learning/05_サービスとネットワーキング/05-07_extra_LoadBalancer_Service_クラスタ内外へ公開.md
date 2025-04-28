# Kubernetes LoadBalancer Service 講義

## 概要
LoadBalancer ServiceはKubernetesクラスタ内のアプリケーションを外部ネットワークに公開するための重要な仕組みです。

## LoadBalancer Serviceとは
LoadBalancer ServiceはKubernetesのService typeの一つで、クラウドプロバイダーのロードバランサーを利用してクラスタ外部からPodへのアクセスを可能にします。

## L4 LoadBalancerの基本

### L4ロードバランシングとは
LoadBalancer ServiceはネットワークのOSI参照モデルにおけるレイヤー4（トランスポート層）で動作します。これはIPアドレスとポート番号に基づいてトラフィックを分散させる仕組みです。

### L4とL7の違い
L4ロードバランサーはTCP/UDPレベルでトラフィックを処理し、パケットの内容（HTTPヘッダーやURLパスなど）を検査せず、単純にパケットを転送します。対照的に、L7（アプリケーション層）ロードバランサーはHTTP/HTTPSなどのアプリケーションプロトコルを理解し、コンテンツベースのルーティングが可能です。

## LoadBalancer Serviceの仕組み

### 動作原理
1. LoadBalancer typeのServiceを作成すると、KubernetesはクラウドプロバイダーのAPIを呼び出します
2. クラウドプロバイダーは外部IPアドレスを持つロードバランサーをプロビジョニングします
3. 外部トラフィックはロードバランサーを経由して、Kubernetes内の適切なPodに転送されます

### 内部アーキテクチャ
LoadBalancer ServiceはNodePortの拡張として機能します：
1. ClusterIPを割り当て（クラスタ内通信用）
2. NodePortを割り当て（各ノードでポートを開放）
3. 外部ロードバランサーが各ノードのNodePortにトラフィックを分散

## 実装方法

### 基本的なYAMLファイル例
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: my-app
  ports:
  - port: 80        # Service公開ポート
    targetPort: 8080 # コンテナ側ポート
    protocol: TCP
  type: LoadBalancer
```

### 主要な設定パラメータ
- `spec.ports[].port`: Serviceが外部に公開するポート
- `spec.ports[].targetPort`: トラフィックが転送される先のPod内ポート
- `spec.ports[].protocol`: 使用するプロトコル（TCPまたはUDP）
- `spec.loadBalancerIP`: 特定のIPアドレスを指定（クラウドプロバイダーによってサポートが異なる）
- `spec.externalTrafficPolicy`: クライアントの送信元IPを保持する方法を指定

## クラウドプロバイダー別の特徴

### AWS
- AWS Elastic Load Balancing (ELB) を使用
- 通常はClassic LoadBalancerまたはNetwork Load Balancerが採用される
- セキュリティグループが自動的に設定される

### GCP
- Google Cloud Load Balancing を使用
- リージョン間ロードバランシングをサポート
- ヘルスチェックが自動的に設定される

### Azure
- Azure Load Balancerを使用
- 内部/外部ロードバランサーを選択可能
- セキュリティルールが自動的に設定される

## オンプレミス環境での対応

### MetalLB
- ベアメタル環境でもLoadBalancer Serviceを実現するソリューション
- 2つの動作モード：
  - Layer 2モード：ARPを使用したIPアドレス広告
  - BGPモード：ルーターとBGPセッションを確立

### その他の方法
- OpenELB
- クラウドプロバイダーコントローラーの独自実装

## セキュリティ考慮事項

### 外部公開の注意点
- 不要なポートは公開しない
- アクセス制限を検討（ソースIPフィルタリング）
- 適切な認証・認可の実装

### 通信の暗号化
- 機密性の高い通信にはTLS/SSLを使用
- 必要に応じてIngressと組み合わせる

## パフォーマンスチューニング

### externalTrafficPolicy
- `Cluster`: デフォルト設定。どのノードでも受信可能だが、クライアントIPが保持されない
- `Local`: 接続されたノード上のPodにのみルーティング。クライアントIPを保持するが、Pod分散に偏りが出る可能性あり

### セッション永続性
```yaml
spec:
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
```

## トラブルシューティング

### 一般的な問題
1. 外部IPが割り当てられない
   - クラウドプロバイダーの設定を確認
   - クォータ制限をチェック
2. 接続できない
   - セキュリティグループ/ファイアウォール設定を確認
   - Podのヘルスステータスを確認
3. 不均等なトラフィック分散
   - `externalTrafficPolicy`の設定を確認

### デバッグコマンド
```bash
# Serviceの状態確認
kubectl get service my-service -o wide

# 詳細情報の確認
kubectl describe service my-service

# エンドポイント（接続先Pod）の確認
kubectl get endpoints my-service
```

## ベストプラクティス

1. 適切なヘルスチェックの設定
2. 必要最小限のポート公開
3. セキュリティ設定の定期的な見直し
4. 複数のレプリカでの冗長性確保
5. モニタリングとアラートの設定

## まとめ
LoadBalancer ServiceはL4レベルでクラスタ外部からのトラフィックをPodに分散させる仕組みです。クラウドプロバイダーのロードバランサーを活用しつつ、Kubernetesの抽象化によって簡単に外部公開が可能となります。適切な設定とセキュリティ対策を行いながら活用しましょう。
