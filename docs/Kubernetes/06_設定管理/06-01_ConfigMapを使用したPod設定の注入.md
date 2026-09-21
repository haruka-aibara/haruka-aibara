# Kubernetes: ConfigMap

## はじめに
「アプリケーションの設定を柔軟に管理したい」「環境ごとに異なる設定を使い分けたい」「設定変更を再デプロイせずに反映したい」そんな悩みはありませんか？KubernetesのConfigMapは、これらの問題を解決し、アプリケーションの設定を効率的に管理する重要なリソースです。この記事では、ConfigMapの基本概念から実践的な使い方まで、わかりやすく解説します。

## ざっくり理解しよう
ConfigMapには、以下の3つの重要なポイントがあります：

1. 設定管理
   - キーと値のペア
   - 環境変数
   - 設定ファイル

2. 柔軟な注入
   - 環境変数として
   - ボリュームとして
   - コマンドライン引数として

3. 動的更新
   - 設定の変更
   - 再起動なしの更新
   - バージョン管理

## 実際の使い方
ConfigMapは様々なシーンで活用できます：

1. アプリケーション設定
   - データベース接続
   - APIエンドポイント
   - 機能フラグ

2. 環境設定
   - 開発環境
   - テスト環境
   - 本番環境

3. システム設定
   - ログレベル
   - キャッシュ設定
   - セキュリティ設定

## 手を動かしてみよう
基本的なConfigMapの設定を説明します：

1. ConfigMapの作成
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  database_url: "postgresql://user:pass@localhost:5432/mydb"
  api_endpoint: "https://api.example.com"
  log_level: "info"
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
    envFrom:
    - configMapRef:
        name: my-config
```

## 実践的なサンプル
よく使う設定パターンを紹介します：

1. 設定ファイルの注入
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  config.json: |
    {
      "database": {
        "host": "localhost",
        "port": 5432
      },
      "api": {
        "endpoint": "https://api.example.com",
        "timeout": 30
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
    image: my-app:latest
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: my-config
```

2. 環境変数の個別指定
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
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: my-config
          key: database_url
    - name: API_ENDPOINT
      valueFrom:
        configMapKeyRef:
          name: my-config
          key: api_endpoint
```

## 困ったときは
よくあるトラブルと解決方法を紹介します：

1. 設定が反映されない
   - ConfigMapの存在を確認
   - マウントパスを確認
   - 環境変数名を確認

2. 更新が反映されない
   - 更新方法を確認
   - キャッシュを確認
   - 再起動の必要性を確認

3. セキュリティ問題
   - 機密情報の扱いを確認
   - アクセス制御を確認
   - 暗号化の必要性を確認

## もっと知りたい人へ
次のステップとして以下の学習をお勧めします：

1. 高度な設定管理
   - 設定のバージョン管理
   - 設定の検証
   - 設定の監査

2. セキュリティ強化
   - Secretsの使用
   - 暗号化
   - アクセス制御

3. 運用管理
   - 設定の監視
   - 変更管理
   - バックアップ

## 参考資料
- [Kubernetes公式ドキュメント: ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Kubernetes公式ドキュメント: 設定の管理](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
