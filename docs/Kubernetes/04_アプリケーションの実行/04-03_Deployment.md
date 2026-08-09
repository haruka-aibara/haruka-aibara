# Kubernetes: Deployment

## はじめに
「アプリケーションの更新時にダウンタイムが発生する」「更新失敗時のロールバックが大変」「手動での更新作業が煩雑」そんな悩みはありませんか？KubernetesのDeploymentは、これらの問題を解決し、アプリケーションのデプロイと更新を効率的に管理するための中心的なリソースです。この記事では、Deploymentの基本概念から実践的な使い方まで、わかりやすく解説します。

## ざっくり理解しよう
Deploymentは、アプリケーションのデプロイと更新を管理するコントローラーです。以下の3つの重要なポイントを押さえましょう：

1. 無停止更新
   - ローリングアップデートによる更新
   - ダウンタイムの最小化
   - 段階的な更新

2. ロールバック機能
   - 更新失敗時の自動ロールバック
   - 以前のバージョンへの復帰
   - 更新履歴の管理

3. スケーリング
   - レプリカ数の動的な変更
   - 負荷に応じた自動スケーリング
   - リソースの効率的な利用

## 実際の使い方
Deploymentは様々なシーンで活用できます：

1. アプリケーションのデプロイ
   - 新規アプリケーションのデプロイ
   - バージョンアップデート
   - 設定変更の反映

2. スケーリング
   - トラフィック増加時のスケールアウト
   - リソース節約のためのスケールイン
   - 自動スケーリング

3. 更新管理
   - ローリングアップデート
   - カナリアリリース
   - ブルー/グリーンデプロイ

## 手を動かしてみよう
基本的なDeploymentの作成手順を説明します：

1. Deploymentの定義ファイルを作成
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
          requests:
            memory: "64Mi"
            cpu: "250m"
```

2. Deploymentの作成と確認
```bash
kubectl apply -f deployment.yaml
kubectl get deployments
kubectl describe deployment nginx-deployment
```

## 実践的なサンプル
よく使う設定パターンを紹介します：

1. 更新戦略の設定
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: strategy-deployment
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
```

2. ヘルスチェックの設定
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: healthcheck-deployment
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: nginx
        image: nginx
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 20
```

## 困ったときは
よくあるトラブルと解決方法を紹介します：

1. 更新が失敗する
   - イメージ名やタグを確認
   - リソース制限を確認
   - ヘルスチェックの設定を確認

2. ロールバックがうまくいかない
   - リビジョン履歴を確認
   - ロールバック戦略を確認
   - イベントログを確認

3. スケーリングの問題
   - リソース制限を確認
   - ノードのリソースを確認
   - スケーリングポリシーを確認

## もっと知りたい人へ
次のステップとして以下の学習をお勧めします：

1. 高度な更新戦略
   - カナリアリリース
   - ブルー/グリーンデプロイ
   - フェーズドロールアウト

2. オートスケーリング
   - HorizontalPodAutoscaler
   - メトリクスベースのスケーリング
   - カスタムメトリクス

3. 監視とロギング
   - Prometheus
   - Grafana
   - ELK Stack

## 参考資料
- [Kubernetes公式ドキュメント: Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Kubernetes Best Practices: Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#updating-a-deployment)

## Deploymentの主な特徴

### 1. レプリカ管理
- 指定した数のPodレプリカを維持
- スケーリング（水平スケーリング）機能を提供
- Pod障害時の自動再起動

### 2. 更新戦略
- **ローリングアップデート**: デフォルトの更新戦略で、古いPodを徐々に新しいPodに置き換える
- **Recreate**: 全ての古いPodを削除してから新しいPodを作成する方法

### 3. ロールバック機能
- 問題があった場合に以前のバージョンに戻せる
- リビジョン履歴の管理

### 4. Deployment Statusの管理
- 進行中・完了・失敗などのステータス監視
- 更新の進捗確認や問題の特定

## フィールドの説明

### 1. metadata
- **name**: Deploymentの名前
- **labels**: Deploymentを識別するためのラベル

### 2. spec
- **replicas**: 作成・維持するPodの数
- **selector**: どのPodがこのDeploymentに属するかを定義するラベルセレクタ
- **strategy**: 更新戦略を指定
  - **type**: `RollingUpdate`または`Recreate`
  - **rollingUpdate**: ローリングアップデートのパラメータ
    - **maxSurge**: 指定したreplicas数を超えて作成できる新しいPodの最大数（絶対値または割合）
    - **maxUnavailable**: 更新中に利用不可になっても良いPodの最大数（絶対値または割合）
- **template**: 作成するPodのテンプレート（Pod定義と同じ構造）

## よく使うコマンド

### Deploymentの作成
```bash
kubectl apply -f deployment.yaml
```

### Deploymentの一覧表示
```bash
kubectl get deployments
```

### Deploymentの詳細表示
```bash
kubectl describe deployment <deployment-name>
```

### スケーリング
```bash
kubectl scale deployment <deployment-name> --replicas=5
```

### イメージ更新
```bash
kubectl set image deployment/<deployment-name> <container-name>=<new-image>
```

### ロールバック
```bash
kubectl rollout undo deployment/<deployment-name>
```

### 更新履歴の確認
```bash
kubectl rollout history deployment/<deployment-name>
```

### 更新状況の確認
```bash
kubectl rollout status deployment/<deployment-name>
```

## Deploymentの利用シナリオ

1. **アプリケーションの無停止更新**
   - 新バージョンへのローリングアップデート
   - 問題発生時の迅速なロールバック

2. **スケーリング**
   - トラフィック増加時の水平スケールアウト
   - リソース節約のためのスケールイン

3. **自己回復**
   - Pod障害時の自動再起動
   - ノード障害時の別ノードでのPod再作成

## Deploymentと他のリソースの関係

- **ReplicaSet**: Deploymentは内部的にReplicaSetを作成してPodのレプリカを管理
- **Pod**: ReplicaSetを通じて間接的にPodを管理
- **Service**: Deploymentが管理するPodにアクセスするためのエンドポイントを提供

## ベストプラクティス

1. **リソース制限の設定**
   - CPU/メモリの`requests`と`limits`を常に指定

2. **ヘルスチェックの設定**
   - `livenessProbe`と`readinessProbe`の適切な設定

3. **更新戦略の最適化**
   - アプリケーションに適した`maxSurge`と`maxUnavailable`の設定

4. **ラベルの適切な使用**
   - 管理しやすい一貫性のあるラベル付け

5. **アノテーションの活用**
   - 更新履歴や理由を記録するためのアノテーション追加

6. **namespace分離**
   - 環境やチームごとの適切なnamespace利用
