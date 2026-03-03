<!-- Space: harukaaibarapublic -->
<!-- Parent: 生成AIセキュリティ -->
<!-- Title: Bedrock IAM とモデルアクセス制御 -->

# Bedrock IAM とモデルアクセス制御

「DeepSeek が Bedrock に追加された。うちの組織では使わせたくないが、どう止めるか」「開発者ロールが `bedrock:*` を持っていて、高コストなモデルを誰でも呼べる状態になっている」——Bedrock を使い始めると、IAM の設計が後手に回ることが多い。

Bedrock の IAM には通常の AWS サービスと違う設計ポイントが2つある。**モデル ID をリソースとして制御できること**と、**SCP でモデルファミリーを組織全体に封鎖できること**。この2つを使いこなすと、ガバナンスのレベルが大きく変わる。

---

## 最低限押さえる IAM アクション

Bedrock の主要な IAM アクションは以下。`bedrock:InvokeModel` と `bedrock:Converse` が推論の入口で、ここを絞ることが最重要。

| アクション | 意味 |
|---|---|
| `bedrock:InvokeModel` | モデルを同期呼び出しする（最も重要） |
| `bedrock:InvokeModelWithResponseStream` | ストリーミング呼び出し |
| `bedrock:Converse` / `bedrock:ConverseStream` | マルチターン会話 API |
| `bedrock:ApplyGuardrail` | Guardrails を適用 |
| `bedrock:CreateModelInvocationJob` | バッチ推論ジョブの作成 |

`bedrock:*` をそのまま付けると、Guardrails の削除や Model Invocation Logging の設定変更まで含まれる。アプリケーション用ロールは推論アクションのみに絞る。

---

## モデル ID をリソースとして制限する

`bedrock:InvokeModel` はリソースレベルの制御に対応している。特定のモデルだけ許可する書き方：

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream",
        "bedrock:Converse",
        "bedrock:ConverseStream"
      ],
      "Resource": [
        "arn:aws:bedrock:ap-northeast-1::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0",
        "arn:aws:bedrock:ap-northeast-1::foundation-model/anthropic.claude-3-haiku-20240307-v1:0"
      ]
    }
  ]
}
```

ワイルドカードで許可してしまうと、後から追加されたモデル（DeepSeek, Meta Llama 等）も自動で使えるようになる。**許可したいモデルを明示する**のが安全。

---

## SCP で組織全体にモデル制限をかける

IAM ポリシーはアカウントごとの設定で、管理が分散する。組織全体のガバナンスには SCP を使う。

SCP の Deny + NotResource で「承認済みモデル以外を禁止」するパターン：

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowOnlyApprovedModels",
      "Effect": "Deny",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream",
        "bedrock:Converse",
        "bedrock:ConverseStream"
      ],
      "NotResource": [
        "arn:aws:bedrock:*::foundation-model/amazon.*",
        "arn:aws:bedrock:*::foundation-model/anthropic.*"
      ]
    }
  ]
}
```

特定モデルだけ禁止したい場合（DeepSeek を組織全体でブロックする例）：

```json
{
  "Sid": "DenyDeepseekEverywhere",
  "Effect": "Deny",
  "Action": "bedrock:*",
  "Resource": "arn:aws:bedrock:*::foundation-model/deepseek.*"
}
```

AWS Organizations の SCP サンプルとして [Example SCPs for Amazon Bedrock](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps_examples_bedrock.html) に公式掲載されているパターン。SCP の `NotResource` 構文は 2025 年に一般公開された完全 IAM 言語サポートで使えるようになった。

---

## 注意：長期クレデンシャルは SCP をすり抜けることがある

SCP で制御しても、**IAM ユーザーの長期アクセスキー**には特定の条件下で SCP の適用に穴がある（Sonrai Security が 2026 年に公開した調査で確認）。

これは IAM ユーザー + 長期アクセスキーという構成そのものの問題。Bedrock を使うロールは IAM ロール + 一時認証情報（IAM Identity Center / OIDC / AssumeRole）にする。長期アクセスキーはゼロにする方向で進める。

---

## Application Inference Profile でチーム別に追跡する

IAM とは別のレイヤーだが、**Application Inference Profile（AIP）** を使うとチーム・アプリ・用途ごとにコストと利用量を分離できる。

```bash
# チームごとに AIP を作成
aws bedrock create-inference-profile \
  --inference-profile-name "team-security-claude-sonnet" \
  --description "Security team Bedrock usage" \
  --model-source '{"copyFrom": "arn:aws:bedrock:ap-northeast-1::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0"}' \
  --tags '{"Team": "security", "Environment": "production"}'
```

AIP を経由した呼び出しには `Team: security` タグが付くので、AWS Cost Explorer で「どのチームがいくら使ったか」を把握できる。AWS Budgets と組み合わせると、チーム別の予算超過アラートも設定できる。

---

## ビジネス側への伝え方

| 技術的な言い方 | ビジネス側に刺さる言い方 |
|---|---|
| `bedrock:*` の wildcard が危険 | 開発者アカウントが侵害された場合、攻撃者がコスト無制限でモデルを呼べる状態になっている |
| SCP でモデルをブロックする | DeepSeek などデータポリシー未確認のモデルが、何も設定しなければ全社員が使えてしまう |
| AIP でチーム別追跡 | 生成AI コストが月末に誰のせいかわからなくなる前に、タグで分離しておく |

---

## 参考

- [Implementing least privilege access for Amazon Bedrock](https://aws.amazon.com/blogs/security/implementing-least-privilege-access-for-amazon-bedrock/)
- [Example SCPs for Amazon Bedrock](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps_examples_bedrock.html)
- [SCP が完全 IAM 言語をサポート](https://aws.amazon.com/blogs/security/unlock-new-possibilities-aws-organizations-service-control-policy-now-supports-full-iam-language/)
- [Bedrock IAM Service Authorization Reference](https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonbedrock.html)
- [Track, allocate, and manage your generative AI cost with Amazon Bedrock](https://aws.amazon.com/blogs/machine-learning/track-allocate-and-manage-your-generative-ai-cost-and-usage-with-amazon-bedrock/)
- [Implementing DeepSeek AI model restrictions across your AWS organization](https://repost.aws/articles/AROjoxvT7dR-aPBCuLBpVclg/implementing-deepseek-ai-model-restrictions-across-your-aws-organization)
