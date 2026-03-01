<!-- Space: harukaaibarapublic -->
<!-- Parent: 13_Stateの検査と修正 -->
<!-- Title: terraform state replace-provider -->

# terraform state replace-provider

State 内のリソースに紐づくプロバイダーを別のプロバイダーに置き換えるコマンド。プロバイダーの移行（フォーク・リネーム）時に使う。

---

## 基本的な使い方

```bash
terraform state replace-provider \
  registry.terraform.io/hashicorp/aws \
  registry.terraform.io/myorg/aws
```

---

## 使いどころ

**プロバイダーのフォーク移行**

コミュニティがメンテナンスするプロバイダーから公式プロバイダーに移行する場合や、カスタムプロバイダーに切り替える場合。

**プロバイダーのリネーム**

過去にプロバイダーの名前空間が変わったケース（例: `terraform-providers/aws` → `hashicorp/aws`）。

---

## 実行手順

```bash
# 1. バックアップ
terraform state pull > backup.tfstate

# 2. プロバイダー置き換え
terraform state replace-provider \
  -auto-approve \
  registry.terraform.io/hashicorp/aws \
  registry.terraform.io/neworg/aws

# 3. terraform.tf の required_providers も更新
# 4. terraform init -upgrade
# 5. terraform plan で差分確認
```

---

## 注意

- 置き換え前後のプロバイダーが同じスキーマを持っていることを確認する
- `plan` で想定外の差分が出る場合は、プロバイダー間の仕様の違いが原因
