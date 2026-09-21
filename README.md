# works

Terraform コードと学習メモが同居する個人のモノレポ。

## 中身

| 場所 | 中身 |
|---|---|
| ルートの `*.tf` / `modules/` | GitHub リポジトリと HCP Terraform ワークスペースの管理 |
| `ci/` | 各リポジトリの `.github/workflows/` に配布する CI の単一ソース |
| `docs/` | 学習メモ・技術記事（1000本超）。旧 `docs` リポジトリを統合したもの |
| `devcontainer-templates/` | ghcr に publish する devcontainer テンプレート。旧 `devcontainer-templates` リポジトリを統合したもの |

## Terraform

リポジトリの設定・topics・branch protection・脆弱性アラートは `modules/repository` に集約。CI は `ci/` を単一ソースとして `github_repository_file` で配布するので、配布先のワークフローファイルは直接編集しない。

apply は HCP Terraform の VCS 駆動ワークスペース `works` が実行する。**`auto_apply = true` のため、main へのマージ時点で apply が走る。** ローカルで行うのは検証まで。

```bash
terraform fmt -check -recursive
```

CI では `terraform fmt` / `tflint` / `trivy`（IaC misconfig）が走る。

## docs

書き方・置き場所のルールは [`docs/reference/README.md`](docs/reference/README.md) に集約している。

## devcontainer テンプレート

`devcontainer-templates/src/**` を触って main にマージすると、`.github/workflows/devcontainer-release.yaml` が version を bump して `ghcr.io/haruka-aibara/works/haruka-aibara-dev-env` に publish する。詳細は [`devcontainer-templates/README.md`](devcontainer-templates/README.md)。

## 運用メモ

- [GitHub 認証のしくみ](docs/reference/github-authentication.md) — workspace の変数や GitHub App が何者かを調べるとき
- [GitHub Organization 移行 + GitHub App 認証 移行手順書](docs/runbooks/github-org-migration-and-app-auth.md) — この構成に至った経緯
- [devcontainer テンプレートのモノレポ統合](docs/runbooks/devcontainer-template-monorepo-migration.md) — 旧リポジトリを畳むとき、ghcr の package を作り直すとき
- [TFE_TOKEN 自動ローテーション](docs/runbooks/tfe-token-rotation.md) — 初回のブートストラップ、漏洩時の手順、文鎮化からの復旧
