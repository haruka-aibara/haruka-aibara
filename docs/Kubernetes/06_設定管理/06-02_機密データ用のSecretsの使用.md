# Kubernetes: Secrets

## はじめに
「パスワードやAPIキーなどの機密情報を安全に管理したい」「機密データを暗号化して保存したい」「アクセス制御を厳密に行いたい」そんな悩みはありませんか？KubernetesのSecretsは、これらの問題を解決し、機密データを安全に管理する重要なリソースです。この記事では、Secretsの基本概念から実践的な使い方まで、わかりやすく解説します。

## ざっくり理解しよう
Secretsには、以下の3つの重要なポイントがあります：

1. 機密データ管理
   - パスワード
   - APIキー
   - 証明書

2. セキュリティ
   - 暗号化
   - アクセス制御
   - 監査ログ

3. 柔軟な注入
   - 環境変数として
   - ボリュームとして
   - イメージプルシークレットとして

## 実際の使い方
Secretsは様々なシーンで活用できます：

1. 認証情報
   - データベース認証
   - API認証
   - サービスアカウント

2. 証明書管理
   - SSL/TLS証明書
   - クライアント証明書
   - 署名証明書

3. トークン管理
   - アクセストークン
   - リフレッシュトークン
   - セッショントークン

## 手を動かしてみよう
基本的なSecretsの設定を説明します：

1. Secretの作成
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
data:
  username: dXNlcg==  # base64エンコードされた "user"
  password: cGFzc3dvcmQ=  # base64エンコードされた "password"
```

2. Podでの使用
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: app
    image: my-app:latest
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: my-secret
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: my-secret
          key: password
```

## 実践的なサンプル
よく使う設定パターンを紹介します：

1. TLS証明書の管理
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
type: kubernetes.io/tls
data:
  tls.crt: |
    -----BEGIN CERTIFICATE-----
    ...
    -----END CERTIFICATE-----
  tls.key: |
    -----BEGIN PRIVATE KEY-----
    ...
    -----END PRIVATE KEY-----
---
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: app
    image: my-app:latest
    volumeMounts:
    - name: tls-volume
      mountPath: /etc/tls
  volumes:
  - name: tls-volume
    secret:
      secretName: tls-secret
```

2. Dockerレジストリ認証
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: docker-registry-secret
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: |
    {
      "auths": {
        "registry.example.com": {
          "username": "user",
          "password": "password",
          "auth": "dXNlcjpwYXNzd29yZA=="
        }
      }
    }
---
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: app
    image: registry.example.com/my-app:latest
  imagePullSecrets:
  - name: docker-registry-secret
```

## 困ったときは
よくあるトラブルと解決方法を紹介します：

1. アクセスできない
   - Secretの存在を確認
   - アクセス権限を確認
   - マウントパスを確認

2. 更新が反映されない
   - 更新方法を確認
   - キャッシュを確認
   - 再起動の必要性を確認

3. セキュリティ問題
   - 暗号化設定を確認
   - アクセス制御を確認
   - 監査ログを確認

## もっと知りたい人へ
次のステップとして以下の学習をお勧めします：

1. 高度なセキュリティ
   - 外部シークレット管理
   - 暗号化プロバイダー
   - キー管理

2. 運用管理
   - シークレットのローテーション
   - バックアップと復元
   - 監査とコンプライアンス

3. 統合
   - クラウドプロバイダー
   - 認証システム
   - 監視システム

## 参考資料
- [Kubernetes公式ドキュメント: Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Kubernetes公式ドキュメント: シークレットの管理](https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/)
