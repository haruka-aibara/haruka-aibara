# iam-access-analyzer-policy-generate

IAM Access Analyzer のポリシー生成を試すためのモジュール。CloudTrail の証跡と保存先 S3 バケット、Access Analyzer がその証跡を読むためのサービスロールを作る。

旧リポジトリ `iam-access-analyzer-policy-generate` を履歴ごと取り込んだもの。過去の経緯は `git log -- modules/iam-access-analyzer-policy-generate` で辿れる。

## 使い方

```hcl
module "iam_access_analyzer_policy_generate" {
  source = "./modules/iam-access-analyzer-policy-generate"
}
```

ポリシー生成そのものは、apply 後にコンソールか `aws accessanalyzer start-policy-generation` で、作成したサービスロールと証跡を指定して実行する。
