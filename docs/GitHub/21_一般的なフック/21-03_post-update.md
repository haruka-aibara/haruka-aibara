# post-updateフック

## はじめに
post-updateフックは、リポジトリが更新された後に実行されるサーバーサイドのフックです。主にデプロイメントの自動化や通知の送信などに使用されます。

## ざっくり理解しよう
1. **実行タイミング**
   - リポジトリの更新後
   - すべての参照の更新後
   - サーバーサイドでのみ実行

2. **主な用途**
   - デプロイメントの自動化
   - 通知の送信
   - バックアップの作成

3. **特徴**
   - 引数として更新された参照のリストを受け取る
   - 非同期で実行可能
   - エラーが発生しても更新は完了

## 実際の使い方
### よくある使用シーン
1. **デプロイメントの自動化**
   - 本番環境への自動デプロイ
   - ステージング環境の更新
   - ビルドプロセスの実行

2. **通知システム**
   - チームへの通知
   - チャットツールへの通知
   - メール通知

3. **バックアップとログ**
   - 自動バックアップ
   - 更新ログの記録
   - 監査ログの作成

## 手を動かしてみよう
### 基本的な設定
```bash
# post-updateフックの作成
cat > hooks/post-update << 'EOF'
#!/bin/sh
echo "リポジトリが更新されました"
# ここに処理を記述
EOF
chmod +x hooks/post-update
```

## 実践的なサンプル
### デプロイメントスクリプト
```bash
#!/bin/sh
# post-updateフックの例

# 更新された参照を表示
echo "更新された参照:"
for ref in "$@"; do
    echo "- $ref"
done

# mainブランチの更新時のみデプロイ
if echo "$@" | grep -q "refs/heads/main"; then
    echo "mainブランチが更新されました。デプロイを開始します..."
    
    # デプロイディレクトリに移動
    cd /path/to/deploy
    
    # 最新のコードを取得
    git pull origin main
    
    # ビルドプロセスの実行
    npm install
    npm run build
    
    # デプロイの完了通知
    echo "デプロイが完了しました"
fi
```

### 通知スクリプト
```bash
#!/bin/sh
# 通知用のpost-updateフック

# Slackへの通知
curl -X POST -H 'Content-type: application/json' \
    --data '{"text":"リポジトリが更新されました"}' \
    https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# メール通知
echo "リポジトリが更新されました" | mail -s "Git更新通知" team@example.com
```

## 困ったときは
### よくあるトラブル
1. **スクリプトが実行されない**
   - 実行権限の確認
   - パスの確認
   - シェバンの確認

2. **デプロイメントの失敗**
   - ログの確認
   - 権限の確認
   - 環境変数の確認

3. **通知が送信されない**
   - ネットワーク接続の確認
   - APIキーの確認
   - エラーログの確認

## もっと知りたい人へ
### 次のステップ
- 高度なデプロイメントスクリプトの作成
- 監視システムとの連携
- セキュリティの強化

### おすすめの学習リソース
- [Git公式ドキュメント](https://git-scm.com/docs/githooks)
- [GitHub Actions](https://docs.github.com/ja/actions)
- [GitLab CI/CD](https://docs.gitlab.com/ee/ci/)
