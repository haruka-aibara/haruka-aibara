<!-- Space: harukaaibarapublic -->
<!-- Parent: 13_Stateの検査と修正 -->
<!-- Title: apply の -replace オプション -->

# apply の -replace オプション

特定のリソースを強制的に削除して再作成するオプション。EC2 インスタンスのリフレッシュや、State が壊れた場合の修復に使う。

---

## 基本的な使い方

```bash
terraform apply -replace=aws_instance.web
```

対象リソースを `-/+`（destroy + create）として扱い、apply を実行する。

---

## 旧来の方法（taint）との違い

v0.15 以前は `terraform taint` を使っていたが、v0.15.2 から `-replace` が推奨。

```bash
# 旧来（非推奨）
terraform taint aws_instance.web
terraform apply

# 現在の推奨
terraform apply -replace=aws_instance.web
```

`-replace` は plan の結果もすぐ確認できるため、`taint` より安全。

---

## 使いどころ

- EC2 インスタンスが不調で作り直したい（定義は変えない）
- AMI を更新したが `lifecycle.ignore_changes = [ami]` を設定していて自動で replace されない
- State とリアルの状態が乖離して apply に失敗し続けている

---

## 複数リソースを同時に指定

```bash
terraform apply \
  -replace=aws_instance.web \
  -replace=aws_instance.api
```

---

## plan で確認してから実行

```bash
terraform plan -replace=aws_instance.web
# -/+ で対象が表示されることを確認してから apply
terraform apply -replace=aws_instance.web
```
