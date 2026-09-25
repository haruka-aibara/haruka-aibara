# aws-cost-allocation-tags

AWS Billing のコスト配分タグ（`Project`）を有効化するモジュール。

旧リポジトリ `aws-cost-allocation-tags` を履歴ごと取り込んだもの。過去の経緯は `git log -- modules/aws-cost-allocation-tags` で辿れる。

## 使い方

```hcl
module "aws_cost_allocation_tags" {
  source = "./modules/aws-cost-allocation-tags"
}
```

コスト配分タグはアカウント単位の設定で、リージョンに依存しない。タグキーが一度でもリソースに付いていないと有効化できない。
