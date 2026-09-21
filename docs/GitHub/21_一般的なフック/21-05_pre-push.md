# pre-pushフック

## はじめに
pre-pushフックは、リモートリポジトリへのプッシュが行われる直前に実行されるクライアントサイドのフックです。プッシュ前に最終的なチェックを行い、品質の高いコードをリモートリポジトリに反映させることができます。

## ざっくり理解しよう
1. **実行タイミング**
   - プッシュ直前
   - リモートへの送信前
   - ローカル環境で実行

2. **主な用途**
   - 最終的なコードチェック
   - テストの再実行
   - プッシュの検証

3. **特徴**
   - プッシュを中止可能
   - 複数のチェックを連続実行
   - リモートへの影響を防止

## 実際の使い方
### よくある使用シーン
1. **最終品質チェック**
   - 全コードのリンター実行
   - 型チェックの実行
   - コードカバレッジの確認

2. **テストの再実行**
   - 全テストスイートの実行
   - 統合テストの実行
   - パフォーマンステストの実行

3. **ブランチ保護**
   - ブランチ名の検証
   - コミット履歴の確認
   - マージ状態の確認

## 手を動かしてみよう
### 基本的な設定
```bash
# pre-pushフックの作成
cat > .git/hooks/pre-push << 'EOF'
#!/bin/sh
echo "プッシュ前のチェックを実行中..."
# ここにチェック処理を記述
EOF
chmod +x .git/hooks/pre-push
```

## 実践的なサンプル
### コード品質チェック
```bash
#!/bin/sh
# pre-pushフックの例

# プッシュされるブランチを取得
while read local_ref local_sha remote_ref remote_sha
do
    if [ "$remote_ref" = "refs/heads/main" ]; then
        echo "mainブランチへのプッシュをチェック中..."

        # 全コードのリンター実行
        if ! npm run lint; then
            echo "リンターエラーがあります"
            exit 1
        fi

        # 型チェックの実行
        if ! npm run type-check; then
            echo "型チェックエラーがあります"
            exit 1
        fi
    fi
done
```

### テストの実行
```bash
#!/bin/sh
# テスト実行用のpre-pushフック

# プッシュされるブランチを取得
while read local_ref local_sha remote_ref remote_sha
do
    if [ "$remote_ref" = "refs/heads/main" ]; then
        echo "mainブランチへのプッシュをチェック中..."

        # 全テストの実行
        if ! npm run test:all; then
            echo "テストが失敗しました"
            exit 1
        fi

        # カバレッジの確認
        if ! npm run test:coverage; then
            echo "カバレッジが基準を下回っています"
            exit 1
        fi
    fi
done
```

## 困ったときは
### よくあるトラブル
1. **フックが実行されない**
   - 実行権限の確認
   - パスの確認
   - シェバンの確認

2. **チェックが失敗する**
   - エラーメッセージの確認
   - 環境変数の確認
   - 依存関係の確認

3. **パフォーマンスの問題**
   - チェックの最適化
   - キャッシュの活用
   - 並列実行の検討

## もっと知りたい人へ
### 次のステップ
- 高度なチェックスクリプトの作成
- CI/CDとの連携
- チーム開発での活用

### おすすめの学習リソース
- [Git公式ドキュメント](https://git-scm.com/docs/githooks)
- [Husky](https://typicode.github.io/husky/)
- [GitHub Actions](https://docs.github.com/ja/actions)
