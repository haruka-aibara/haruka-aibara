---
marp: true
theme: default
paginate: true
style: |
  section {
    font-family: "Meiryo", "Noto Sans JP", "Hiragino Sans", "Hiragino Kaku Gothic ProN", sans-serif;
    color: #333;
    padding: 45px 35px 35px 35px;
    position: relative;
  }

  .header-bar {
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 48px;
    background: #444;
    color: #fff;
    font-size: 1.1em;
    font-weight: bold;
    line-height: 48px;
    padding-left: 28px;
    letter-spacing: 0.08em;
    z-index: 10;
    box-sizing: border-box;
  }

  h1, h2 {
    font-weight: 700;
    letter-spacing: 0.01em;
    margin-bottom: 0.25em;
  }

  h1 {
    font-size: 1.6em;
    color: #333;
    border-bottom: 1px solid #1976d2;
    padding-bottom: 0.1em;
    margin-bottom: 0.4em;
  }

  h2 {
    font-size: 1.3em;
    color: #1976d2;
  }

  h3, h4 {
    font-weight: 600;
    color: #555;
    margin-top: 0.8em;
  }

  p, li {
    font-size: 0.9em;
    line-height: 1.4;
  }

  ul, ol {
    margin-left: 0.8em;
  }

  li {
    margin-bottom: 0.2em;
  }

  code, pre {
    background: #f5f5f5;
    color: #1976d2;
    border-radius: 3px;
    padding: 0.15em 0.3em;
    font-size: 0.85em;
  }

  blockquote {
    border-left: 1px solid #1976d2;
    background: #f0f7fa;
    color: #333;
    padding: 0.4em 0.6em;
    margin: 0.6em 0;
  }

  footer, .footer {
    color: #888;
    font-size: 0.7em;
    text-align: center;
    margin-top: 1em;
  }

  a {
    color: #1976d2;
    text-decoration: underline;
  }

  .columns {
    display: flex;
    gap: 1em;
  }
  .columns > div {
    flex: 1;
  }

  hr {
    border: none;
    border-top: 1px solid #eee;
    margin: 1em 0;
  }

  /* アクセントカラー */
  .accent {
    color: #e53935;
    font-weight: bold;
  }

  /* サブカラー */
  .sub {
    color: #90caf9;
  }

  /* ページ番号のカスタマイズ */
  section::after {
    content: attr(data-marpit-pagination);
    position: absolute;
    right: 1em;
    bottom: 0.8em;
    color: #888;
    font-size: 0.75em;
  }
---
<div class="header-bar">プレゼン資料</div>

# Marp サンプルプレゼンテーション
## 基本的な使い方と機能紹介

---
<div class="header-bar">プレゼン資料</div>

# スライドの基本構造

- スライドは `---` で区切ります
- Markdownの記法が使えます
- テーマを変更できます

---
<div class="header-bar">プレゼン資料</div>

# コードの表示

```python
def hello_world():
    print("Hello, Marp!")
```

---
<div class="header-bar">プレゼン資料</div>

# 画像の挿入

![width:500px](https://picsum.photos/500/300)

---
<div class="header-bar">プレゼン資料</div>

# 2カラムレイアウト

<div class="columns">
<div>

## 左カラム
- リスト1
- リスト2

</div>
<div>

## 右カラム
- リスト3
- リスト4

</div>
</div>

---
<div class="header-bar">プレゼン資料</div>

# 背景画像

![bg left:40%](https://picsum.photos/800/600)

## 背景画像付きスライド
- 左側に画像
- 右側にテキスト

---
<div class="header-bar">プレゼン資料</div>

# ありがとうございました！

- 質問はありますか？
- ご清聴ありがとうございました
