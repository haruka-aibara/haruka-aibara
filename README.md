# works

管理対象を全部集約する個人のモノレポ。Terraform コード・CI 配布・実装コード（Lambda など）・学習メモが同居する。

## 中身

| 場所 | 中身 |
|---|---|
| ルートの `*.tf` | GitHub リポジトリ・HCP Terraform ワークスペース・AWS リソースの管理（HCP Terraform の `works` ワークスペースで apply） |
| `modules/repository` | GitHub リポジトリ1つ分の設定をまとめたモジュール |
| `modules/` のその他 | インフラ／アプリ（Bedrock の Slack ボット、AWS 予算通知、HCP Vault、Google Cloud など）と `TFE_TOKEN` の自己ローテーション。使っていないものは `main.tf` で呼び出しをコメントアウトしてある |
| `workflow-dist/` | 各リポジトリに配布する CI の単一ソース。`reusable/` は github-actions リポジトリに置く reusable workflow 本体、`callers/` は各リポジトリの `.github/workflows/` に置く呼び出し側テンプレート |
| `docs/` | 学習メモ・技術記事（1000本超）。GitHub Pages（<https://haruka-aibara.github.io/works/>）で公開 |
| `devcontainer-templates/` | ghcr に publish する devcontainer テンプレート |

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
