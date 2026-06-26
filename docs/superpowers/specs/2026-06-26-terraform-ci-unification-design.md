# Terraform CI 統一導入 設計

- 日付: 2026-06-26
- 対象: `haruka-aibara` org の Terraform リポジトリ群（現状 9 workspace）

## 背景・課題

`haruka-aibara/haruka-aibara` は HCP Terraform (Terraform Cloud) で 9 個の workspace を
管理するメタリポジトリ。各 workspace は別々の GitHub リポジトリに VCS 連携しており、
`plan`/`apply` は HCP Terraform 側（VCS-driven runs）で実行される。

現状、どのリポジトリにも GitHub Actions による Terraform CI が無い。PR マージ前の
早期フィードバック（フォーマット崩れ・lint・IaC 誤設定）を得たい。さらに、複数の
Terraform リポジトリに **統一した形で** CI を入れ、メンテナンスを一元化したい。

`plan`/`apply` は HCP Terraform が担うため、CI では重複する `plan`/`apply` は行わず、
トークン不要の静的チェックに絞る。

## 決定事項（ブレストの結論）

1. **配布方式**: Reusable Workflow 中心。CI ロジックを 1 箇所に集約し、各 repo は薄い
   呼び出しのみ持つ。
2. **チェック内容**: トークン不要の軽量セット = `terraform fmt -check` + `tflint` + `trivy`
   （`validate` は `cloud {}` バックエンドのため init=TFC トークンが各 repo に必要になり、
   今回は採用しない）。
3. **ロジック置き場**: 専用リポジトリ `haruka-aibara/github-actions` を新設。
4. **呼び出し側ファイルの配置**: 各 repo の `.github/workflows/terraform-ci.yml` を、
   本 Terraform から `github_repository_file` で自動配置・一元管理。

## 全体像

```
┌─────────────────────────────────────┐
│ haruka-aibara/github-actions (新設)   │  ← CI ロジックの単一ソース
│  .github/workflows/terraform-ci.yml   │     (workflow_call / reusable)
│   jobs: fmt-check, tflint, trivy      │
└──────────────────┬──────────────────┘
                   │ uses: ...@main
   ┌───────────────┼───────────────┬────────────┐
   ▼               ▼               ▼            ▼
 repoA           repoB           repoC  ...  repoN
 .github/workflows/terraform-ci.yml (薄い呼び出し)
   ↑ これを haruka-aibara(本 repo) の Terraform が
     github_repository_file で全 repo に自動配置
```

## コンポーネント

### 1. `haruka-aibara/github-actions` リポジトリ（新設・Terraform 管理）

- 本 Terraform の `modules/repository` で repo の器を作る（visibility = public）。
  - public にする理由: public な呼び出し元から reusable workflow を参照する場合に
    最も摩擦が少ないため。
- 中身の reusable workflow 本体 `terraform-ci.yml` は、この repo に直接コミットして
  管理する CI ロジックの単一ソース。
- インターフェース:
  - トリガー: `on: workflow_call`
  - inputs:
    - `working-directory` (string, default `"."`) — Terraform コードのディレクトリ
    - `terraform-version` (string, optional) — 未指定時は repo の `.terraform-version`
      を読む、それも無ければ未指定（latest）
- jobs:
  - `fmt`: `terraform fmt -check -recursive`（init 不要・トークン不要）
  - `tflint`: `terraform-linters/setup-tflint` + デフォルトルールセット
    （`.tflint.hcl` がある repo ではそれを使う）
  - `trivy`: `aquasecurity/trivy-action` の config スキャン（IaC 誤設定検知）
- TF バージョン方針: fmt/lint/trivy はバージョン非依存のため緩めで良い。
  `.terraform-version` があれば読む、無ければ未指定。

### 2. 各 repo の呼び出し側 workflow（Terraform で自動配置）

- 本 repo に `github_repository_file` を `for_each` で追加し、対象 repo 一覧（`locals`）を
  ループ配置。
- 内容は `templatefile()` で DRY に生成。中身は数行:

  ```yaml
  on:
    pull_request:
    push:
      branches: [main]
  jobs:
    ci:
      uses: haruka-aibara/github-actions/.github/workflows/terraform-ci.yml@main
  ```

- repo 追加時は `locals` のリストに 1 行足すだけ → 自動で CI が付く。
- `working-directory` が repo ごとに異なる場合は、`locals` をオブジェクトのリストにして
  per-repo に input を渡せるようにする。

## ロールアウト（段階展開）

1. `github-actions` repo を作り、reusable workflow を置く。
2. **まず 1 リポジトリでパイロット**（呼び出しファイルを 1 つだけ配置）して動作確認。
3. OK なら `locals` のリストに全 repo を入れて一斉展開。

## 既知のリスク（実装時に検証）

- **branch protection との競合**: `github_repository_file` はデフォルトブランチへ直接
  コミットする。required PR reviews / enforce_admins が有効な repo では、HCP Terraform の
  github トークンが直接 push を弾かれる可能性がある。→ パイロットで権限を確認し、
  必要なら App 権限や運用を調整する。
- **TF ディレクトリ構成の差異**: ルート直下か `terraform/` 配下かが repo ごとに異なる
  場合は `working-directory` input で吸収する。

## スコープ外（今回やらないこと）

- CI 内での `terraform plan` / `apply`（HCP Terraform が担当）。
- `terraform validate`（各 repo への TFC トークン配布が必要なため今回見送り）。
- 既存リポジトリのコード自体のフォーマット修正（CI 導入後に各 repo で対応）。
