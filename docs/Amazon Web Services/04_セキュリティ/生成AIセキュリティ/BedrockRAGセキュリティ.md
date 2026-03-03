<!-- Space: harukaaibarapublic -->
<!-- Parent: 生成AIセキュリティ -->
<!-- Title: Bedrock Knowledge Base の RAG セキュリティ -->

# Bedrock Knowledge Base の RAG セキュリティ

「営業部門が社内 AI で質問したら、人事の機密情報が回答に混じって返ってきた」——Knowledge Base（RAG）の素朴な実装にある、見落とされがちな落とし穴。

RAG はベクトル類似度検索でドキュメントを取ってくる仕組みで、**ベクトル検索自体には認可の概念がない**。全ドキュメントを1つの Knowledge Base に入れて誰でも検索できる状態にすると、ユーザーが権限を持たない情報でも、質問と意味的に近ければ検索結果に混入する。

---

## 問題が起きる構成

```
ユーザー A（営業）が「福利厚生の詳細を教えて」と質問
  ↓
Knowledge Base がベクトル類似度で検索
  ↓
「人事：給与テーブル（役員報酬含む）」ドキュメントがヒット（意味的に近いため）
  ↓
AI が役員の給与情報を含む回答を生成して返す
```

---

## 解決策：メタデータフィルタリング

Knowledge Base にドキュメントを取り込む際にメタデータを付与し、検索時にそのメタデータで絞り込む。

### ドキュメント取り込み時のメタデータ設定

S3 に格納するドキュメントと同じ場所に、同名の `.metadata.json` ファイルを置く。

```
s3://my-kb-bucket/
├── hr/salary-table.pdf
├── hr/salary-table.pdf.metadata.json
├── sales/product-catalog.pdf
└── sales/product-catalog.pdf.metadata.json
```

`hr/salary-table.pdf.metadata.json`：
```json
{
  "metadataAttributes": {
    "department": "hr",
    "classification": "confidential",
    "allowed_roles": "hr-managers,executives"
  }
}
```

`sales/product-catalog.pdf.metadata.json`：
```json
{
  "metadataAttributes": {
    "department": "sales",
    "classification": "internal",
    "allowed_roles": "all"
  }
}
```

### 検索時のフィルタ適用

`RetrieveAndGenerate` または `Retrieve` API 呼び出し時にフィルタを指定する。

```python
import boto3

client = boto3.client("bedrock-agent-runtime")

# ユーザーのロールはアプリ側で認証（Cognito 等）から取得する
# フィルタはクライアントから受け取るのではなく、サーバー側で生成する
user_department = get_user_department_from_jwt(token)  # 例: "sales"

response = client.retrieve_and_generate(
    input={"text": "福利厚生の詳細を教えて"},
    retrieveAndGenerateConfiguration={
        "type": "KNOWLEDGE_BASE",
        "knowledgeBaseConfiguration": {
            "knowledgeBaseId": "kb-xxxxxxxxxx",
            "modelArn": "arn:aws:bedrock:ap-northeast-1::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0",
            "retrievalConfiguration": {
                "vectorSearchConfiguration": {
                    "filter": {
                        "orAll": [
                            {
                                "equals": {
                                    "key": "department",
                                    "value": user_department
                                }
                            },
                            {
                                "equals": {
                                    "key": "allowed_roles",
                                    "value": "all"
                                }
                            }
                        ]
                    }
                }
            }
        }
    }
)
```

**重要：フィルタはサーバー側で生成する。** クライアント（ブラウザ・アプリ）が渡してきた値をそのままフィルタに使うと、攻撃者がフィルタを改ざんして権限外のデータを取得できる。ユーザーの認可情報は、Cognito の JWT や IAM の属性など**信頼できるソースから取得する**。

---

## テナント分離の2つのパターン

| パターン | 概要 | 向いているケース |
|---|---|---|
| **テナントごとに別 Knowledge Base** | 完全に分離。シンプルで安全 | テナント数が少ない。分離を絶対的に保証したい |
| **単一 Knowledge Base + メタデータフィルタ** | コスト効率が良い。フィルタの実装が必要 | テナント数が多い。コストを抑えたい |

メタデータフィルタリングは AWS が公式に推奨するパターンだが、**フィルタの実装バグが直接データ漏洩につながる**。実装後は、境界条件（管理者・ゲスト・未認証ユーザー等）のテストを必ず行う。

---

## S3 データソースのアクセス制御

Knowledge Base が参照する S3 バケットへのアクセスは、Knowledge Base の IAM ロール（サービスロール）に絞る。

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "bedrock.amazonaws.com"
      },
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::my-kb-bucket",
        "arn:aws:s3:::my-kb-bucket/*"
      ],
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "arn:aws:bedrock:ap-northeast-1:123456789012:knowledge-base/*"
        }
      }
    }
  ]
}
```

- `s3:DeleteObject` は付けない
- 人間のユーザーはバケットに直接アクセスしない（データは Knowledge Base 経由で参照）
- Amazon Macie で S3 バケット内の意図しない PII を定期的にスキャンする

---

## ベクトル取り込み前に PII を除去する（多層防御）

メタデータフィルタが唯一の防線では不十分な場合、**ドキュメントを S3 に入れる前に PII を除去する**。Amazon Comprehend の PII 検出と置換を前段に挟む構成：

```
ドキュメント → Comprehend で PII 検出・マスク → S3 → Knowledge Base
```

これにより、メタデータフィルタのバグが起きても、ベクトルストアに実際の PII が存在しないため漏洩が防げる。

```python
import boto3

comprehend = boto3.client("comprehend")

# PII を検出してマスクした版のテキストを作成
response = comprehend.contains_pii_entities(
    Text=document_text,
    LanguageCode="ja"
)

# PII が含まれていれば、該当箇所をマスクして S3 に保存
```

---

## 参考

- [Access control for vector stores using metadata filtering](https://aws.amazon.com/blogs/machine-learning/access-control-for-vector-stores-using-metadata-filtering-with-knowledge-bases-for-amazon-bedrock/)
- [Multi-tenancy in RAG applications with metadata filtering](https://aws.amazon.com/blogs/machine-learning/multi-tenancy-in-rag-applications-in-a-single-amazon-bedrock-knowledge-base-with-metadata-filtering/)
- [Authorizing access to data with RAG implementations (AWS Security Blog)](https://aws.amazon.com/blogs/security/authorizing-access-to-data-with-rag-implementations/)
- [Protect sensitive data in RAG applications with Amazon Bedrock](https://aws.amazon.com/blogs/machine-learning/protect-sensitive-data-in-rag-applications-with-amazon-bedrock/)
- [Guidance for Securing Sensitive Data in RAG Applications using Amazon Bedrock](https://aws.amazon.com/solutions/guidance/securing-sensitive-data-in-rag-applications-using-amazon-bedrock/)
