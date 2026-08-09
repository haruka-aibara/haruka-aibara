# Kubernetes: Ingress Service

## はじめに
「複数のサービスを効率的に公開したい」「SSL/TLS終端を一元管理したい」「パスベースのルーティングを実現したい」そんな悩みはありませんか？KubernetesのIngress Serviceは、これらの問題を解決し、クラスター外へのサービス公開を柔軟に管理する重要なリソースです。この記事では、Ingress Serviceの基本概念から実践的な使い方まで、わかりやすく解説します。

## ざっくり理解しよう
Ingress Serviceには、以下の3つの重要なポイントがあります：

1. ルーティング
   - パスベースのルーティング
   - ホストベースのルーティング
   - リダイレクトとリライト

2. 負荷分散
   - サービス間の分散
   - セッションアフィニティ
   - ヘルスチェック

3. SSL/TLS
   - 証明書管理
   - 自動更新
   - セキュアな通信

## 実際の使い方
Ingress Serviceは様々なシーンで活用できます：

1. マイクロサービス
   - 複数サービスの統合
   - APIゲートウェイ
   - サービスディスカバリ

2. Webアプリケーション
   - フロントエンド
   - バックエンドAPI
   - 静的コンテンツ

3. マルチテナント
   - サブドメイン管理
   - テナント分離
   - アクセス制御

## 手を動かしてみよう
基本的なIngress Serviceの設定を説明します：

1. Ingressの作成
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
      - path: /web
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

2. サービスの作成
```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-service
spec:
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
```

## 実践的なサンプル
よく使う設定パターンを紹介します：

1. SSL/TLS設定
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: my-tls-secret
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

2. リダイレクト設定
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /old-path(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

## 困ったときは
よくあるトラブルと解決方法を紹介します：

1. ルーティングが機能しない
   - パスの設定を確認
   - ホスト名の設定を確認
   - サービスの設定を確認

2. SSL/TLSエラー
   - 証明書の有効性を確認
   - シークレットの設定を確認
   - アノテーションの設定を確認

3. アクセスできない
   - Ingressコントローラーの状態を確認
   - サービスの状態を確認
   - ネットワークポリシーを確認

## もっと知りたい人へ
次のステップとして以下の学習をお勧めします：

1. 高度なルーティング
   - カスタムルール
   - 認証統合
   - レート制限

2. セキュリティ強化
   - WAF統合
   - アクセス制御
   - 監査ログ

3. モニタリングと分析
   - トラフィック監視
   - パフォーマンス分析
   - エラー追跡

## 参考資料
- [Kubernetes公式ドキュメント: Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Kubernetes公式ドキュメント: Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
