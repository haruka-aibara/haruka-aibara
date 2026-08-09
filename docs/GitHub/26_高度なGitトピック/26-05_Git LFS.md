# Git LFS

## はじめに

「大きなファイルをGitで管理したい」「画像や動画などのバイナリファイルを効率的に扱いたい」そんな要望はありませんか？Git LFS（Large File Storage）は、大きなファイルを効率的に管理するためのGitの拡張機能です。この記事では、Git LFSの基本的な使い方から実践的な活用方法まで解説します。

## ざっくり理解しよう

Git LFSの重要なポイントは以下の3つです：

1. **大きなファイルの効率的な管理**
   - 大きなファイルを別のストレージで管理
   - リポジトリのサイズを最適化
   - クローンやプルの高速化

2. **透過的な操作**
   - 通常のGitコマンドで操作可能
   - 特別な知識が不要
   - 既存のワークフローを維持

3. **柔軟な設定**
   - ファイルタイプごとの管理
   - サイズ制限のカスタマイズ
   - ストレージの選択

## 実際の使い方

### 基本的な使い方

1. Git LFSのインストール
```bash
# macOS
brew install git-lfs

# Ubuntu
sudo apt install git-lfs

# Windows
choco install git-lfs
```

2. Git LFSの初期化
```bash
# リポジトリでGit LFSを初期化
git lfs install

# 特定のファイルタイプを追跡
git lfs track "*.psd"
git lfs track "*.zip"
git lfs track "*.pdf"
```

3. ファイルの管理
```bash
# 追跡対象のファイルを追加
git add .gitattributes
git add file.psd

# 通常通りコミット
git commit -m "Add large file with Git LFS"
```

## 手を動かしてみよう

### 基本的な手順

1. リポジトリの設定
```bash
# Git LFSをインストール
git lfs install

# 追跡対象の設定
git lfs track "*.psd"
git lfs track "*.zip"
git lfs track "*.pdf"

# 設定を保存
git add .gitattributes
git commit -m "Configure Git LFS"
```

2. 大きなファイルの追加
```bash
# ファイルを追加
git add large-file.psd

# コミット
git commit -m "Add large file"

# プッシュ
git push
```

3. ファイルの確認
```bash
# 追跡中のファイルを確認
git lfs ls-files

# 特定のファイルの詳細を確認
git lfs ls-files --name-only
```

## 実践的なサンプル

### 一般的なプロジェクトの設定例

```bash
# .gitattributesファイルの例
*.psd filter=lfs diff=lfs merge=lfs -text
*.zip filter=lfs diff=lfs merge=lfs -text
*.pdf filter=lfs diff=lfs merge=lfs -text
*.mp4 filter=lfs diff=lfs merge=lfs -text
*.mov filter=lfs diff=lfs merge=lfs -text
*.ai filter=lfs diff=lfs merge=lfs -text
*.indd filter=lfs diff=lfs merge=lfs -text
```

### 特定のプロジェクトの設定例

```bash
# 画像ファイル
*.png filter=lfs diff=lfs merge=lfs -text
*.jpg filter=lfs diff=lfs merge=lfs -text
*.gif filter=lfs diff=lfs merge=lfs -text

# 動画ファイル
*.mp4 filter=lfs diff=lfs merge=lfs -text
*.mov filter=lfs diff=lfs merge=lfs -text
*.avi filter=lfs diff=lfs merge=lfs -text

# ドキュメント
*.pdf filter=lfs diff=lfs merge=lfs -text
*.docx filter=lfs diff=lfs merge=lfs -text
*.xlsx filter=lfs diff=lfs merge=lfs -text
```

## 困ったときは

### よくあるトラブルと解決方法

1. **ファイルが正しく追跡されない場合**
```bash
# 追跡設定を確認
git lfs track

# 設定を再適用
git lfs track "*.psd"
git add .gitattributes
git commit -m "Update Git LFS tracking"
```

2. **プッシュが失敗する場合**
```bash
# 認証情報を確認
git lfs env

# キャッシュをクリア
git lfs prune
```

3. **ファイルのダウンロードに問題がある場合**
```bash
# ファイルの状態を確認
git lfs ls-files

# ファイルを再ダウンロード
git lfs pull
```

### 予防するためのコツ

- プロジェクト開始時にGit LFSを設定
- 適切なファイルタイプの選択
- 定期的なメンテナンス

## もっと知りたい人へ

### 次のステップ

- カスタムストレージの設定
- バックアップ戦略
- 大規模プロジェクトでの最適化

### おすすめの学習リソース

- [Git LFS公式ドキュメント](https://git-lfs.github.com/)
- [Git LFS GitHubリポジトリ](https://github.com/git-lfs/git-lfs)

### コミュニティ情報

- [Git LFS GitHub Discussions](https://github.com/git-lfs/git-lfs/discussions)
- [Stack Overflow - git-lfs](https://stackoverflow.com/questions/tagged/git-lfs)
