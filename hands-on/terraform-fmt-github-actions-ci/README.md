## 参考記事

https://github.com/marketplace/actions/hashicorp-setup-terraform

https://www.bioerrorlog.work/entry/terraform-fmt-github-actions

https://book.st-hakky.com/hakky/check-terraform-fmt-by-github-actions/

## 最新の terraform version で terraform fmt -check -recursive を行う github-actions を作成する手順

1. .github/workflows/任意の名前.yml がなければリポジトリ内に作成し、以下の内容を入れる。
```yml
name: Terraform fmt checker

on: [push]

jobs:
  terraform-fmt-checker:
    name: Terraform fmt checker
    runs-on: ubuntu-latest

    defaults:
      run:
        shell: bash

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: HashiCorp - Setup Terraform
        uses: hashicorp/setup-terraform@v3.1.2

      - name: Terraform Format
        run: terraform fmt -recursive -check

```
