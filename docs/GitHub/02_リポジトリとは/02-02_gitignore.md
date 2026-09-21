# .gitignoreの基礎知識

## 概要
.gitignoreファイルはGitリポジトリで追跡しないファイルやディレクトリを指定するための設定ファイルです。

## .gitignoreとは
.gitignoreはGitがバージョン管理対象から除外すべきファイルやディレクトリのパターンを定義するテキストファイルです。

## .gitignoreの重要性
- **不要なファイルの除外**: ビルド成果物、ログファイル、一時ファイルなど、リポジトリに含めるべきでないファイルを除外できます
- **リポジトリの肥大化防止**: バイナリファイルや生成ファイルを除外することで、リポジトリのサイズを最適に保ちます
- **機密情報の保護**: API キーや認証情報などの機密データをリポジトリに含めることを防ぎます

## .gitignoreの基本的な書き方

```
# コメント行（#で始まる行はコメントとして扱われます）

# 特定のファイル名を指定
example.log
secrets.json

# 特定の拡張子を持つすべてのファイルを指定
*.log
*.tmp

# 特定のディレクトリ内のすべてのファイルを指定
logs/
node_modules/

# 特定のパスパターンを指定
build/output/
dist/*.min.js

# 除外したファイルを再度含める（!で始まるパターン）
!important.log
```

## パターンマッチングのルール

- `*` - 0個以上の任意の文字にマッチ（ディレクトリ区切り文字を除く）
- `?` - 任意の1文字にマッチ
- `[abc]` - 角括弧内の任意の1文字にマッチ
- `[0-9]` - 範囲内の任意の1文字にマッチ
- `**` - 任意のディレクトリを再帰的にマッチ（例: `docs/**/*.md`）
- `/` で始まるパターンはリポジトリのルートディレクトリから相対的に評価
- `/` で終わるパターンはディレクトリを指定

## .gitignoreの配置場所と適用範囲

1. **リポジトリ全体**: リポジトリのルートに配置した`.gitignore`ファイルはリポジトリ全体に適用されます
2. **サブディレクトリ**: 任意のサブディレクトリに配置した`.gitignore`ファイルはそのディレクトリとその下のディレクトリに適用されます
3. **グローバル設定**: `git config --global core.excludesfile ~/.gitignore_global`で設定するグローバルな.gitignoreファイル

## よく使われる.gitignoreパターン例

### 開発環境とエディタ関連
```
# VS Code
.vscode/
*.code-workspace

# IntelliJ IDEA / JetBrains
.idea/
*.iml
*.iws

# Eclipse
.project
.classpath
.settings/

# macOS
.DS_Store
.AppleDouble
.LSOverride

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini
```

### プログラミング言語別

#### Java
```
# コンパイル結果
*.class
*.jar
target/
build/
```

#### Python
```
# キャッシュファイル
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
```

#### JavaScript / Node.js
```
# 依存関係
node_modules/
npm-debug.log
yarn-debug.log
yarn-error.log
package-lock.json
```

## すでに追跡されているファイルの除外方法

.gitignoreファイルに追加しても、すでにGitで追跡されているファイルは自動的には無視されません。その場合は以下のコマンドでキャッシュから削除する必要があります：

```bash
git rm --cached <ファイル名>  # 特定のファイルをインデックスから削除
git rm -r --cached <ディレクトリ名>  # ディレクトリをインデックスから削除
```

## .gitignoreテンプレート

GitHubは様々な言語やフレームワーク向けの.gitignoreテンプレートを提供しています。新しいリポジトリ作成時に選択するか、[github/gitignore](https://github.com/github/gitignore)リポジトリから適切なテンプレートを利用できます。

## 注意点

- チーム内で.gitignoreファイルを共有し、一貫性を保つことが重要です
- プロジェクト固有の一時ファイルも忘れずに追加しましょう
- 機密情報は.gitignoreに頼らず、環境変数や専用の設定ファイルでの管理を検討してください
