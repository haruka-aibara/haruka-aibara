# works

作るもの・管理するものを、別リポジトリを切らずに全部ここへ集める個人のモノレポ。

## 方針

- **インフラは Terraform で持つ。** 手で作らず、このリポジトリから HCP Terraform 経由で apply する（ルートの `*.tf` / `modules/`）
- **アプリのコードは、それを動かすインフラと同じモジュールに置く。** Lambda なども `modules/` の中
- **他リポジトリに配るものは、ここを単一ソースにする。** CI などは Terraform で配布し、配布先は直接編集しない（`workflow-dist/`）
- **学んだこと・調べたことは記事にして公開する。** `docs/` に書き、GitHub Pages（<https://haruka-aibara.github.io/works/>）で読めるようにする
- **開発環境も配布物として持つ。** devcontainer テンプレートをここから ghcr に publish する（`devcontainer-templates/`）
- **使わなくなったものは消さずに止める。** モジュールは残し、`main.tf` の呼び出しをコメントアウトしておく

## Terraform

リポジトリの設定・topics・branch protection・脆弱性アラートは `modules/repository` に集約。CI は `workflow-dist/` を単一ソースとして `github_repository_file` で配布するので、配布先のワークフローファイルは直接編集しない。

apply は HCP Terraform の VCS 駆動ワークスペース `works` が実行する。**`auto_apply = true` のため、main へのマージ時点で apply が走る。** ローカルで行うのは検証まで。

```bash
terraform fmt -check -recursive
```

CI では `terraform fmt` / `tflint` / `trivy`（IaC misconfig）が走る。

Python は `pyproject.toml` を持つディレクトリ（Lambda 1つにつき1つ）を CI が自動で見つけ、ディレクトリごとに `ruff` と `pytest` を並列で回す。PR では変更のあったディレクトリだけが対象になる。Lambda を足すときは、`pyproject.toml`・`uv.lock`・`tests/` を持つディレクトリを置けばよく、CI 側の設定は触らない。

## docs

書き方・置き場所のルールは [`docs/reference/README.md`](docs/reference/README.md) に集約している。

## devcontainer テンプレート

`devcontainer-templates/src/**` を触って main にマージすると、`.github/workflows/devcontainer-release.yaml` が version を bump して `ghcr.io/haruka-aibara/works/haruka-aibara-dev-env` に publish する。詳細は [`devcontainer-templates/README.md`](devcontainer-templates/README.md)。
