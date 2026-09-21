# works

GitHub リポジトリと HCP Terraform ワークスペースを Terraform で一元管理するメタリポジトリ。

## 管理対象

| 対象 | 定義 |
|---|---|
| GitHub リポジトリ | `main.tf`（`./modules/repository` を利用） |
| HCP Terraform ワークスペース | `hcp_terraform.tf` |
| Terraform CI の配布 | `terraform_ci.tf` + `ci/` |
| Python CI の配布 | `python_ci.tf` + `ci/` |
| `TFE_TOKEN` のローテーション | `tfe_token_rotation.tf` |

リポジトリの設定・topics・branch protection・脆弱性アラートは `modules/repository` に集約している。各リポジトリの `.github/workflows/` に置かれる CI は、`ci/` 配下を単一ソースとして `github_repository_file` で配布される。配布先のワークフローファイルは直接編集しない。

## 適用方法

HCP Terraform の VCS 駆動ワークスペース `works` が apply を実行する。

**`auto_apply = true` のため、main へのマージ時点で apply が走る。**

ローカルで行うのは検証まで。

```bash
terraform fmt -check -recursive
```

CI では `terraform fmt` / `tflint` / `trivy`（IaC misconfig）が走る。

## ドキュメント

- [GitHub 認証のしくみ](docs/reference/github-authentication.md) — workspace の変数や GitHub App が何者かを調べるとき
- [GitHub Organization 移行 + GitHub App 認証 移行手順書](docs/runbooks/github-org-migration-and-app-auth.md) — この構成に至った経緯
- [TFE_TOKEN 自動ローテーション](docs/runbooks/tfe-token-rotation.md) — 初回のブートストラップ、漏洩時の手順、文鎮化からの復旧
