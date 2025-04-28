# Kubernetes講義：機密データ用のSecretsの使用

## 概要と重要性
Kubernetesにおいて、パスワードやトークン、APIキーなどの機密データを安全に管理するためのSecretsは、セキュアなアプリケーション構築に不可欠な要素です。

## Secretsの基本概念
Secretsは、機密性の高いデータをKubernetesクラスター内で安全に保存・管理するためのオブジェクトで、Base64エンコーディングされてetcdに保存されます。

## Secretsの主な特徴

### 作成方法
Secretsは手動または自動的に作成することができます：

```yaml
# 手動作成の例
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
type: Opaque
data:
  username: YWRtaW4=  # Base64エンコードされた "admin"
  password: cGFzc3dvcmQxMjM=  # Base64エンコードされた "password123"
```

コマンドラインからの作成も可能です：

```bash
# リテラル値からSecretを作成
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=password123

# ファイルからSecretを作成
kubectl create secret generic ssl-certificates \
  --from-file=./tls.crt \
  --from-file=./tls.key
```

### Podでの利用方法
Secretsは主に2つの方法でPodに提供されます：

1. **ボリュームとしてマウント**：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app-container
    image: my-app:1.0
    volumeMounts:
    - name: secrets-volume
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secrets-volume
    secret:
      secretName: db-credentials
```

2. **環境変数として設定**：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app-container
    image: my-app:1.0
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: password
```

### アクセス制御
KubernetesのRBAC（Role-Based Access Control）を使用して、Secretsへのアクセスを制限することができます：

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
  resourceNames: ["db-credentials"]
```

### Secretsの制限事項とセキュリティ上の課題
- サイズ制限：1MB以下である必要があります
- 一度作成したSecretのキーを更新することは難しいため、多くの場合、新しいSecretを作成して古いものを削除する方法が採られます
- **重要な注意点**: Secretsはデフォルトでは単にBase64エンコードされているだけであり、これは暗号化ではありません。Base64は誰でも簡単にデコードできるため、本質的にはデータの難読化にすぎません
  ```bash
  # Base64のデコード例
  echo 'cGFzc3dvcmQxMjM=' | base64 --decode
  # 出力: password123
  ```
- デフォルトではSecretはetcdに暗号化されずに保存されるため、追加の暗号化設定が強く推奨されます
- クラスター管理者やetcdにアクセスできる人は、全てのSecretデータを閲覧できる可能性があります

## セキュリティのベストプラクティス
- Secretsへのアクセスを最小権限の原則に基づいて制限する
- **etcdの暗号化を必ず有効にする**：Secretデータの実際の保護には、etcdでの保存時の暗号化が不可欠です
  ```yaml
  # APIサーバー設定の例（kube-apiserver.yaml）
  apiVersion: apiserver.config.k8s.io/v1
  kind: EncryptionConfiguration
  resources:
    - resources:
        - secrets
      providers:
        - aescbc:
            keys:
              - name: key1
                secret: <base64-encoded-key>
        - identity: {}
  ```
- イメージやGitリポジトリにSecretデータを含めない
- 定期的にSecretをローテーションする
- より高度なセキュリティが必要な場合は、HashiCorp VaultやAWS Secrets Managerなどの専用の外部シークレット管理ツールの使用を検討する

## 実際の使用例
データベース接続情報、TLS証明書、OAuthトークンなどの機密情報をKubernetes Secretsとして保存することで、アプリケーションのセキュリティを向上させながら、環境間での移植性を維持することができます。
