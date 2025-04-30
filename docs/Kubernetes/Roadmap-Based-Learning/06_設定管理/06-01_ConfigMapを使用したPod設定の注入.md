# Kubernetes講義: ConfigMapを使用したPod設定の注入

## 概要
ConfigMapはKubernetesにおいてアプリケーション設定を分離し、環境ごとのデプロイを柔軟に行うための重要なリソースです。

## ConfigMapとは
ConfigMapはアプリケーションの構成情報をコンテナイメージから分離して管理するためのKubernetesリソースで、環境変数、コマンドライン引数、設定ファイルなどの形で Pod に設定データを提供します。

## ConfigMapの基本概念

### なぜConfigMapを使うのか
- コードと設定の分離
- 環境ごとに異なる設定値の管理
- 構成変更時のイメージ再構築不要
- 設定データの一元管理

### ConfigMapの作成方法

1. **コマンドラインから直接作成**:
```bash
# キーと値のペアから作成
kubectl create configmap app-config --from-literal=DB_HOST=mysql --from-literal=DB_PORT=3306

# ファイルから作成
kubectl create configmap app-config --from-file=config.properties

# ディレクトリから作成
kubectl create configmap app-config --from-file=config-dir/
```

2. **YAMLマニフェストから作成**:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DB_HOST: mysql
  DB_PORT: "3306"
  config.properties: |
    app.name=MyApp
    app.description=サンプルアプリケーション
```

### ConfigMapのPodへの注入方法

1. **環境変数として使用**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app-container
    image: myapp:1.0
    env:
    - name: DATABASE_HOST  # コンテナ内の環境変数名
      valueFrom:
        configMapKeyRef:
          name: app-config  # ConfigMap名
          key: DB_HOST      # ConfigMap内のキー
    - name: DATABASE_PORT
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: DB_PORT
```

2. **環境変数としてすべてのキーを一括で使用**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app-container
    image: myapp:1.0
    envFrom:
    - configMapRef:
        name: app-config  # ConfigMap名
```

3. **ボリュームマウントとして使用**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app-container
    image: myapp:1.0
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config  # コンテナ内のマウントパス
  volumes:
  - name: config-volume
    configMap:
      name: app-config  # ConfigMap名
```

上記の例では、ConfigMapのデータが `/etc/config` ディレクトリ内のファイルとして配置されます。各キーがファイル名になり、値がファイルの内容になります。

4. **特定のキーのみをファイルとしてマウント**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app-container
    image: myapp:1.0
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config/app.properties  # 特定のファイルとしてマウント
      subPath: config.properties             # ConfigMapのキー
  volumes:
  - name: config-volume
    configMap:
      name: app-config
      items:
      - key: config.properties
        path: config.properties
```

### ConfigMapの更新と反映

- 環境変数として利用している場合は、Podの再起動が必要
- ボリュームマウントとして利用している場合は、自動的に更新される（遅延あり）
- ボリューム更新の遅延時間は数秒〜数分（デフォルトは約1分）

### ConfigMapの制限事項

- バイナリデータには向かない（Secret リソースを使用）
- サイズ制限: 1MB以下を推奨
- 機密情報（パスワード、APIキーなど）の保存には不適切（代わりにSecretを使用）

### ConfigMapのベストプラクティス

- 環境ごとに異なるConfigMapを使い分ける
- 設定変更の履歴を管理するためGitでバージョン管理する
- アプリケーションの機能別にConfigMapを分割する
- デフォルト値をアプリケーション内に持ち、ConfigMapが存在しない場合のフォールバック処理を実装する

## まとめ

ConfigMapを使用することで、アプリケーションコードから設定を分離し、環境ごとに異なる設定を簡単に管理できるようになります。環境変数やファイルとしてPodに注入することができ、柔軟なアプリケーション設定管理を実現します。
