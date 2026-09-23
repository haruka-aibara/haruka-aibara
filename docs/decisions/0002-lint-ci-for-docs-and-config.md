# ADR-0002: YAML / ワークフロー / HTML / Markdown を lint CI で機械チェックする

## ステータス

採用 (2026-09-23)

## コンテキスト

このリポジトリの中身の大半は Terraform ではなく、学習メモ（md 約1000本・HTML 約200本）とワークフローの YAML。これまで CI が見ていたのは Terraform と Python だけで、文書と設定ファイルは誰もチェックしていなかった。

導入時に既存ファイルを走らせたら、実際に次のものが見つかった。

- Marp ガイドのコードブロックの閉じ位置がずれて、以降の本文がすべてコード扱いで表示されていた
- 見出しレベルの飛び、画像の alt 抜け、HTML のコード例の生の `&`
- 見出し・リスト前後の空行抜けが数千か所。レンダラによっては見出しやリストとして解釈されない

どれも書いた時点では気づけず、表示して初めて分かる類の崩れ。AI に記事を書かせる運用なので量が増える一方で、目視では追いつかない。

## 決定

`.github/workflows/lint.yml` で PR と main への push ごとに次を走らせる。落ちたらマージしない。

| ツール | 対象 | 設定 |
|---|---|---|
| yamllint | `*.yml` / `*.yaml` | `.yamllint.yml` |
| actionlint | `.github/workflows/`（`run:` の shellcheck を含む） | なし |
| html-validate | `*.html` | `.htmlvalidate.json` |
| markdownlint（markdownlint-cli2） | `*.md` | `.markdownlint-cli2.jsonc` |

- **ツールは各形式のデファクトから選ぶ。** 根拠は「大手の文書リポジトリが実際に使っているか」と「リンター集約ツール（[Super-Linter](https://github.com/super-linter/super-linter)・[MegaLinter](https://github.com/oxsecurity/megalinter)）がその形式の標準として採用しているか」。2026-09 時点で確認した。
  - **markdownlint**: GitHub Docs のコンテンツリンターは markdownlint の上に独自ルールを足したもの（[コンテンツ リンターの使用](https://docs.github.com/ja/contributing/collaborating-on-github-docs/using-the-content-linter)、[github/docs の content-linter README](https://github.com/github/docs/blob/main/src/content-linter/README.md)「新しいルールを作る前に Markdownlint にないか確認する」）。MDN（[mdn/content の package.json](https://github.com/mdn/content/blob/main/package.json)）は markdownlint-cli2 を使っている。Super-Linter・MegaLinter とも Markdown の標準リンター。
  - **yamllint**: GitHub-hosted の Ubuntu ランナーイメージに最初から入っている（[actions/runner-images の Ubuntu 24.04 README](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md)）。ansible-lint は内部で yamllint を使っている。Super-Linter・MegaLinter とも YAML の標準リンター。
  - **actionlint**: Super-Linter・MegaLinter とも GitHub Actions の標準リンター。
- **Markdown は `--fix` で空行まわりを自動修正できるのも決め手。** 独自ルールを書かずに済む。
- **見るのは「構造の崩れ」だけ。書き方の好みは見ない。** 行長・表の列揃え・コードの言語指定・見出し末尾の句読点・同名見出しなどは無効にする。1000本超の既存メモを好みに合わせて書き換えるのは割に合わず、ノイズが多いと CI を無視するようになる。
- **自動修正で本文が変わるルールは切る。** 番号付きリストの番号チェック（`ol-prefix`）は、画像などで分断されたリストの番号を 1. に振り直して表示を変えてしまう。見出し末尾の「。」を消すルールも本文の変更になる。
- **HTML は単一ファイル記事の作りに合わせる。** inline style と landmark の命名は無効。表の `thead` / `tbody` と `th` の `scope` は有効にして、既存 74 ファイルを一括で直した。
- **導入と同時に既存の違反はすべて直す。** 除外リストで既存ファイルを逃がすと、そのファイルを触るたびに落ちる。対象外にしたのは、書き方の見本そのもの（`docs/Markdown/cheatsheet.md`）と Marp のスライドだけ。
- **記事の書き方は article-writing スキルに反映する。** AI が書く段階でルールに沿わせ、CI は取りこぼしの検出に回す。

## 検討した代替案

- **Terraform で他リポジトリに配布する（`ci/`）。** 対象の文書はこのリポジトリにしかないので、配布の仕組みに乗せる必要がない。直接置く。
- **zizmor（ワークフローのセキュリティ監査）。** 有用だが、指摘の大半は `ci/` から配布しているワークフローの `@main` 参照や `permissions` 未指定で、配布元の修正になる。別 PR で扱う。
- **リンク切れチェック（lychee など）。** 外部リンクの死活で CI が不安定になるので見送り。

## トレードオフ

- 記事を書くたびに空行などで CI が落ちうる。手元で `npx markdownlint-cli2 --fix "**/*.md"` を流せば大半は直る。
- 無効にしたルールの範囲の崩れ（表の見た目、リストの番号など）は引き続き目視頼み。
- ツールのメジャーバージョンはワークフロー内で固定している（`html-validate@11`、`markdownlint-cli2@0.23`）。上げるときはルールが増えて既存ファイルが落ちることがあるので、同じ PR で直す。
