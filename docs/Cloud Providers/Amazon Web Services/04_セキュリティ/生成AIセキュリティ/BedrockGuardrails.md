<!-- Space: harukaaibarapublic -->
<!-- Parent: 生成AIセキュリティ -->
<!-- Title: Bedrock Guardrails -->

# Bedrock Guardrails

「AI が社員の機密情報を含んだ回答を返してしまった」「ユーザーがプロンプトを操作して、業務外のことを AI に実行させた」——Guardrails は AI の入出力に対してコンテンツフィルタリングをかけるサービス。有効化しておかないと、AI が何を返しても止める手段がない。

ただし **Guardrails を入れれば安全になる、ではない**。何を守れて、何を守れないかを正確に理解することが先。

---

## Guardrails が守るもの（6 つのポリシー）

| ポリシー | 何をするか |
|---|---|
| **コンテンツフィルタ** | ヘイトスピーチ・暴力・性的コンテンツ・侮辱・不正行為を検出してブロック。強度（なし/低/中/高）をカテゴリ別に設定 |
| **プロンプト攻撃検出** | ジェイルブレーク・直接プロンプトインジェクション・プロンプトリーク（Standard ティアのみ）を ML で分類 |
| **拒否トピック** | 「競合製品については話さない」などのトピックをセマンティック検索で遮断。完全一致ではなく意味で判断 |
| **個人情報（PII）フィルタ** | SSN・クレジットカード・電話番号・メールアドレス等 30+ 種の PII を検出またはマスク。コード内（変数名・コメント・ハードコード）の PII も対象 |
| **グラウンディングチェック** | RAG 用。モデルの回答が参照ドキュメントに基づいているか検証し、ハルシネーションを検出 |
| **ワードフィルタ** | 特定の単語や表現を完全一致でブロック。コンテンツフィルタより単純で、ブランド保護用途向け |

---

## Guardrails を有効化する

```bash
# Guardrails を作成
aws bedrock create-guardrail \
  --name "enterprise-guardrail" \
  --description "Enterprise default guardrail" \
  --content-policy-config '{
    "filtersConfig": [
      {"type": "HATE", "inputStrength": "HIGH", "outputStrength": "HIGH"},
      {"type": "VIOLENCE", "inputStrength": "MEDIUM", "outputStrength": "HIGH"},
      {"type": "SEXUAL", "inputStrength": "HIGH", "outputStrength": "HIGH"},
      {"type": "MISCONDUCT", "inputStrength": "HIGH", "outputStrength": "HIGH"},
      {"type": "PROMPT_ATTACK", "inputStrength": "HIGH", "outputStrength": "NONE"}
    ]
  }' \
  --sensitive-information-policy-config '{
    "piiEntitiesConfig": [
      {"type": "EMAIL", "action": "ANONYMIZE"},
      {"type": "PHONE", "action": "ANONYMIZE"},
      {"type": "CREDIT_DEBIT_CARD_NUMBER", "action": "BLOCK"},
      {"type": "AWS_ACCESS_KEY", "action": "BLOCK"},
      {"type": "AWS_SECRET_KEY", "action": "BLOCK"}
    ]
  }' \
  --blocked-input-messaging "この質問には回答できません" \
  --blocked-outputs-messaging "この回答はポリシーに違反するため表示できません" \
  --guardrail-policy-config '{
    "filtersConfig": [
      {"type": "GROUNDING", "threshold": 0.75}
    ]
  }'
```

作成した Guardrail は `InvokeModel` や `Converse` の呼び出し時に ID と Version を渡して適用する。

```python
import boto3

client = boto3.client("bedrock-runtime")
response = client.converse(
    modelId="anthropic.claude-3-5-sonnet-20241022-v2:0",
    guardrailConfig={
        "guardrailIdentifier": "arn:aws:bedrock:ap-northeast-1:123456789012:guardrail/xxxx",
        "guardrailVersion": "DRAFT",
        "trace": "enabled"  # ブロック理由をレスポンスに含める
    },
    messages=[{"role": "user", "content": [{"text": "..."}]}]
)
```

---

