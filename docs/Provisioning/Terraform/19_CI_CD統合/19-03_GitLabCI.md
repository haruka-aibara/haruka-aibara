<!-- Space: harukaaibarapublic -->
<!-- Parent: 19_CI_CD統合 -->
<!-- Title: GitLab CI での Terraform -->

# GitLab CI での Terraform

GitLab CI/CD で Terraform の plan / apply を自動化する構成。GitLab には Terraform との統合機能が標準で含まれている。

---

## 基本的な .gitlab-ci.yml

```yaml
image:
  name: hashicorp/terraform:1.7.0
  entrypoint: [""]

variables:
  TF_ROOT: ${CI_PROJECT_DIR}/infra
  TF_ADDRESS: ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/production

cache:
  paths:
    - ${TF_ROOT}/.terraform

before_script:
  - cd ${TF_ROOT}
  - terraform init
    -backend-config="address=${TF_ADDRESS}"
    -backend-config="lock_address=${TF_ADDRESS}/lock"
    -backend-config="unlock_address=${TF_ADDRESS}/lock"
    -backend-config="username=gitlab-ci-token"
    -backend-config="password=${CI_JOB_TOKEN}"
    -backend-config="lock_method=POST"
    -backend-config="unlock_method=DELETE"
    -backend-config="retry_wait_min=5"

stages:
  - validate
  - plan
  - apply

validate:
  stage: validate
  script:
    - terraform validate

plan:
  stage: plan
  script:
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - ${TF_ROOT}/tfplan

apply:
  stage: apply
  script:
    - terraform apply -auto-approve tfplan
  when: manual
  only:
    - main
```

---

## GitLab の Terraform State バックエンド

GitLab には Terraform の State を保存する HTTP バックエンドが標準搭載されている。S3 なしで State 管理ができる。

```hcl
terraform {
  backend "http" {}
}
```

実際の設定は `CI_JOB_TOKEN` を使って CI 側で動的に渡す。

---

## 認証情報の設定

GitLab の Settings → CI/CD → Variables で設定する。

| 変数名 | Protected | Masked |
|---|---|---|
| `AWS_ACCESS_KEY_ID` | ✓ | ✓ |
| `AWS_SECRET_ACCESS_KEY` | ✓ | ✓ |

Protected にすると `main` などの保護ブランチでのみ使える。

---

## MR へのコメント

GitLab CI には `terraform show` の結果を MR（Merge Request）にコメントする機能が Terraform コンポーネントとして提供されている。

```yaml
include:
  - component: gitlab.com/components/opentofu/full-pipeline@main
    inputs:
      version: latest
      opentofu_version: 1.7.0
```

OpenTofu（Terraform の OSSフォーク）用だが、考え方は同様。
