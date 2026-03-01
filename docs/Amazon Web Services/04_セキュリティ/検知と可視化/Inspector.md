<!-- Space: harukaaibarapublic -->
<!-- Parent: 検知と可視化 -->
<!-- Title: Amazon Inspector -->

# Amazon Inspector

「EC2 に古い OpenSSL が入ったまま本番稼働している」「ECR のコンテナイメージに CVE が含まれている」——パッチ適用が追いつかないのはよくある話だが、「どのインスタンスに何の脆弱性があるか」を把握していないのは論外。Inspector は EC2・ECR・Lambda を継続的にスキャンして脆弱性を自動検出する。

---

## スキャン対象

| リソース | 検出内容 |
|---|---|
| EC2 インスタンス | OS パッケージの CVE（SSM Agent 経由） |
| ECR コンテナイメージ | イメージ内パッケージの CVE |
| Lambda 関数 | コードの依存パッケージの CVE |

---

## 有効化

```bash
# Inspector v2 を有効化
aws inspector2 enable \
  --resource-types EC2 ECR LAMBDA

# 組織全体で有効化（管理アカウントから）
aws inspector2 enable-delegated-admin-account \
  --delegated-admin-account-id 123456789012
```

EC2 スキャンには Systems Manager Agent（SSM Agent）のインストールが必要。ECR・Lambda は設定だけで動く。

---

## 検出結果の確認

```bash
# CRITICAL の脆弱性を一覧
aws inspector2 list-findings \
  --filter-criteria '{
    "severities": [
      {"comparison": "EQUALS", "value": "CRITICAL"}
    ],
    "findingStatus": [
      {"comparison": "EQUALS", "value": "ACTIVE"}
    ]
  }'
```

検出結果は Security Hub に自動集約される。Security Hub の画面から一元確認できる。

---

## リスクスコアの見方

Inspector は各脆弱性に 0〜10 のスコアを付ける（Inspector Score）。CVSS スコアだけでなく、実際のネットワーク到達可能性（インターネットからアクセスできるか）や攻撃コードの存在有無を加味したスコアになっている。

CVSS 7.5（High）でもインターネットから到達不可なら Inspector Score は低くなる。優先度付けに使える。

---

## ECR へのプッシュ時スキャン

```bash
# ECR リポジトリでプッシュ時スキャンを有効化
aws ecr put-image-scanning-configuration \
  --repository-name my-app \
  --image-scanning-configuration scanOnPush=true
```

プッシュのたびに自動スキャンが走り、脆弱性があれば検出結果が記録される。Inspector を有効にしている場合は継続的にも再スキャンが走る（新しい CVE が公開されたときにも検出される）。

---

## EventBridge で新規検出を通知

```json
{
  "source": ["aws.inspector2"],
  "detail-type": ["Inspector2 Finding"],
  "detail": {
    "severity": ["CRITICAL", "HIGH"],
    "status": ["ACTIVE"]
  }
}
```

このルールで Slack や PagerDuty に通知を飛ばせる。「新しい CRITICAL 脆弱性が検出されたら即時通知」という運用が作れる。

---

## Suppression（抑制）の活用

誤検知や対応不要な脆弱性は抑制ルールで非表示にできる。

```bash
aws inspector2 create-filter \
  --action SUPPRESS \
  --filter-criteria '{
    "resourceTags": [{
      "comparison": "EQUALS",
      "key": "Environment",
      "value": "Development"
    }],
    "severities": [{"comparison": "EQUALS", "value": "LOW"}]
  }' \
  --name "suppress-dev-low"
```

開発環境の LOW 脆弱性を抑制する例。本番の CRITICAL に集中できる。
