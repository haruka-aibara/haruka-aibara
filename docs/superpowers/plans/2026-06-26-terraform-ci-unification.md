# Terraform CI 統一導入 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `haruka-aibara` org の Terraform リポジトリ群に、単一ソースの Reusable Workflow による Terraform CI（fmt / tflint / trivy）を統一的に導入する。

**Architecture:** CI ロジックは新設 `haruka-aibara/github-actions` repo の reusable workflow に集約。各 Terraform repo には薄い caller workflow を `github_repository_file` で自動配置する。reusable workflow 本体・caller テンプレートともに本メタ repo (`haruka-aibara/haruka-aibara`) のソースツリーで管理し、`github_repository_file` で各 repo へ push する（= 単一ソース、1 回の apply で完結）。

**Tech Stack:** Terraform (HCP Terraform / cloud backend), GitHub provider `integrations/github ~> 6.6`, GitHub Actions (reusable workflow), tflint, trivy。

## Global Constraints

- Terraform `required_version = "1.15.6"`（`terraform.tf`）。`.terraform-version` も `1.15.6`。
- Providers: `integrations/github ~> 6.6`, `hashicorp/tfe ~> 0.77`。
- このメタ repo は HCP Terraform の VCS-driven workspace。**apply は main へのマージで HCP Terraform 側が実行する**。ローカルでの検証は `terraform fmt -check` / `terraform validate` / 投機的 `terraform plan`（HCP のリモート run）まで。
- すべての `.tf` は `terraform fmt` 準拠（末尾改行・整形済み）であること。
- Action は読みやすさ優先でタグ pin（`@v4` 等）。将来 SHA pin に上げてよい。
- caller workflow ファイルはコメントで「Terraform 管理・直接編集禁止」を明記する。
- 既存パターンに従う: repo は `./modules/repository` モジュールで作成（`main.tf` 参照）。

## File Structure

- Create: `ci/workflows/terraform-ci.yml` — reusable workflow 本体（github-actions repo へ push される）
- Create: `ci/templates/terraform-ci-caller.yml.tftpl` — caller workflow テンプレート
- Modify: `main.tf` — `module "github-actions"` を追加（repo 器を作成）
- Create: `terraform_ci.tf` — locals（対象 repo 一覧）+ `github_repository_file` リソース群（reusable workflow の push と caller の配布）

---

### Task 1: `github-actions` repo を作成する（Terraform モジュール）

CI ロジックの置き場となる public repo を `./modules/repository` で新設する。

**Files:**
- Modify: `main.tf`（末尾に module ブロック追加）

**Interfaces:**
- Consumes: `module "<name>" { source = "./modules/repository" ... }` パターン（`main.tf:6` 等）。
- Produces: `module.github-actions.repository_name`（= `"github-actions"`）を Task 2 が参照する。

- [ ] **Step 1: `main.tf` に module ブロックを追加する**

`main.tf` の末尾に以下を追記する（既存の module ブロックと同じ書式）:

```hcl
# =========================================
# Shared CI / GitHub Actions
# =========================================

# Reusable GitHub Actions workflows (Terraform CI logic single source)
module "github-actions" {
  source = "./modules/repository"

  repository_name = "github-actions"
  description     = "Shared reusable GitHub Actions workflows (Terraform CI etc.)"

  topics = ["github-actions", "ci", "terraform"]
}
```

- [ ] **Step 2: フォーマットを検証する**

Run: `terraform fmt -check -recursive`
Expected: 差分なし（exit 0）。差分が出たら `terraform fmt` で整形し直す。

- [ ] **Step 3: 構文を検証する**

Run: `terraform validate`
Expected: `Success! The configuration is valid.`

- [ ] **Step 4: コミットする**

```bash
git add main.tf
git commit -m "feat: add github-actions repository for shared CI workflows"
```

---

### Task 2: reusable workflow 本体を作成し github-actions repo へ配布する

`fmt` / `tflint` / `trivy` を実行する `workflow_call` ワークフローを作り、`github_repository_file` で github-actions repo に push する。

**Files:**
- Create: `ci/workflows/terraform-ci.yml`
- Create: `terraform_ci.tf`

**Interfaces:**
- Consumes: `module.github-actions.repository_name`（Task 1）。
- Produces: github-actions repo の `.github/workflows/terraform-ci.yml`（`workflow_call`、inputs: `working-directory` string default `"."`, `terraform-version` string default `""`）。Task 3 の caller がこのパスを `uses:` で参照する。

- [ ] **Step 1: reusable workflow 本体を作成する**

`ci/workflows/terraform-ci.yml` を作成:

