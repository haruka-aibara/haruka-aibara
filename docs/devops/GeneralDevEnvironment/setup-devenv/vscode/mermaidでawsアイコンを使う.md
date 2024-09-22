## 参考記事

https://qiita.com/take_me/items/83769d32c35e99b85ec8

## 手順
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

## 対象サービスの aws アイコンが存在するか確認

以下のように検索できます（SNSで検索した場合の例）

https://icones.js.org/collection/logos?s=aws-sns
