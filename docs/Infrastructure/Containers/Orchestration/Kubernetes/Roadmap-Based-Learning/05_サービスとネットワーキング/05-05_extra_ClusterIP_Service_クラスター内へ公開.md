# Kubernetes ClusterIP Service

## 概要と重要性
ClusterIP Serviceは、Kubernetesクラスター内のアプリケーション間通信を実現する基本的なサービスタイプです。

## 主要概念の説明
ClusterIP Serviceは、指定したPodのグループに対して安定した内部IPアドレスとDNS名を提供し、クラスター内からのみアクセス可能です。

## ClusterIP Serviceの詳細

### 基本的な特徴
- クラスター内部でのみ利用可能
- 静的なIPアドレスを提供
- サービス名によるDNS解決が可能
- ロードバランシング機能内蔵

### 使用シナリオ
- マイクロサービス間の通信
- バックエンドサービスのアクセス
- フロントエンドからバックエンドへのリクエスト

### ClusterIP ServiceのYAML定義例

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    - protocol: TCP
      port: 80        # サービスが公開するポート
      targetPort: 9376 # Podのターゲットポート
  type: ClusterIP      # デフォルトはClusterIP
```

### アクセス方法
1. サービス名によるアクセス: `my-service`
2. FQDN (完全修飾ドメイン名)によるアクセス: `my-service.default.svc.cluster.local`
3. ClusterIPによるアクセス: `<自動割り当てられたIP>`

### 注意点
- 外部からアクセスできないため、デバッグには追加の手段が必要
- `kubectl port-forward`を使用して一時的に外部からアクセス可能
- デフォルトのServiceタイプなので、`type: ClusterIP`は省略可能

### コマンド例

サービスの作成:
```bash
kubectl apply -f service.yaml
```

サービスの確認:
```bash
kubectl get services
```

特定サービスの詳細表示:
```bash
kubectl describe service my-service
```

### セッションアフィニティ
```yaml
spec:
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
```
