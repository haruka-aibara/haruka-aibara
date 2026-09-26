# generate-dev-io-summary

DevelopersIO に前日投稿された記事を要約して、毎朝 6:30 頃に Slack へ通知するモジュール。EventBridge で scraper Lambda が記事 URL を SQS に積み、summarizer Lambda が Bedrock で PREP 法の要約を作って SNS → AWS Chatbot 経由で Slack に流す。

![image](https://github.com/user-attachments/assets/1aa0052e-ce90-41da-be98-f320f598cadb)

旧リポジトリ `generate-dev-io-summary` を履歴ごと取り込んだもの。過去の経緯は `git log -- modules/generate-dev-io-summary` で辿れる。

## 使い方

```hcl
module "generate_dev_io_summary" {
  source = "./modules/generate-dev-io-summary"

  slack_channel_id   = var.generate_dev_io_summary_slack_channel_id
  slack_workspace_id = var.generate_dev_io_summary_slack_workspace_id
}
```

Slack ワークスペースは事前に AWS Chatbot のコンソールで認可しておく必要がある。

Lambda Layer の中身（`requirements.txt` の requests / beautifulsoup4）はコミットしない。plan のたびに `build_layer.py` が `requirements.txt` から pip で `.build/lambda_layer` に作るので、バージョンを変えるときは `requirements.txt` だけを直す。

参考記事: https://dev.classmethod.jp/articles/generate-dev-io-summary/
