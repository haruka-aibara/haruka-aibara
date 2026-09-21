### VScode 拡張機能をインストール

1. **Markdown All in One**
   - Markdownの基本機能をまとめた総合パッケージ
   - キーボードショートカット、目次作成、プレビューなどの機能を提供
   - https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one

2. **Markdown Preview Enhanced**
   - リアルタイムプレビュー機能を強化
   - 数式、図表、PDFエクスポートなどの高度な機能をサポート
   - https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced

3. **Markdown Preview Mermaid Support**
   - Mermaid記法でのダイアグラム作成をサポート
   - フローチャートや時系列図などの図表を簡単に作成可能
   - https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid

### Settings.json を編集する

#### マークダウンに画像を貼り付けた際の保存先ディレクトリを定義
```
"markdown.copyFiles.destination": {
  "**/*.md": "assets/${documentBaseName}/"
},
"markdown.copyFiles.overwriteBehavior": "uniqueFilename",
"markdown.editor.drop.copyIntoWorkspace": "always",
"markdown.editor.filePaste.copyIntoWorkspace": "always"
```

### その他設定

#### Mermaid プレビューで AWS アイコンを使えるようにする
https://qiita.com/take_me/items/83769d32c35e99b85ec8

##### 手順
コマンドパレットから

Markdown Preview Enhanced: Customize Preview HTML Head (Global) を選択

html の内容を以下の通り修正

```html
<!-- The content below will be included at the end of the <head> element. -->
<script type="text/javascript">
   const configureMermaidIconPacks = () => {
    window["mermaid"].registerIconPacks([
      {
        name: "logos",
        loader: () =>
          fetch("https://unpkg.com/@iconify-json/logos/icons.json").then(
            (res) => res.json()
          ),
      },
    ]);
  };

  // ref: https://stackoverflow.com/questions/39993676/code-inside-domcontentloaded-event-not-working
  if (document.readyState !== 'loading') {
    configureMermaidIconPacks();
  } else {
    document.addEventListener("DOMContentLoaded", () => {
      configureMermaidIconPacks();
    });
  }
</script>
```

##### 対象サービスの aws アイコンが存在するか確認

以下から検索できます（SNSで検索した場合の例）

https://icones.js.org/collection/logos?s=aws-sns
