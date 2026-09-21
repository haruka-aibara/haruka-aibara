# Git Attributes

## はじめに

「特定のファイルの改行コードを統一したい」「バイナリファイルをGitで管理したい」「特定のファイルの差分表示方法をカスタマイズしたい」そんな要望はありませんか？Git Attributesは、ファイルごとにGitの動作をカスタマイズできる強力な機能です。この記事では、Git Attributesの基本的な使い方から実践的な活用方法まで解説します。

## ざっくり理解しよう

Git Attributesの重要なポイントは以下の3つです：

1. **ファイルごとの動作制御**
   - 改行コードの自動変換
   - バイナリファイルの適切な扱い
   - 差分表示方法のカスタマイズ

2. **プロジェクトの一貫性維持**
   - チーム全体での設定統一
   - 環境間の差異を解消
   - コード品質の維持

3. **柔軟なカスタマイズ**
   - パターンベースの設定
   - 条件付きの動作制御
   - 外部ツールとの連携

## 実際の使い方

### 基本的な使い方

1. `.gitattributes`ファイルの作成
```bash
# プロジェクトのルートディレクトリに作成
touch .gitattributes
```

2. 基本的な属性の設定
```gitattributes
# テキストファイルの改行コードを統一
*.txt text eol=lf

# バイナリファイルの指定
*.png binary
*.jpg binary

# 特定のファイルの差分表示方法
*.md diff=markdown
```

3. パターンベースの設定
```gitattributes
# すべてのテキストファイル
* text=auto

# 特定のディレクトリ内のファイル
docs/*.txt text eol=lf
src/*.js text eol=lf

# 特定の拡張子
*.{cmd,bat} text eol=crlf
```

## 手を動かしてみよう

### 基本的な手順

1. プロジェクトの設定
```bash
# .gitattributesファイルを作成
echo "* text=auto" > .gitattributes

# 設定を確認
git check-attr -a file.txt
```

2. 特定のファイルの設定
```bash
# 改行コードの設定
echo "*.txt text eol=lf" >> .gitattributes

# バイナリファイルの設定
echo "*.png binary" >> .gitattributes
```

3. 設定の適用
```bash
# 設定をリポジトリに追加
git add .gitattributes
git commit -m "Add .gitattributes"

# 既存のファイルに設定を適用
git add --renormalize .
```

## 実践的なサンプル

### 一般的なプロジェクトの設定例

```gitattributes
# テキストファイルの基本設定
* text=auto

# 改行コードの設定
*.txt text eol=lf
*.md text eol=lf
*.js text eol=lf
*.css text eol=lf
*.html text eol=lf

# バイナリファイル
*.png binary
*.jpg binary
*.gif binary
*.ico binary
*.zip binary
*.pdf binary

# 実行ファイル
*.exe binary
*.dll binary

# 特定の言語の設定
*.java text eol=lf
*.py text eol=lf
*.rb text eol=lf

# 設定ファイル
*.ini text eol=crlf
*.conf text eol=crlf
```

### 特定のプロジェクトの設定例

```gitattributes
# フロントエンドプロジェクト
*.js text eol=lf
*.jsx text eol=lf
*.ts text eol=lf
*.tsx text eol=lf
*.css text eol=lf
*.scss text eol=lf
*.html text eol=lf

# アセット
assets/images/* binary
assets/fonts/* binary

# 設定ファイル
.env* text eol=lf
*.config.js text eol=lf
```

## 困ったときは

### よくあるトラブルと解決方法

1. **改行コードが正しく変換されない場合**
```bash
# 設定を確認
git check-attr -a file.txt

# 設定を再適用
git add --renormalize .
```

2. **バイナリファイルが正しく扱われない場合**
```bash
# ファイルの属性を確認
git check-attr -a file.png

# バイナリ属性を強制設定
git add --renormalize .
```

3. **設定が反映されない場合**
```bash
# キャッシュをクリア
git rm --cached -r .
git reset --hard
git add .
```

### 予防するためのコツ

- プロジェクト開始時に`.gitattributes`を設定
- チームで設定を共有
- 定期的な設定の見直し

## もっと知りたい人へ

### 次のステップ

- カスタム属性の定義
- 外部ツールとの連携
- 大規模プロジェクトでの設定管理

### おすすめの学習リソース

- [Git公式ドキュメント - Attributes](https://git-scm.com/docs/gitattributes)
- [Pro Git Book - Attributes](https://git-scm.com/book/ja/v2/Git-%E3%81%AE%E3%82%AB%E3%82%B9%E3%82%BF%E3%83%9E%E3%82%A4%E3%82%BA-%E3%82%AE%E3%83%83%E3%83%88%E3%81%AE%E3%82%A2%E3%83%88%E3%83%AA%E3%83%93%E3%83%A5%E3%83%BC%E3%83%88)

### コミュニティ情報

- [GitHub Discussions](https://github.com/git/git/discussions)
- [Stack Overflow - gitattributes](https://stackoverflow.com/questions/tagged/gitattributes)
