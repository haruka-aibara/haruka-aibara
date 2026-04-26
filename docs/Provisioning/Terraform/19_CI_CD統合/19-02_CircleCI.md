<!-- Space: harukaaibarapublic -->
<!-- Parent: 19_CI_CD統合 -->
<!-- Title: CircleCI での Terraform -->

# CircleCI での Terraform

CircleCI で Terraform の plan / apply を自動化する構成。

---

## 基本的な config.yml

```yaml
version: 2.1

orbs:
  terraform: circleci/terraform@3.2.1

jobs:
  plan:
    executor: terraform/default
    steps:
      - checkout
      - terraform/init:
          path: ./infra
      - terraform/plan:
          path: ./infra

  apply:
    executor: terraform/default
    steps:
      - checkout
      - terraform/init:
          path: ./infra
      - terraform/apply:
          path: ./infra

workflows:
  terraform:
    jobs:
      - plan:
          filters:
            branches:
              ignore: main
      - apply:
          filters:
            branches:
              only: main
```

CircleCI の公式 Terraform Orb を使うと `init` / `plan` / `apply` がコマンド単位で使える。

---

## 認証情報の設定

CircleCI の Project Settings → Environment Variables で設定する。

| 変数名 | 内容 |
|---|---|
| `AWS_ACCESS_KEY_ID` | IAM アクセスキー |
| `AWS_SECRET_ACCESS_KEY` | IAM シークレットキー |
| `AWS_DEFAULT_REGION` | リージョン |

---

## plan 結果を PR にコメントする

CircleCI には GitHub PR コメントの仕組みが標準で弱いため、`terraform show -no-color tfplan` の結果を GitHub API で投稿するスクリプトを `local-exec` 代わりに使うか、`atlantis` などの専用ツールを検討する。

---

## Orb を使わない場合

```yaml
jobs:
  terraform-plan:
    docker:
      - image: hashicorp/terraform:1.7.0
    steps:
      - checkout
      - run:
          name: terraform init
          command: terraform -chdir=infra init
      - run:
          name: terraform plan
          command: terraform -chdir=infra plan -out=tfplan
```

Docker イメージで Terraform バージョンを固定できる。
