# Kubernetes: ネットワーキング

## はじめに
「コンテナ間の通信を効率的に管理したい」「異なるネットワークドライバーの特徴を理解したい」「セキュアなネットワーク構成を実現したい」そんな悩みはありませんか？Kubernetesのネットワーキングは、これらの問題を解決し、コンテナ間の通信を柔軟に管理する重要な機能です。この記事では、ネットワーキングの基本概念から実践的な使い方まで、わかりやすく解説します。

## ざっくり理解しよう
Kubernetesのネットワーキングには、以下の3つの重要なポイントがあります：

1. ネットワークモデル
   - コンテナ間通信
   - ノード間通信
   - 外部通信

2. ネットワークドライバー
   - Bridge
   - Host
   - Overlay
   - Null

3. セキュリティ
   - ネットワークポリシー
   - アクセス制御
   - トラフィック暗号化

## 実際の使い方
ネットワーキングは様々なシーンで活用できます：

1. コンテナ通信
   - マイクロサービス
   - データベース
   - キャッシュ

2. クラスター通信
   - マルチノード
   - マルチクラスタ
   - ハイブリッド

3. 外部通信
   - ロードバランサー
   - APIゲートウェイ
   - サービスメッシュ

## 手を動かしてみよう
基本的なネットワーク設定を説明します：

1. Bridgeネットワーク
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: app
    image: my-app:latest
    ports:
    - containerPort: 8080
  hostNetwork: false
```

2. Hostネットワーク
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: app
    image: my-app:latest
    ports:
    - containerPort: 8080
  hostNetwork: true
```

## 実践的なサンプル
よく使う設定パターンを紹介します：

1. Overlayネットワーク
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
```

2. ネットワークポリシー
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: my-network-policy
spec:
  podSelector:
    matchLabels:
      app: my-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 80
```

## 困ったときは
よくあるトラブルと解決方法を紹介します：

1. 通信ができない
   - ネットワークポリシーを確認
   - サービス設定を確認
   - ファイアウォール設定を確認

2. パフォーマンス問題
   - ネットワークドライバーを確認
   - リソース制限を確認
   - トラフィックパターンを確認

3. セキュリティ問題
   - アクセス制御を確認
   - 暗号化設定を確認
   - 監査ログを確認

## もっと知りたい人へ
次のステップとして以下の学習をお勧めします：

1. 高度なネットワーキング
   - サービスメッシュ
   - マルチクラスタ
   - カスタムCNI

2. セキュリティ強化
   - ネットワークポリシー
   - mTLS
   - アクセス制御

3. モニタリングと分析
   - トラフィック監視
   - パフォーマンス分析
   - セキュリティ監査

## 参考資料
- [Kubernetes公式ドキュメント: ネットワーキング](https://kubernetes.io/docs/concepts/cluster-administration/networking/)
- [Kubernetes公式ドキュメント: ネットワークポリシー](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
