<!-- Space: harukaaibarapublic -->
<!-- Parent: 09_デプロイメント -->
<!-- Title: terraform apply -->

# terraform apply

plan の内容を実際に適用してインフラを作成・更新・削除するコマンド。

---

## 基本的な使い方

```bash
terraform apply
```

実行すると plan が表示され、`yes` の入力を求められる。`yes` を入力すると実際に変更が適用される。

---

## plan ファイルを使う（推奨）

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

`-out` で保存した plan を適用すると、plan と apply の間に状態が変わっても元の計画通りに実行できる。CI/CD では必ずこの方式を使う。

---

## よく使うオプション

```bash
# 確認プロンプトをスキップ（CI/CD での利用）
terraform apply -auto-approve

# 特定リソースだけ適用
terraform apply -target=aws_instance.web

# 変数を渡す
terraform apply -var="env=production"
```

---

## apply 後の状態

apply が完了すると `terraform.tfstate` が更新される。出力値があれば画面に表示される。

```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

instance_id = "i-0abc123def456"
public_ip   = "54.123.45.67"
```

---

## エラー時の挙動

apply 途中でエラーが発生した場合、すでに作成済みのリソースは State に残る。次回 apply 時に残りの差分が適用される。手動修正が必要な場合は State を確認してから対応する。
