<!-- Space: harukaaibarapublic -->
<!-- Parent: 22_セキュリティ -->
<!-- Title: コンプライアンスと Sentinel -->

# コンプライアンスと Sentinel

Sentinel は HashiCorp が提供するポリシー as コードフレームワーク。HCP Terraform（旧 Terraform Cloud）と統合されており、apply の前にポリシーチェックを強制できる。

---

## Sentinel とは

Terraform の apply を「ゲート」として制御する仕組み。

```
Plan → Sentinel ポリシーチェック → Apply
                ↓
         違反があれば Abort
```

開発者がどんなコードを書いても、Sentinel ポリシーに違反するリソースは作れない。コンプライアンス・セキュリティルールをコードで強制できる。

---

## ポリシーの例

```python
# sentinel/require-tags.sentinel

import "tfplan/v2" as tfplan

# すべての EC2 インスタンスに Environment タグが必要
main = rule {
  all tfplan.resource_changes as _, rc {
    rc.type != "aws_instance" or
    rc.change.after.tags["Environment"] is not null
  }
}
```

---

## ポリシーの適用レベル

| レベル | 挙動 |
|---|---|
| `advisory` | 警告のみ。apply は続行 |
| `soft-mandatory` | デフォルトは Abort。権限を持つユーザーがオーバーライド可 |
| `hard-mandatory` | 絶対 Abort。オーバーライド不可 |

本番環境のセキュリティルールは `hard-mandatory` で強制するのが推奨。

---

## HCP Terraform でのセットアップ

1. HCP Terraform の Organization Settings → Policy Sets
2. GitHub からポリシーリポジトリを連携
3. 適用するワークスペースを選択

```
my-sentinel-policies/
├── sentinel.hcl         # ポリシーセットの設定
├── require-tags.sentinel
├── restrict-instance-types.sentinel
└── enforce-encryption.sentinel
```

---

## OPA（Open Policy Agent）との違い

Sentinel は HCP Terraform 専用。OSSの Terraform での代替は OPA + Conftest を使う。

```bash
# Conftest で OPA ポリシーをチェック
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
conftest test tfplan.json --policy policies/
```

`conftest` は CI で使える汎用ポリシー検証ツール。Rego 言語でポリシーを書く。

---

## コンプライアンスチェックのまとめ

| ツール | 対象 | 実行タイミング |
|---|---|---|
| tflint | コード品質 | PR / ローカル |
| Checkov / Trivy | IaC セキュリティ | PR / ローカル |
| Sentinel | apply の強制 | HCP Terraform でのみ |
| OPA + Conftest | ポリシーチェック | CI |

多くのチームは Checkov + CI 統合で十分。Sentinel は HCP Terraform を使っている組織向け。
