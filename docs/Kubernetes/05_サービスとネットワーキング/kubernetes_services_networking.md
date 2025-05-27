---
marp: true
theme: default
paginate: true
style: |
  section {
    font-family: "Meiryo", "Noto Sans JP", "Hiragino Sans", "Hiragino Kaku Gothic ProN", sans-serif;
    color: #333;
    padding: 45px 35px 35px 35px;
    position: relative;
  }

  .header-bar {
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 48px;
    background: #444;
    color: #fff;
    font-size: 1.1em;
    font-weight: bold;
    line-height: 48px;
    padding-left: 28px;
    letter-spacing: 0.08em;
    z-index: 10;
    box-sizing: border-box;
  }

  h1, h2 {
    font-weight: 700;
    letter-spacing: 0.01em;
    margin-bottom: 0.25em;
  }

  h1 {
    font-size: 1.6em;
    color: #333;
    border-bottom: 1px solid #1976d2;
    padding-bottom: 0.1em;
    margin-bottom: 0.4em;
  }

  h2 {
    font-size: 1.3em;
    color: #1976d2;
  }

  h3, h4 {
    font-weight: 600;
    color: #555;
    margin-top: 0.8em;
  }

  p, li {
    font-size: 0.9em;
    line-height: 1.4;
  }

  ul, ol {
    margin-left: 0.8em;
  }

  li {
    margin-bottom: 0.2em;
  }

  code, pre {
    background: #f5f5f5;
    color: #1976d2;
    border-radius: 3px;
    padding: 0.15em 0.3em;
    font-size: 0.75em;
    line-height: 1.2;
  }

  pre, code {
    font-size: 0.65em !important;
    line-height: 1.3 !important;
  }

  blockquote {
    border-left: 1px solid #1976d2;
    background: #f0f7fa;
    color: #333;
    padding: 0.4em 0.6em;
    margin: 0.6em 0;
  }

  footer, .footer {
    color: #888;
    font-size: 0.7em;
    text-align: center;
    margin-top: 1em;
  }

  a {
    color: #1976d2;
    text-decoration: underline;
  }

  .columns {
    display: flex;
    gap: 1em;
  }
  .columns > div {
    flex: 1;
  }

  hr {
    border: none;
    border-top: 1px solid #eee;
    margin: 1em 0;
  }

  /* アクセントカラー */
  .accent {
    color: #e53935;
    font-weight: bold;
  }

  /* サブカラー */
  .sub {
    color: #90caf9;
  }

  /* ページ番号のカスタマイズ */
  section::after {
    content: attr(data-marpit-pagination);
    position: absolute;
    right: 1em;
    bottom: 0.8em;
    color: #888;
    font-size: 0.75em;
  }

  /* 図表のスタイル */
  .diagram {
    background: #fff;
    border: 1px solid #ddd;
    border-radius: 4px;
    padding: 1em;
    margin: 1em 0;
  }

  .note {
    background: #fff3cd;
    border-left: 4px solid #ffc107;
    padding: 0.5em 1em;
    margin: 0.5em 0;
    font-size: 0.85em;
  }

  .warning {
    background: #f8d7da;
    border-left: 4px solid #dc3545;
    padding: 0.5em 1em;
    margin: 0.5em 0;
    font-size: 0.85em;
  }

  .info {
    background: #d1ecf1;
    border-left: 4px solid #17a2b8;
    padding: 0.5em 1em;
    margin: 0.5em 0;
    font-size: 0.85em;
  }

  pre {
    margin: 0.5em 0;
    padding: 0.5em;
    white-space: pre-wrap;
    word-wrap: break-word;
  }

  img {
    max-width: 100%;
    max-height: 300px;
    object-fit: contain;
  }

  .image-source {
    font-size: 0.7em;
    color: #666;
    text-align: right;
    margin-top: 0.2em;
  }

  .code-container {
    background: #f5f5f5;
    border-radius: 3px;
    padding: 0.5em;
    margin: 0.5em 0;
  }
---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# Kubernetes サービスとネットワーキング
## クラスター内の通信と外部公開

