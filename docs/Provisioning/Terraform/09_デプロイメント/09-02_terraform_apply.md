<!-- Space: harukaaibarapublic -->
<!-- Parent: 09_デプロイメント -->
<!-- Title: terraform apply -->

# terraform apply

plan の内容を実際のインフラに反映するコマンド。apply する前に plan を必ず確認する。特に `-/+`（replace）が出ているリソースは要注意。

---

## 基本の流れ

```bash
terraform apply
```

plan が表示されてから `yes` の入力を求められる。`yes` を入力したら実際にクラウドへの変更が始まる。

---

## CI/CD では plan ファイルを使う

```bash
# plan を保存
terraform plan -out=tfplan

# 保存した plan だけを適用（確認プロンプトなし）
terraform apply tfplan
```

これにより「レビューした plan と違う内容が apply される」を防げる。plan と apply の間に誰かが別の変更を入れても、保存した plan の内容だけが実行される。

自動実行したい場合は `-auto-approve`：

```bash
terraform apply -auto-approve tfplan
```

---

## apply 後の出力

```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

instance_id = "i-0abc123def456"
public_ip   = "54.123.45.67"
```

---

## 途中でエラーになったとき

apply の途中でエラーが起きても、それまでに作成できたリソースは State に残る。次回 apply 時に残りの差分が適用される。

State と実態が想定外にズレている可能性があるので、`terraform state list` や `terraform show` で状態を確認してから次の手を考える。