```yaml
name: Terraform CI

on:
  workflow_call:
    inputs:
      working-directory:
        description: Directory that contains the Terraform code
        type: string
        default: "."
      terraform-version:
        description: Terraform version to use (empty = read .terraform-version, else latest)
        type: string
        default: ""

jobs:
  fmt:
    name: terraform fmt
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Resolve Terraform version
        id: tfver
        run: |
          if [ -n "${{ inputs.terraform-version }}" ]; then
            echo "version=${{ inputs.terraform-version }}" >> "$GITHUB_OUTPUT"
          elif [ -f "${{ inputs.working-directory }}/.terraform-version" ]; then
            echo "version=$(cat "${{ inputs.working-directory }}/.terraform-version")" >> "$GITHUB_OUTPUT"
          else
            echo "version=latest" >> "$GITHUB_OUTPUT"
          fi
      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ steps.tfver.outputs.version }}
      - name: terraform fmt -check
        working-directory: ${{ inputs.working-directory }}
        run: terraform fmt -check -recursive

  tflint:
    name: tflint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: terraform-linters/setup-tflint@v4
      - name: tflint --init
        working-directory: ${{ inputs.working-directory }}
        run: tflint --init
      - name: tflint
        working-directory: ${{ inputs.working-directory }}
        run: tflint -f compact

  trivy:
    name: trivy (IaC misconfig)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Trivy config scan
        uses: aquasecurity/trivy-action@0.28.0
        with:
          scan-type: config
          scan-ref: ${{ inputs.working-directory }}
          format: table
          exit-code: "1"
          severity: HIGH,CRITICAL
```

- [ ] **Step 2: caller テンプレートのディレクトリを用意する**

Run: `mkdir -p ci/templates`
Expected: ディレクトリ作成（Task 3 でファイルを置く）。

- [ ] **Step 3: `terraform_ci.tf` を作成して reusable workflow を push する**

`terraform_ci.tf` を作成:

```hcl
# =========================================
# Terraform CI distribution
# Reusable workflow body + per-repo caller files,
# all managed from this repo as the single source.
# =========================================

# Push the reusable workflow body into the github-actions repo.
resource "github_repository_file" "reusable_terraform_ci" {
  repository          = module.github-actions.repository_name
  branch              = "main"
  file                = ".github/workflows/terraform-ci.yml"
  content             = file("${path.module}/ci/workflows/terraform-ci.yml")
  commit_message      = "Update reusable Terraform CI workflow (managed by Terraform)"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [commit_author, commit_email]
  }
}
```

- [ ] **Step 4: フォーマットを検証する**

Run: `terraform fmt -check -recursive`
Expected: 差分なし。差分が出たら `terraform fmt` で整形。

- [ ] **Step 5: 構文を検証する**

Run: `terraform validate`
Expected: `Success! The configuration is valid.`

- [ ] **Step 6: 投機的 plan で内容を確認する**

Run: `terraform plan`
Expected: HCP のリモート run が走り、`module.github-actions`（repo）と `github_repository_file.reusable_terraform_ci` が **新規作成** として表示される。destroy が出ないこと。

- [ ] **Step 7: コミットする**

```bash
git add ci/workflows/terraform-ci.yml terraform_ci.tf
git commit -m "feat: add reusable terraform CI workflow and distribute to github-actions repo"
```

---

### Task 3: caller テンプレート + パイロット 1 repo への配布

caller workflow テンプレートを作り、まず 1 repo（`aws-cost-allocation-tags`）だけに配布して end-to-end を確認する。

**Files:**
- Create: `ci/templates/terraform-ci-caller.yml.tftpl`
- Modify: `terraform_ci.tf`（locals + caller 用 `github_repository_file` を追加）

**Interfaces:**
- Consumes: github-actions repo の reusable workflow パス（Task 2）。
- Produces: `local.terraform_ci_repos`（map: repo 名 → `{ working_directory = string }`）。Task 4 がこの map を拡張する。`github_repository_file.terraform_ci_caller`（`for_each`）。

- [ ] **Step 1: caller テンプレートを作成する**

`ci/templates/terraform-ci-caller.yml.tftpl` を作成:

```yaml
# Managed by Terraform (haruka-aibara/haruka-aibara). Do not edit directly.
name: Terraform CI

on:
  pull_request:
  push:
    branches: [main]

jobs:
  ci:
    uses: haruka-aibara/github-actions/.github/workflows/terraform-ci.yml@main
    with:
      working-directory: "${working_directory}"
```

- [ ] **Step 2: `terraform_ci.tf` に locals と caller リソースを追加する**

`terraform_ci.tf` の先頭付近（既存 resource の前）に locals を追加:

```hcl
# Terraform repositories that should receive the CI caller workflow.
# Add a line here to onboard a new repo.
locals {
  terraform_ci_repos = {
    "aws-cost-allocation-tags" = { working_directory = "." }
  }
}
```

同ファイル末尾に caller 配布リソースを追加:

```hcl
# Distribute the thin caller workflow to each Terraform repository.
resource "github_repository_file" "terraform_ci_caller" {
  for_each = local.terraform_ci_repos

  repository = each.key
  branch     = "main"
  file       = ".github/workflows/terraform-ci.yml"
  content = templatefile("${path.module}/ci/templates/terraform-ci-caller.yml.tftpl", {
    working_directory = each.value.working_directory
  })
  commit_message      = "Add Terraform CI caller workflow (managed by Terraform)"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [commit_author, commit_email]
  }
}
```

