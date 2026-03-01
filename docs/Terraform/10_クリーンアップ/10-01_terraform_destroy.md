<!-- Space: harukaaibarapublic -->
<!-- Parent: 10_クリーンアップ -->
<!-- Title: terraform destroy -->

# terraform destroy

検証環境のコストを止めたい、作り直したいからいったん全部消したい——こういうときに使うのが `terraform destroy`。State に記録されているリソースをまとめて削除する。本番で誤実行すると取り返しがつかないため、実行前に `-target` での絞り込みや `prevent_destroy` の設定を確認する習慣をつけたい。

---

## 基本的な使い方

```bash
terraform destroy
```

削除対象のリソース一覧と確認プロンプトが表示される。`yes` を入力すると削除が実行される。

---

## 注意点

**本番環境での誤実行を防ぐ**

- `lifecycle { prevent_destroy = true }` を設定した重要リソースは destroy してもエラーになる
- `-target` で対象を絞ることができる

```bash
# 特定リソースのみ削除
terraform destroy -target=aws_instance.web
```

**削除順序**

Terraform は依存関係を考慮して逆順に削除する（依存されているリソースを最後に削除）。

---

## 代替手段: terraform apply で削除

`destroy` は実質的に以下と同じ。

```bash
terraform apply -destroy
```

plan ファイルと組み合わせる場合：

```bash
terraform plan -destroy -out=destroy.plan
terraform apply destroy.plan
```

---

## よく使うオプション

```bash
# 確認プロンプトをスキップ（CI/CD での利用）
terraform destroy -auto-approve

# 変数を渡す
terraform destroy -var-file="production.tfvars"
```

---

## 削除できないリソース

`prevent_destroy = true` が設定されているリソースは destroy 時にエラーになる。

```
Error: Instance cannot be destroyed
│
│ Resource aws_db_instance.main has lifecycle.prevent_destroy set,
│ but the plan calls for this resource to be destroyed.
```

意図して削除する場合は `prevent_destroy = false` に変更してから実行する。
