## GitHub ↔ Zenn 連携

GitHub リポジトリと連携して Markdown ファイルをもとに記事を自動的に Zenn にアップロードできます。

下記参考ページ

### アカウントにGitHubリポジトリを連携してZennのコンテンツを管理する
https://zenn.dev/zenn/articles/connect-to-github

上記ページ通りに連携しただけだと、リポジトリ内の Markdown ファイルが Zenn に対応していないと Zenn へのアップロードに失敗します。

各 Markdown ファイルは Front Matter を含み、ファイル名が slug になっている必要があります。

それぞれの言葉の意味が分からない場合は以下ページを確認

### Markdownのメタデータ[Front Matter]について
https://zenn.dev/adust/articles/cea61d98ea09d3

### Zennのスラッグ（slug）とは
https://zenn.dev/zenn/articles/what-is-slug