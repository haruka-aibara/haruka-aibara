# works

作るもの・管理するものを、別リポジトリを切らずに全部ここへ集める個人のモノレポ。

## 方針

- **GitHub もクラウドも Terraform で持つ。** 手で作らず、このリポジトリから apply する
- **アプリのコードは、それを動かすインフラと同じモジュールに置く。**
- **他リポジトリに配るものは、ここを単一ソースにする。** CI（`workflow-dist/`）は Terraform で配布するので、配布先は直接編集しない
- **学んだことは記事にして公開する。** `docs/` に書き、[GitHub Pages](https://haruka-aibara.github.io/works/) で読めるようにする。書き方は [`docs/reference/README.md`](docs/reference/README.md)
- **開発環境も配布物として持つ。** [`devcontainer-templates/`](devcontainer-templates/README.md) から ghcr に publish する
- **使わなくなったものは消さずに止める。** モジュールは残し、`main.tf` の呼び出しをコメントアウトしておく

## main へのマージで起きること

- **HCP Terraform が apply する。** ワークスペース `works` は `auto_apply = true` なので、plan を確認する段階がなくそのまま反映される。ローカルでやるのは検証まで
- `devcontainer-templates/src/**` を変えていれば、version を bump して publish する

## Lambda を足すとき

`pyproject.toml`・`uv.lock`・`tests/` を持つディレクトリを置けば、CI が見つけて `ruff` と `pytest` を回す。CI 側の設定は触らない。
