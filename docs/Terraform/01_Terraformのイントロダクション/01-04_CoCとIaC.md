<!-- Space: harukaaibarapublic -->
<!-- Parent: 01_Terraformのイントロダクション -->
<!-- Title: CaC と IaC -->

# CaC（Configuration as Code）と IaC（Infrastructure as Code）

似た概念だが対象が異なる。混同されることが多いので整理する。

---

## IaC（Infrastructure as Code）

インフラのプロビジョニングをコードで管理する。サーバー・ネットワーク・ストレージなどの**作成・削除**を対象とする。

- Terraform, AWS CloudFormation, Pulumi

**例**: EC2 インスタンスを作成する、VPC を構築するといった操作。

---

## CaC（Configuration as Code）

プロビジョニング後のサーバーの**設定・状態管理**をコードで行う。

- Ansible, Chef, Puppet, SaltStack

**例**: OS パッケージのインストール、設定ファイルの配置、サービスの起動。

---

## 役割分担の整理

| フェーズ | 内容 | ツール例 |
|---|---|---|
| プロビジョニング | インフラを作る | Terraform |
| 構成管理 | サーバーを設定する | Ansible |

モダンなクラウド環境では、コンテナやイミュータブルインフラの普及により CaC の出番は減っている。EC2 を Ansible で設定する代わりに、設定済みの AMI や Docker イメージを Terraform で起動するパターンが主流。

---

## Terraform における位置づけ

Terraform は IaC ツール。サーバーの中身（OS 設定、アプリのデプロイ）は対象外。必要であれば Terraform でインフラを作った後に Ansible 等を組み合わせる。
