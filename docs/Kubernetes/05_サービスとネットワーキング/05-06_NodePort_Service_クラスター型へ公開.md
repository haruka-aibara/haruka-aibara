# Kubernetes: NodePort Service

## はじめに
「クラスター外からアプリケーションにアクセスしたい」「開発環境で簡単にサービスを公開したい」「特定のノードのポートを直接公開したい」そんな悩みはありませんか？KubernetesのNodePort Serviceは、これらの問題を解決し、クラスター外からのアクセスを可能にする重要なリソースです。この記事では、NodePort Serviceの基本概念から実践的な使い方まで、わかりやすく解説します。

## ざっくり理解しよう
NodePort Serviceには、以下の3つの重要なポイントがあります：

1. ポート公開
   - ノードの特定ポートを公開
   - 30000-32767の範囲
   - すべてのノードで同じポート

2. アクセス制御
   - ノードのIPアドレスでアクセス
   - ポート番号による制御
   - ファイアウォール設定

3. 負荷分散
   - ノード間の分散
   - セッションアフィニティ
   - ヘルスチェック

## 実際の使い方
NodePort Serviceは様々なシーンで活用できます：

1. 開発環境
   - ローカルテスト
   - デバッグ
   - プロトタイピング

2. テスト環境
   - 統合テスト
   - 負荷テスト
   - セキュリティテスト

3. 小規模環境
   - スタンドアロン
   - オンプレミス
   - ハイブリッド

## 手を動かしてみよう
基本的なNodePort Serviceの設定を説明します：

1. NodePort Serviceの作成
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
  - port: 80
    targetPort: 8080
    nodePort: 30001
```

2. アプリケーションのデプロイ
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: app
        image: my-app:latest
        ports:
        - containerPort: 8080
```

## 実践的なサンプル
よく使う設定パターンを紹介します：

1. マルチポートNodePort
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
  - name: http
    port: 80
    targetPort: 8080
    nodePort: 30001
  - name: https
    port: 443
    targetPort: 8443
    nodePort: 30002
```

2. セッションアフィニティの設定
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
  - port: 80
    targetPort: 8080
    nodePort: 30001
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
```

## 困ったときは
よくあるトラブルと解決方法を紹介します：

1. ポートが使用できない
   - ポート範囲を確認
   - ポートの競合を確認
   - ファイアウォール設定を確認

2. アクセスできない
   - ノードのIPアドレスを確認
   - ポート番号を確認
   - ネットワーク設定を確認

3. 負荷分散がうまくいかない
   - セッションアフィニティを確認
   - ヘルスチェックを確認
   - スケーリング設定を確認

## もっと知りたい人へ
次のステップとして以下の学習をお勧めします：

1. 高度な公開方法
   - LoadBalancer
   - Ingress
   - API Gateway

2. セキュリティ強化
   - ネットワークポリシー
   - SSL/TLS終端
   - アクセス制御

3. モニタリングと分析
   - トラフィック監視
   - パフォーマンス分析
   - セキュリティ監査

## 参考資料
- [Kubernetes公式ドキュメント: Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Kubernetes公式ドキュメント: NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport)
