# aws-budget-slack-notifier

AWS Budgets の日次コストが閾値を超えたら、SNS → AWS Chatbot 経由で Slack に通知するモジュール。

旧リポジトリ `terraform-aws-budget-slack-notifier` を履歴ごと取り込んだもの。過去の経緯は `git log -- modules/aws-budget-slack-notifier` で辿れる。

## 使い方

`aws` と `aws.us-east-1` の 2 つのプロバイダーを渡す。Budgets が us-east-1 のサービスなので、SNS トピックと KMS キーは us-east-1 に作る。

```hcl
module "aws_budget_slack_notifier" {
  source = "./modules/aws-budget-slack-notifier"

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }

  slack_channel_id           = var.budget_slack_channel_id
  slack_workspace_id         = var.budget_slack_workspace_id
  budgets_limit_amount_daily = 1
}
```

Slack ワークスペースは事前に AWS Chatbot のコンソールで認可しておく必要がある。

参考記事: https://zenn.dev/takehiro1111/articles/budget_slack_notify
