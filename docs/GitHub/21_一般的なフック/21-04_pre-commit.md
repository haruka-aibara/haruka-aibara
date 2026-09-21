# pre-commitフック

## はじめに
pre-commitフックは、コミットが作成される直前に実行されるクライアントサイドのフックです。コードの品質を保つために、コミット前に様々なチェックを自動的に行うことができます。

## ざっくり理解しよう
1. **実行タイミング**
   - コミット作成直前
   - コミットメッセージ入力前
   - ローカル環境で実行

2. **主な用途**
   - コードの品質チェック
   - テストの実行
   - コミットの検証

3. **特徴**
   - コミットを中止可能
   - 複数のチェックを連続実行
   - 開発者の作業を支援

## 実際の使い方
### よくある使用シーン
1. **コード品質の確保**
   - リンターの実行
   - コードフォーマッターの実行
   - 型チェックの実行

2. **テストの自動化**
   - ユニットテストの実行
   - 統合テストの実行
   - テストカバレッジの確認

3. **セキュリティチェック**
   - 機密情報の検出
   - セキュリティスキャン
   - 依存関係のチェック

## 手を動かしてみよう
### 基本的な設定
```bash
# pre-commitフックの作成
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
echo "コミット前のチェックを実行中..."
# ここにチェック処理を記述
EOF
chmod +x .git/hooks/pre-commit
```

## 実践的なサンプル
### コード品質チェック
```bash
#!/bin/sh
# pre-commitフックの例

# 変更されたファイルを取得
files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|jsx|ts|tsx)$')

if [ -n "$files" ]; then
    echo "JavaScript/TypeScriptファイルのチェックを実行中..."

    # ESLintの実行
    if ! npx eslint $files; then
        echo "ESLintエラーがあります"
        exit 1
    fi

    # Prettierの実行
    if ! npx prettier --check $files; then
        echo "コードフォーマットエラーがあります"
        exit 1
    fi
fi
```

### テストの実行
```bash
#!/bin/sh
# テスト実行用のpre-commitフック

# 変更されたファイルを取得
files=$(git diff --cached --name-only --diff-filter=ACM)

# テストファイルが変更された場合のみテストを実行
if echo "$files" | grep -q "test/"; then
    echo "テストを実行中..."
    
    # テストの実行
    if ! npm test; then
        echo "テストが失敗しました"
        exit 1
    fi
fi
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
- [pre-commitフレームワーク](https://pre-commit.com/)
- [Husky](https://typicode.github.io/husky/)
