<!-- Space: harukaaibarapublic -->
<!-- Parent: 01_Terraformのイントロダクション -->
<!-- Title: Terraform とは -->

# Terraform とは

IaC ツールはいくつかあるが、「AWS だけ」「Azure だけ」に依存せず、複数クラウドやサービスを同じ書き方で管理したい場合に選ばれるのが Terraform。AWS の EC2 も、Datadog のアラートも、GitHub のリポジトリも、同じ `.tf` ファイルで管理できる。

---

## 基本の流れ

```
.tf ファイルにリソースを書く
    ↓
terraform plan   # 「何が変わるか」を事前確認
    ↓
terraform apply  # 実際に反映
```

`plan` で差分を確認してから `apply` するのが基本。意図しない変更が入っていないかを plan で必ず確認する。

---

## State ファイルの役割

Terraform は「今インフラがどういう状態か」を `terraform.tfstate` に記録する。plan のたびに State と実際のクラウドを照合して差分を計算する。

**チームで使うなら State はリモートに置く**。ローカルに State があると「別の人が apply したとき State が古い」問題が起きる。S3 + DynamoDB（State ロック）か HCP Terraform が定番。

---

## 3,000 以上のプロバイダー

[Terraform Registry](https://registry.terraform.io/browse/providers) にプロバイダーが公開されている。AWS・GCP・Azure・Kubernetes・Datadog・GitHub など主要サービスはほぼカバーされている。「このサービスを Terraform で管理できる？」と思ったらまずレジストリを検索する。

---

## OSS vs HCP Terraform

| | OSS | HCP Terraform |
|---|---|---|
| State 管理 | 自前（S3 など） | 自動 |
| 実行環境 | ローカル / CI | クラウド上 |
| 料金 | 無料 | 小規模なら無料 |

個人や小チームなら OSS で十分。「State の管理を楽にしたい」「CI の設定を減らしたい」なら HCP Terraform を検討する。
