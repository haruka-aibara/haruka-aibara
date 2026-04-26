<!-- Space: harukaaibarapublic -->
<!-- Parent: 21_Terraformのスケーリング -->
<!-- Title: Infracost -->

# Infracost

Infracost は Terraform の plan 結果からクラウドコストを見積もるツール。PR の段階でコスト増減を把握できる。

---

## インストールと基本的な使い方

```bash
# macOS
brew install infracost

# API キーを設定（無料）
infracost auth login

# コスト見積もりを実行
infracost breakdown --path .
```

出力例：

```
Project: my-terraform

 Name                                     Quantity  Unit         Monthly Cost
 aws_instance.web
 ├─ Instance usage (Linux/UNIX, on-demand, t3.medium)  730  hours  $30.37
 └─ root_block_device
    └─ Storage (general purpose SSD, gp2)              20   GB     $2.00

 OVERALL TOTAL                                                      $32.37
```

---

## CI での diff 表示

PR を出したときにコスト変化を自動コメントする。

```bash
# 変更前のコストを計算
infracost breakdown --path . --format json \
  --out-file /tmp/infracost-base.json

# 変更後のコストを計算
infracost breakdown --path . --format json \
  --out-file /tmp/infracost-new.json

# 差分をテキストで表示
infracost diff \
  --path /tmp/infracost-new.json \
  --compare-to /tmp/infracost-base.json
```

GitHub Actions の場合：

```yaml
- name: Run Infracost
  uses: infracost/actions/setup@v3
  with:
    api-key: ${{ secrets.INFRACOST_API_KEY }}

- name: Generate Infracost diff
  run: |
    infracost diff \
      --path=. \
      --format=json \
      --compare-to=/tmp/infracost-base.json \
      --out-file=/tmp/infracost.json

- name: Post Infracost comment
  run: infracost comment github \
    --path=/tmp/infracost.json \
    --repo=$GITHUB_REPOSITORY \
    --github-token=${{ github.token }} \
    --pull-request=${{ github.event.pull_request.number }}
```

PR にこんなコメントが自動投稿される：

```
💰 Infracost estimate: monthly cost will increase by $45.00

┌──────────────────────────┬──────────────┬──────────────┐
│ Changed resource         │ Before       │ After        │
├──────────────────────────┼──────────────┼──────────────┤
│ aws_instance.app         │ $15.18/mo    │ $60.74/mo    │
└──────────────────────────┴──────────────┴──────────────┘
```

---

## 対応リソース

AWS・GCP・Azure の主要リソースに対応。対応していないリソースは「$0」として計上される（実際はコストがかかる可能性あり）。

---

## 活用場面

- `t3.micro → t3.xlarge` のような意図しないインスタンスタイプ変更を PR で発見
- 開発環境と本番環境のコスト差分を可視化
- 月次コスト予測の自動化
