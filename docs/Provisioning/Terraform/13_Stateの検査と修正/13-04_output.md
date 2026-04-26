<!-- Space: harukaaibarapublic -->
<!-- Parent: 13_Stateの検査と修正 -->
<!-- Title: terraform output（State から取得） -->

# terraform output（State から出力値を取得）

apply した後に「インスタンスの ID 何番だっけ」「ALB の DNS は？」と毎回コンソールを開いている場合、`terraform output` で確認できる。スクリプトや CI/CD への値渡しにも使える。

---

## 基本的な使い方

```bash
# すべての出力を表示
terraform output

# 特定の出力を取得
terraform output instance_id

# JSON 形式で取得
terraform output -json
```

---

## スクリプトとの連携

```bash
# シェルスクリプトで値を取得
INSTANCE_ID=$(terraform output -raw instance_id)
echo "Instance: $INSTANCE_ID"

# JSON で全出力を取得して jq で処理
terraform output -json | jq -r '.instance_id.value'
```

`-raw` オプションは文字列型の出力を引用符なしで取得する（スクリプトで使いやすい）。

---

## CI/CD での活用

```yaml
- name: Get ALB DNS
  id: outputs
  run: echo "alb_dns=$(terraform output -raw alb_dns)" >> $GITHUB_OUTPUT

- name: Run smoke test
  run: curl -f https://${{ steps.outputs.outputs.alb_dns }}/health
```

---

## state pull と output の違い

| | `terraform output` | `terraform state pull` |
|---|---|---|
| 取得対象 | `output` ブロックで定義した値 | State ファイル全体 |
| 用途 | アプリやスクリプトへの値渡し | State の調査・バックアップ |
