# Marp for VS Code ガイド

## はじめに
スライド作成に時間を取られていませんか？Markdownで簡単にプレゼンテーションを作成できるMarp for VS Codeの使い方をご紹介します。このガイドでは、技術的な内容を効率的に伝えるためのスライド作成方法を解説します。

## ざっくり理解しよう
- Markdownでスライドを作成できるVS Code拡張機能
- リアルタイムプレビューで確認しながら編集可能
- PDFやPowerPoint形式でエクスポート可能

## 実際の使い方
1. VS Codeに拡張機能をインストール
   - [Marp for VS Code](https://marketplace.visualstudio.com/items?itemName=marp-team.marp-vscode)をインストール

2. 基本的な使い方
   - `.md`ファイルを作成
   - ファイルの先頭に`---`を3つ書く
   - 各スライドは`---`で区切る
   - プレビューは`Ctrl+Shift+V`（Windows）または`Cmd+Shift+V`（Mac）

## 手を動かしてみよう
1. 新規ファイル作成
```markdown
---
marp: true
theme: default
---

# タイトルスライド
## サブタイトル

---

# 2枚目のスライド
- 箇条書き
- コードブロック
```

2. プレビュー表示
   - エディタ右上のプレビューボタンをクリック
   - または`Ctrl+Shift+V`（Windows）または`Cmd+Shift+V`（Mac）

## 実践的なサンプル
```markdown
---
marp: true
theme: default
paginate: true
---

# 技術解説
## サンプルスライド

- ポイント1
- ポイント2

---

# コードサンプル

```python
def hello():
    print("Hello, Marp!")
```

---

# 画像の挿入

![width:500px](https://example.com/image.png)
```

## 困ったときは
- プレビューが表示されない場合
  - VS Codeを再起動
  - 拡張機能が正しくインストールされているか確認
- 画像が表示されない場合
  - パスが正しいか確認
  - インターネット接続を確認

## もっと知りたい人へ
- [公式ドキュメント](https://marpit.marp.app/)
- [Marp for VS Code マーケットプレイス](https://marketplace.visualstudio.com/items?itemName=marp-team.marp-vscode)
- [参考記事](https://qiita.com/piyonakajima/items/1084e2f2ba765e855271)
