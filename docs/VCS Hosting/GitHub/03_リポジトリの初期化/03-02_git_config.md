# Git Configuration (git config)

Git configurationはGitの動作をカスタマイズするための設定機能で、効率的なバージョン管理のための重要な第一歩です。

Git configは階層的な設定ファイルを通じてユーザー情報やGitの振る舞いを定義する仕組みです。

## 基本的な使い方

### 設定レベル

Git configには3つの設定レベルがあります：

- `--system`：システム全体の設定（すべてのユーザー、すべてのリポジトリに適用）
- `--global`：ユーザーごとの設定（現在のユーザーのすべてのリポジトリに適用）
- `--local`：リポジトリごとの設定（デフォルト、現在のリポジトリのみに適用）

### 必須の初期設定

Gitを使い始める際に必ず設定すべき項目：

```bash
# ユーザー名の設定
git config --global user.name "あなたの名前"

# メールアドレスの設定
git config --global user.email "あなたのメール@example.com"
```

### 設定の確認

```bash
# すべての設定を表示
git config --list

# 特定の設定値を確認
git config user.name
```

### よく使う設定項目

```bash
# デフォルトのエディタを設定
git config --global core.editor "vim"

# 改行コードの自動変換を無効化
git config --global core.autocrlf false

# カラー出力を有効化
git config --global color.ui auto

# エイリアス（ショートカットコマンド）の設定
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
```

### 設定ファイルの場所

- システム設定: `/etc/gitconfig`
- グローバル設定: `~/.gitconfig` または `~/.config/git/config`
- ローカル設定: プロジェクトの `.git/config`

### 設定の削除

```bash
# 設定項目の削除
git config --global --unset user.name
```

## 日本語環境での注意点

### 文字化け対策

```bash
# 日本語ファイル名の文字化けを防ぐ
git config --global core.quotepath false
```

### コミットメッセージのエンコーディング

```bash
# コミットメッセージのエンコーディングをUTF-8に設定
git config --global i18n.commitEncoding utf-8

# ログの出力エンコーディングをUTF-8に設定
git config --global i18n.logOutputEncoding utf-8
```

## まとめ

Git configは初期設定から高度なカスタマイズまで幅広く対応し、快適なGit環境構築のために必須のコマンドです。基本設定を正しく行うことで、チーム開発やプロジェクト管理がスムーズになります。
