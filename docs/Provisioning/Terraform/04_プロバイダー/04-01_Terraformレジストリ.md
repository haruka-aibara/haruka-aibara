<!-- Space: harukaaibarapublic -->
<!-- Parent: 04_プロバイダー -->
<!-- Title: Terraform レジストリ -->

# Terraform レジストリ

「Terraform で Datadog のモニターを管理したい」「GitHub のリポジトリ設定をコード化したい」といったとき、自分でプラグインを書かなくていい。[registry.terraform.io](https://registry.terraform.io) に誰かが作ったプロバイダーやモジュールが公開されているので、それを使えば大抵のサービスを管理できる。

---

## プロバイダー

クラウドや SaaS と Terraform をつなぐプラグイン。使いたいサービスのプロバイダーを `terraform init` でインストールして使う。

```
hashicorp/aws       # AWS（公式）
hashicorp/google    # GCP（公式）
hashicorp/azurerm   # Azure（公式）
datadog/datadog     # Datadog（パートナー）
integrations/github # GitHub（パートナー）
```

レジストリのページで対応リソース一覧・引数リファレンス・設定例が確認できる。公式ドキュメントより実例が多くて参考になることも多い。

---

## プロバイダーのティア

| ティア | 管理者 | 信頼性 |
|---|---|---|
| Official | HashiCorp | 最高 |
| Partner | 各ベンダー（HashiCorp 認定） | 高い |
| Community | コミュニティ | 要確認 |

本番で使うなら Official か Partner を選ぶ。Community はコードを読んで問題ないか確認してから使う。

---

## モジュール

VPC を Terraform で作るとき、サブネット・ルートテーブル・NAT ゲートウェイなどを全部自分で書くと大変。レジストリのモジュールを使えば数行で済む。

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
  azs  = ["ap-northeast-1a", "ap-northeast-1c"]
}
```

`terraform-aws-modules` は AWS 関係者も関与する信頼性の高いモジュール群。ただし何が作られるかを理解した上で使う。ブラックボックスのまま本番に入れるのは避ける。