## Guardrails が守れないもの（ここが重要）

Guardrails を入れれば終わり、ではない。以下は明確な守備範囲外。

**① IAM の代わりにはならない**

Guardrails はモデルが「何を言うか」を制御するが、「誰が呼べるか」は IAM が管轄。IAM 権限を持った内部の人間がアプリを経由せずに API を直接叩けば、Guardrails をすり抜けて自由にモデルを使える。

**② リーズニングコンテンツブロックは対象外**

Claude の Extended Thinking（拡張推論）モードで出力される推論トレース（思考過程）は Guardrails の評価対象外。推論過程に機密情報が含まれていても検出・マスクされない。

**③ 高度な間接プロンプトインジェクションは通り抜ける**

プロンプト攻撃検出は ML 分類なので、巧妙に設計された多段階・間接的なインジェクション（RAG ドキュメントに埋め込まれた指示など）を 100% 止めるわけではない。

**④ モデルが記憶している訓練データは止められない**

ファウンデーションモデルが学習データを「記憶」している場合、その内容を呼び出されても Guardrails は特定パターンにマッチしない限り止めない。

**⑤ エージェントのツール呼び出しパラメータに盲点がある**

Bedrock Agents でツールが返してきた外部データが次のアクションに渡される経路は、開発者が明示的にタグ付けしない限り Guardrails の評価対象にならない場合がある。

---

## Standard ティア vs Classic ティア

エンタープライズ用途では **Standard ティア** を使う。

| 機能 | Classic | Standard |
|---|---|---|
| コンテンツフィルタ | ✓ | ✓ |
| PII フィルタ | ✓ | ✓ |
| 拒否トピック | ✓ | ✓ |
| プロンプト攻撃検出 | 部分 | ✓（プロンプトリーク含む） |
| グラウンディングチェック | ✗ | ✓ |
| 自動推論チェック | ✗ | ✓ |

---

## 組織レベルで Guardrails を強制適用する（Enforced Guardrails）

個別アプリが Guardrails を付け忘れても確実に適用する仕組みがある。Bedrock の組織管理機能で、**アカウントレベルの Enforced Guardrail** を設定すると、そのアカウント内のすべての Bedrock 呼び出しに自動で適用される。

```bash
# 組織レベルで Guardrail を強制適用
aws bedrock put-guardrail-enforcement \
  --target-id "123456789012" \
  --target-type "AWS_ACCOUNT" \
  --guardrail-identifier "arn:aws:bedrock:ap-northeast-1:123456789012:guardrail/xxxx" \
  --guardrail-version "1"
```

アプリレベル・アカウントレベル・組織レベルと複数の Guardrail がある場合、すべてが同時に評価され、**最も厳しい制御が優先**される。

---

## ビジネス側への伝え方

| 技術的な言い方 | ビジネス側に刺さる言い方 |
|---|---|
| PII フィルタを有効化する | 社員が社内 AI に顧客情報を貼り付け、その回答が別の社員に見えてしまうリスクを防ぐ |
| 拒否トピックを設定する | 「競合製品の評価をしてください」など、社内 AI にさせるべきでない用途を技術的に制限できる |
| プロンプト攻撃検出を有効化する | ユーザーが AI をジェイルブレークして、安全装置を無効化するのを防ぐ |

---

## 参考

- [Bedrock Guardrails — 公式ドキュメント](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html)
- [Build safe generative AI applications: Best Practices with Amazon Bedrock Guardrails](https://aws.amazon.com/blogs/machine-learning/build-safe-generative-ai-applications-like-a-pro-best-practices-with-amazon-bedrock-guardrails/)
- [Guardrails for Amazon Bedrock — AI Safety & Compliance Guide (Lasso Security)](https://www.lasso.security/blog/guardrails-for-amazon-bedrock)
- [Apply cross-account safeguards with Amazon Bedrock Guardrails enforcements](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-enforcements.html)
- [Amazon Bedrock Guardrails expands support for code domain](https://aws.amazon.com/blogs/machine-learning/amazon-bedrock-guardrails-expands-support-for-code-domain/)
