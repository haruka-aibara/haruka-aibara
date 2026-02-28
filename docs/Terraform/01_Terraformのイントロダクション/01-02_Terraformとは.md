<!-- Space: harukaaibarapublic -->
<!-- Parent: 01_Terraformのイントロダクション -->
<!-- Title: Terraform とは -->

# Terraform とは

HashiCorp が開発したオープンソースの IaC ツール。AWS / Azure / GCP などのクラウドリソースを HCL（HashiCorp Configuration Language）で定義し、コマンド一つでデプロイ・管理できる。

---

## 基本的な動作フロー

```
コードを書く (.tf ファイル)
    ↓
terraform plan   # 変更内容をプレビュー
    ↓
terraform apply  # 実際に適用
```

`plan` で差分を確認してから `apply` するのが基本。

---

## State ファイル

Terraform は現在のインフラ状態を `terraform.tfstate` に記録する。このファイルを元に「現状と定義の差分」を計算して apply 対象を決める。

チームで使う場合は S3 などのリモートバックエンドに保存するのが必須。

---

## Terraform OSS vs HCP Terraform（旧 Terraform Cloud）

| | OSS | HCP Terraform |
|---|---|---|
| 実行環境 | ローカル / CI | HashiCorp のクラウド |
| State 管理 | 自前 | 自動で管理 |
| 料金 | 無料 | 一定規模まで無料 |
| リモート実行 | なし | あり |

個人・小規模なら OSS で十分。チーム運用では HCP Terraform か自前の CI/CD で State を管理する。

---

## サポートするプロバイダー

[Terraform Registry](https://registry.terraform.io/browse/providers) に 3,000 以上のプロバイダーが公開されている。AWS / Azure / GCP / Kubernetes / Datadog など、ほぼすべての主要サービスをカバー。