- [ ] **Step 3: フォーマットと構文を検証する**

Run: `terraform fmt -check -recursive && terraform validate`
Expected: 差分なし、かつ `Success! The configuration is valid.`

- [ ] **Step 4: 投機的 plan で確認する**

Run: `terraform plan`
Expected: `github_repository_file.terraform_ci_caller["aws-cost-allocation-tags"]` が新規作成として 1 件表示される。

- [ ] **Step 5: コミットする**

```bash
git add ci/templates/terraform-ci-caller.yml.tftpl terraform_ci.tf
git commit -m "feat: add terraform CI caller template and pilot rollout to aws-cost-allocation-tags"
```

- [ ] **Step 6: パイロット動作確認（マージ後）**

PR を作成 → HCP Terraform の投機的 plan を確認 → main にマージ → HCP が apply。
その後 `aws-cost-allocation-tags` repo を確認:
- `.github/workflows/terraform-ci.yml` が配置されていること
- push/PR をトリガーに `fmt` / `tflint` / `trivy` の 3 ジョブが実行され、成功（または妥当な失敗）すること

Expected: 3 ジョブが実行され、reusable workflow 経由で動作する。問題があればここで修正してから Task 4 へ進む。

---

### Task 4: 全 Terraform repo へ展開する

パイロット成功後、`local.terraform_ci_repos` に残りの Terraform repo を追加して一斉展開する。

**Files:**
- Modify: `terraform_ci.tf`（`local.terraform_ci_repos` を拡張）

**Interfaces:**
- Consumes: `local.terraform_ci_repos`（Task 3）、`github_repository_file.terraform_ci_caller`（Task 3）。

- [ ] **Step 1: locals に残りの repo を追加する**

`terraform_ci.tf` の `local.terraform_ci_repos` を以下に置き換える（HCP workspace を持つ Terraform repo 全件）:

```hcl
locals {
  terraform_ci_repos = {
    "aws-cost-allocation-tags"                  = { working_directory = "." }
    "bedrock-slack-ai-agent"                    = { working_directory = "." }
    "bedrock-slack-ai-chatbot"                  = { working_directory = "." }
    "deploy-hcp-vault-dedicated-with-terraform" = { working_directory = "." }
    "generate-dev-io-summary"                   = { working_directory = "." }
    "haruka-aibara"                             = { working_directory = "." }
    "iam-access-analyzer-policy-generate"       = { working_directory = "." }
    "terraform-aws-budget-slack-notifier"       = { working_directory = "." }
    "google-cloud-hands-on"                     = { working_directory = "." }
  }
}
```

注: `working_directory` がルート直下でない repo（例: `google-cloud-hands-on` がサブディレクトリ構成の場合）は、その repo の実際の Terraform ディレクトリに合わせて値を変更する。マージ前に各 repo の構成を確認すること。

- [ ] **Step 2: フォーマットと構文を検証する**

Run: `terraform fmt -check -recursive && terraform validate`
Expected: 差分なし、かつ `Success! The configuration is valid.`

- [ ] **Step 3: 投機的 plan で確認する**

Run: `terraform plan`
Expected: `github_repository_file.terraform_ci_caller[...]` が追加分（8 件）新規作成として表示される。既存 1 件（pilot）に変更が無いこと。destroy が出ないこと。

- [ ] **Step 4: コミットする**

```bash
git add terraform_ci.tf
git commit -m "feat: roll out terraform CI caller workflow to all terraform repos"
```

- [ ] **Step 5: 展開確認（マージ後）**

main にマージ → HCP が apply。各 repo に caller workflow が配置され、CI が起動することをスポット確認する。

Expected: 全 Terraform repo に `.github/workflows/terraform-ci.yml` が配置され、CI が動作する。

---

## Self-Review Notes

- **Spec coverage:** 配布方式（reusable workflow）= Task 2/3。チェック内容（fmt/tflint/trivy, トークン不要）= Task 2 の workflow。置き場（github-actions repo 新設）= Task 1。caller の Terraform 自動配置 = Task 3/4。段階展開（パイロット→全件）= Task 3 Step 6 → Task 4。`.terraform-version` 読み取り = Task 2 Step 1 の Resolve Terraform version。
- **Spec からの差分（要周知）:** reusable workflow 本体を「github-actions repo に直接コミット」する代わりに、本メタ repo で管理し `github_repository_file` で push する方式に変更（単一ソース・1 apply 完結のため）。最終状態は同等。
- **リスク（spec 記載）:** branch protection はモジュール既定で `require_pull_request_reviews=false` / `enforce_admins=false` のため、`main` への直接コミットはブロックされない見込み。万一ブロックされる repo があれば該当 repo の設定を確認する。
- **Placeholder scan:** なし。全ステップに実コード/実コマンドを記載。
- **Type consistency:** `module.github-actions.repository_name` / `local.terraform_ci_repos`（map of object `{ working_directory }`）/ `github_repository_file.terraform_ci_caller`（for_each）を全タスクで一貫使用。
