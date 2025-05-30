# Kubernetes Ingress

## 概要
Kubernetesにおいて外部からのHTTP/HTTPSトラフィックをクラスター内のサービスにルーティングするためのリソース。

## 理論的説明
Ingressはクラスター外部からのリクエストをクラスター内の複数のサービスに対してパス/ホストベースのルーティングルールを適用し、トラフィックを効率的に分配する仕組み。

## Ingressの主な機能

### パスベースのルーティング
- 同じホスト名に対して異なるパスごとに別のサービスにルーティング可能
- 例: example.com/app1 → app1サービス、example.com/app2 → app2サービス

### ホストベースのルーティング
- 異なるホスト名に基づいて別々のサービスにルーティング可能
- 例: app1.example.com → app1サービス、app2.example.com → app2サービス

### TLS/SSL終端
- HTTPSトラフィックの暗号化/復号化をIngressレベルで処理
- 証明書の一元管理が可能

## Ingress Controller

Ingressリソースを実際に機能させるためには、Ingress Controllerのデプロイが必須です。
代表的なIngress Controllerには以下があります：

- Nginx Ingress Controller（最も広く使われている）
- Traefik
- HAProxy
- Kong
- Istio Ingress

## 基本的なIngressマニフェスト例

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
```

## アノテーション

Ingressの振る舞いをカスタマイズするためのアノテーション例：

- `nginx.ingress.kubernetes.io/rewrite-target`: パスの書き換え
- `nginx.ingress.kubernetes.io/ssl-redirect`: HTTPSリダイレクトの設定
- `nginx.ingress.kubernetes.io/proxy-body-size`: ボディサイズの制限
- `nginx.ingress.kubernetes.io/proxy-connect-timeout`: タイムアウト設定

## TLS設定例

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-example-ingress
spec:
  tls:
  - hosts:
      - app.example.com
    secretName: example-tls-secret
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 80
```

## Ingressの利点

- 複数サービスへの単一エントリポイント提供
- URLベースのルーティング
- SSL/TLS終端の一元管理
- ロードバランシング
- 名前ベースの仮想ホスティング

## 注意点

- Ingress単体では機能せず、Ingress Controllerが必要
- Ingress Controllerの種類によって使用できるアノテーションが異なる
- クラウドプロバイダによって実装が異なる場合がある