![width:300px](https://kubernetes.io/images/docs/services-iptables-overview.svg)

<div class="image-source">
出典: Kubernetes公式ドキュメント - Services, Load Balancing, and Networking
</div>

---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# Serviceとは

- Podへの安定したアクセスを提供する抽象化レイヤー
- PodのIPアドレスは動的に変更されるため、直接アクセスは非推奨
- Serviceは固定のIPアドレスとDNS名を提供

<div class="note">
💡 **重要**: ServiceはPodの集合に対する論理的なエンドポイントを提供します
</div>

---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# Serviceの基本概念

![width:500px](https://kubernetes.io/images/docs/services-iptables-overview.svg)

<div class="image-source">
出典: Kubernetes公式ドキュメント - Services, Load Balancing, and Networking
</div>

- ServiceはPodの集合に対する論理的なエンドポイント
- kube-proxyがiptablesルールを管理
- クラスター内DNSによる名前解決

---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# Serviceの種類 (1/2)

## 1. ClusterIP (デフォルト)
- クラスター内部からのみアクセス可能
- 内部サービス間の通信に使用

## 2. NodePort
- クラスター外からノードのIP:ポートでアクセス可能
- 開発・テスト環境で使用

---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# Serviceの種類 (2/2)

## 3. LoadBalancer
- クラウドプロバイダーのロードバランサーを使用
- 本番環境での外部公開に使用

## 4. ExternalName
- 外部サービスへのDNSエイリアスを提供

![width:400px](https://kubernetes.io/images/docs/services-overview.svg)

<div class="image-source">
出典: Kubernetes公式ドキュメント - Services, Load Balancing, and Networking
</div>

---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# ClusterIP Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: my-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: ClusterIP
```

<div class="info">
📝 **特徴**:
- クラスター内部でのみアクセス可能
- 自動的にクラスター内DNSに登録
- 例: `my-service.default.svc.cluster.local`
</div>

---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# ClusterIP Serviceの動作

![width:400px](https://kubernetes.io/images/docs/services-iptables-overview.svg)

<div class="image-source">
出典: Kubernetes公式ドキュメント - Services, Load Balancing, and Networking
</div>

- kube-proxyがiptablesルールを管理
- ラウンドロビンによる負荷分散
- クラスター内DNSによる名前解決

---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# NodePort Service

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
      nodePort: 30000
```

<div class="warning">
⚠️ **注意点**:
- ポート範囲: 30000-32767
- セキュリティ考慮が必要
- 本番環境ではLoadBalancerの使用を推奨
</div>

---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# NodePort Serviceの動作

![width:400px](https://kubernetes.io/images/docs/services-nodeport.svg)

<div class="image-source">
出典: Kubernetes公式ドキュメント - Services, Load Balancing, and Networking
</div>

- すべてのノードの指定ポートでアクセス可能
- ノード間での負荷分散
- クラスター外からのアクセスに使用

---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# LoadBalancer Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: LoadBalancer
  selector:
    app: my-app
  ports:
    - port: 80
      targetPort: 8080
```

<div class="info">
💡 **利点**:
- クラウドプロバイダーのロードバランサーを自動プロビジョニング
- 外部からのアクセスを複数ノードに分散
- 本番環境での推奨方式
</div>

---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# LoadBalancer Serviceの動作

![width:400px](https://kubernetes.io/images/docs/services-loadbalancer.svg)

<div class="image-source">
出典: Kubernetes公式ドキュメント - Services, Load Balancing, and Networking
</div>

- クラウドプロバイダーのロードバランサーを使用
- 外部からのアクセスを複数ノードに分散
- 高可用性とスケーラビリティを提供

---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# Ingress (1/2)

- HTTP/HTTPSトラフィックのルーティングを管理
- ホスト名やパスベースのルーティング
- SSL/TLS終端
- ロードバランシング

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```

---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# Ingress (2/2)

![width:400px](https://kubernetes.io/images/docs/ingress.svg)

<div class="image-source">
出典: Kubernetes公式ドキュメント - Services, Load Balancing, and Networking
</div>

- 複数のServiceを単一のエンドポイントで公開
- パスベースのルーティング
- SSL/TLS終端
- ロードバランシング

---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# ネットワークポリシー (1/2)

- Pod間の通信を制御
- 名前空間レベルでの分離
- セキュリティポリシーの実装

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
```

---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# ネットワークポリシー (2/2)

![width:400px](https://kubernetes.io/images/docs/network-policy.svg)

<div class="image-source">
出典: Kubernetes公式ドキュメント - Services, Load Balancing, and Networking
</div>

- Pod間の通信を制御
- 名前空間レベルでの分離
- セキュリティポリシーの実装
- マイクロサービス間の通信制御

---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# 実践的な使用例 (1/2)

## マイクロサービス構成
- フロントエンド → API → データベース
- 各層で適切なServiceタイプを選択
- セキュリティ考慮した通信制御

![width:300px](https://kubernetes.io/images/docs/services-iptables-overview.svg)

<div class="image-source">
出典: Kubernetes公式ドキュメント - Services, Load Balancing, and Networking
</div>

---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# 実践的な使用例 (2/2)

## ベストプラクティス
- 最小権限の原則
- 適切なServiceタイプの選択
- ネットワークポリシーの活用
- モニタリングとロギング

<div class="note">
💡 **推奨事項**:
- 本番環境ではLoadBalancer + Ingress
- 内部サービスはClusterIP
- ネットワークポリシーで通信制限
</div>

---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# まとめ

- ServiceはPodへの安定したアクセスを提供
- 用途に応じて適切なServiceタイプを選択
- Ingressによる柔軟なルーティング
- ネットワークポリシーによるセキュリティ制御
- 実運用ではモニタリングと管理が重要

<div class="info">
📚 **参考資料**:
- [Kubernetes公式ドキュメント](https://kubernetes.io/docs/concepts/services-networking/)
- [Kubernetes Service Types](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)
- [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
</div>

---
<div class="header-bar">Kubernetes サービスとネットワーキング</div>

# ご清聴ありがとうございました

- 質問はありますか？
- より詳しい情報は公式ドキュメントを参照してください

<div class="note">
💡 **次のステップ**:
- 実際のクラスターでServiceを作成
- 異なるServiceタイプの動作確認
- Ingressコントローラーの設定
- ネットワークポリシーの実装
</div>
