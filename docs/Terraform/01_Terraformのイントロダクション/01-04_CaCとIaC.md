<!-- Space: harukaaibarapublic -->
<!-- Parent: 01_Terraformのイントロダクション -->
<!-- Title: CaC と IaC -->

# CaC（Configuration as Code）と IaC（Infrastructure as Code）

「Ansible でできるのに Terraform が必要なの？」「Terraform でサーバーの設定もできる？」という疑問が出たとき、IaC と CaC の違いを知っていると整理できる。似た言葉だが対象が違う。

---

## 何が違うか

| | IaC | CaC |
|---|---|---|
| 対象 | インフラの**作成・削除** | サーバーの**設定・状態** |
| やること | EC2 を建てる、VPC を作る | パッケージをインストール、設定ファイルを配置 |
| 代表ツール | Terraform, CloudFormation | Ansible, Chef, Puppet |

Terraform は「インフラを作る」が仕事。その中で動かすアプリの設定や OS の構成は対象外。

---

## 役割分担のイメージ

```
Terraform（IaC）: EC2 インスタンスを建てる
      ↓
Ansible（CaC）: そのサーバーに nginx をインストールして設定する
```

---

## 現代では CaC の出番が減っている

コンテナやイミュータブルインフラが普及したことで、「サーバーを Ansible で設定する」より「設定済みの Docker イメージを Terraform で起動する」パターンが主流になった。

設定が必要なら AMI に焼き込む、もしくはコンテナで管理する方が再現性が高い。CaC が必要になるのは、コンテナ化できないレガシーなサーバー管理など、特定の場面に絞られてきている。
