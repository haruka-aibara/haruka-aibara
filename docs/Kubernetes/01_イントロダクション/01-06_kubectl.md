# kubectl コマンド入門

## はじめに
Kubernetesクラスターを操作する際に、こんな悩みはありませんか？
- コマンドが多すぎて覚えられない
- エラーが発生した時の対処方法がわからない
- 効率的な操作方法を知りたい

kubectlは、これらの課題を解決するための強力なツールです。この記事では、kubectlの基本的な使い方から実践的なTipsまで、わかりやすく解説していきます。

## ざっくり理解しよう
kubectlの重要なポイントは以下の3つです：

1. **クラスター操作の中心**
   - Kubernetes APIサーバーとの通信
   - リソースの管理
   - 状態の確認

2. **多機能なコマンド**
   - リソースの作成/更新/削除
   - ログの確認
   - デバッグ機能

3. **柔軟な設定**
   - コンテキストの切り替え
   - プラグインの追加
   - カスタマイズ可能

## 実際の使い方
### よくある使用シーン
1. **日常的な操作**
   - リソースの状態確認
   - ログの確認
   - トラブルシューティング

2. **開発作業**
   - アプリケーションのデプロイ
   - 設定の更新
   - テストの実行

### 実践的なTips
- エイリアスの設定
- プラグインの活用
- 自動補完の有効化

## 手を動かしてみよう
1. **基本的なコマンド**
```bash
# クラスター情報の確認
kubectl cluster-info

# ノードの一覧表示
kubectl get nodes

# Podの一覧表示
kubectl get pods
```

2. **リソースの操作**
```bash
# Podの作成
kubectl run nginx --image=nginx

# サービスの作成
kubectl create service clusterip my-service --tcp=80:80

# デプロイメントのスケール
kubectl scale deployment nginx-deployment --replicas=3
```

## 実践的なサンプル
### 基本的な設定
```bash
# 環境変数の設定
kubectl run nginx --image=nginx --env="DB_HOST=mysql" --env="DB_PORT=3306"

# リソース制限の設定
kubectl run nginx --image=nginx --limits="cpu=200m,memory=256Mi"
```

### よく使う設定パターン
1. **デバッグ用の設定**
```bash
# 詳細なログの確認
kubectl logs -f my-pod

# コンテナ内でのコマンド実行
kubectl exec -it my-pod -- /bin/bash

# イベントの確認
kubectl get events
```

## 困ったときは
### よくあるトラブルと解決方法
1. **接続の問題**
   - クラスターの状態確認: `kubectl cluster-info`
   - 認証情報の確認: `kubectl config view`
   - コンテキストの確認: `kubectl config current-context`

2. **リソースの問題**
   - 詳細な状態確認: `kubectl describe pod my-pod`
   - ログの確認: `kubectl logs my-pod`
   - イベントの確認: `kubectl get events`

### デバッグの手順
1. リソースの状態確認
2. ログの確認
3. イベントの確認
4. 詳細な情報の取得

## もっと知りたい人へ
### 次のステップ
- 高度なコマンドの学習
- プラグインの活用
- 自動化スクリプトの作成

### おすすめの学習リソース
- [Kubernetes公式ドキュメント - kubectl](https://kubernetes.io/docs/reference/kubectl/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [kubectl GitHubリポジトリ](https://github.com/kubernetes/kubectl)

### コミュニティ情報
- Kubernetes Slack (#kubectl)
- Stack Overflow (kubectlタグ)
- GitHub Discussions
