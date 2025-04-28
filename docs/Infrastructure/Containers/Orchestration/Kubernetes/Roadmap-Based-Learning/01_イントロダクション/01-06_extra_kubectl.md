# kubectl コマンド入門

## 概要
kubectlはKubernetesクラスターを操作するための主要なコマンドラインツールで、リソースの作成・表示・更新・削除などの操作を行います。

## 基本的な理解
kubectlはKubernetes APIサーバーと通信し、JSONやYAMLで定義されたオブジェクトを操作することで、コンテナの実行環境を制御します。

## 重要なコマンド

### kubectl run
新しいPodを作成して実行します。

```bash
# 基本的な使い方
kubectl run nginx --image=nginx

# ラベルを指定して実行
kubectl run nginx --image=nginx --labels="app=web"

# 特定のポートを公開
kubectl run nginx --image=nginx --port=80
```

### kubectl run --env
環境変数を設定してPodを実行します。

```bash
# 単一の環境変数を設定
kubectl run nginx --image=nginx --env="DB_HOST=mysql"

# 複数の環境変数を設定
kubectl run nginx --image=nginx --env="DB_HOST=mysql" --env="DB_PORT=3306"
```

### kubectl get pods
クラスター内のPodを一覧表示します。

```bash
# すべてのPodを表示
kubectl get pods

# 詳細情報を表示
kubectl get pods -o wide

# 特定の名前空間のPodを表示
kubectl get pods -n kube-system

# 特定のラベルを持つPodを表示
kubectl get pods -l app=nginx

# YAML形式で出力
kubectl get pods nginx -o yaml
```

### kubectl logs
Pod内のコンテナのログを表示します。

```bash
# 基本的な使い方
kubectl logs my-pod

# リアルタイムでログを表示（tail -f相当）
kubectl logs -f my-pod

# 直近の20行を表示
kubectl logs --tail=20 my-pod

# 複数コンテナがあるPodで特定のコンテナのログを表示
kubectl logs my-pod -c my-container
```

### kubectl describe pod
Pod の詳細情報を表示します。

```bash
# 基本的な使い方
kubectl describe pod my-pod

# ラベルセレクタを使用して特定のPodを表示
kubectl describe pod -l app=nginx
```

表示される情報には以下が含まれます：
- Pod の基本情報（名前、ネームスペース、ノード等）
- Pod の状態とIPアドレス
- コンテナの情報（イメージ、ポート、環境変数）
- イベント履歴（スケジューリング、起動など）

### kubectl exec
実行中のPod内でコマンドを実行します。

```bash
# 単一のコマンドを実行
kubectl exec my-pod -- ls -la

# 対話式シェルを実行
kubectl exec -it my-pod -- /bin/bash

# 複数コンテナがあるPodで特定のコンテナに対して実行
kubectl exec -it my-pod -c my-container -- /bin/bash
```

## よくあるエラーとトラブルシューティング

### Pod が起動しない場合
```bash
# Podの状態を確認
kubectl get pod my-pod

# 詳細情報を確認
kubectl describe pod my-pod

# ログを確認
kubectl logs my-pod
```

### コマンド実行時の権限エラー
権限が不足している場合は、適切なRBACポリシーが設定されているか確認してください。

### コンテキストの確認
```bash
# 現在のコンテキストを確認
kubectl config current-context

# 利用可能なコンテキストを一覧表示
kubectl config get-contexts
```
