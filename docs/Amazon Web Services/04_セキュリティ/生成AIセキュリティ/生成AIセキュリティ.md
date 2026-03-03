<!-- Space: harukaaibarapublic -->
<!-- Parent: 04_セキュリティ -->
<!-- Title: 生成AIセキュリティ -->

# 生成AIセキュリティ（Bedrock）

Amazon Bedrock を社内展開するときに押さえるべきセキュリティ領域をまとめる。

---

## セキュリティの全体像

Bedrock を「とりあえず使えるようにした」状態には、複数の落とし穴がある。

| 領域 | 放置するとどうなるか |
|---|---|
| **ログ** | 誰が何を AI に聞いたか追跡できない |
| **IAM / モデルアクセス制御** | 禁止すべきモデル（DeepSeek 等）が使えてしまう |
| **Guardrails** | 機密情報が AI から流出する。プロンプトインジェクション攻撃が通る |
| **データプライバシー** | 「AWSに学習されているのでは」という不安に根拠を持って答えられない |
| **Knowledge Base / RAG** | 別の部署のドキュメントが AI の回答に混入する |

---

## 記事一覧

- [ログと AI セキュリティ監視](../検知と可視化/BedrockログとAIセキュリティ監視.md)
- [IAM とモデルアクセス制御](BedrockIAMとモデルアクセス制御.md)
- [Guardrails](BedrockGuardrails.md)
- [データプライバシー](Bedrockデータプライバシー.md)
- [Knowledge Base の RAG セキュリティ](BedrockRAGセキュリティ.md)
