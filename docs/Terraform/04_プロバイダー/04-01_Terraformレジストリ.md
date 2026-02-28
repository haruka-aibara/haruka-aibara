<!-- Space: harukaaibarapublic -->
<!-- Parent: 04_プロバイダー -->
<!-- Title: Terraform レジストリ -->

# Terraform レジストリ

[registry.terraform.io](https://registry.terraform.io) は Terraform の公式パッケージリポジトリ。プロバイダーとモジュールを検索・利用できる。

---

## プロバイダー

クラウドサービスや SaaS と Terraform をつなぐプラグイン。

```
registry.terraform.io/hashicorp/aws       # AWS（公式）
registry.terraform.io/hashicorp/google    # GCP（公式）
registry.terraform.io/hashicorp/azurerm   # Azure（公式）
registry.terraform.io/datadog/datadog     # Datadog（パートナー）
```

レジストリでプロバイダーを検索すると、対応リソース一覧・設定例・引数リファレンスが確認できる。

---

## モジュール

よく使われるパターンをまとめた再利用可能なコードセット。

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
  azs  = ["ap-northeast-1a", "ap-northeast-1c"]
}
```

`terraform-aws-modules` はコミュニティが管理する AWS 向けの人気モジュール群。本番利用前にコードを読んで内容を把握するのが望ましい。

---

## プロバイダーのティア

| ティア | 意味 |
|---|---|
| Official | HashiCorp が管理 |
| Partner | 各ベンダーが管理（HashiCorp 認定） |
| Community | コミュニティ管理 |

本番利用では Official または Partner を優先する。
