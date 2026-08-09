# Amazon BedrockのRAGとKnowledge Bases

## 概要
Amazon BedrockのRAG（Retrieval Augmented Generation）とKnowledge Basesは、生成AIモデルに外部知識を組み込むための機能です。これにより、モデルは最新の情報や特定のドメイン知識に基づいた、より正確で関連性の高い応答を生成することができます。

## 詳細

### RAG（Retrieval Augmented Generation）
- 外部知識を検索して生成AIの応答を強化する手法
- 主な特徴：
  - リアルタイムの情報アクセス
  - ドメイン固有の知識の活用
  - 事実に基づいた応答の生成
- 使用シーン：
  - 最新情報が必要な応答
  - 企業固有の知識の活用
  - 正確性が重要な応答

### Knowledge Bases
- 構造化された知識リポジトリ
- 主な特徴：
  - 複数のデータソースの統合
  - 自動的なインデックス作成
  - セマンティック検索
- 使用シーン：
  - 企業ナレッジベースの構築
  - ドキュメント管理
  - カスタム知識の蓄積

## 具体例

### Knowledge Baseの作成と設定
```python
import boto3
import json

# Bedrockクライアントの初期化
bedrock = boto3.client(
    service_name='bedrock',
    region_name='us-west-2'
)

# Knowledge Baseの作成
knowledge_base = bedrock.create_knowledge_base(
    name='company-knowledge-base',
    description='企業のナレッジベース',
    roleArn='arn:aws:iam::account:role/BedrockKnowledgeBaseRole',
    knowledgeBaseConfiguration={
        'type': 'VECTOR',
        'vectorKnowledgeBaseConfiguration': {
            'embeddingModelArn': 'arn:aws:bedrock:region:account:model/amazon.titan-embed-text-v1'
        }
    },
    storageConfiguration={
        'type': 'S3',
        's3Configuration': {
            'bucketName': 'my-knowledge-base-bucket',
            'prefix': 'knowledge-base/'
        }
    }
)

# データソースの追加
data_source = bedrock.create_data_source(
    knowledgeBaseId=knowledge_base['knowledgeBaseId'],
    name='company-documents',
    description='企業ドキュメント',
    dataSourceConfiguration={
        'type': 'S3',
        's3Configuration': {
            'bucketName': 'my-documents-bucket',
            'prefix': 'documents/'
        }
    }
)
```

### RAGを使用した推論
```python
import boto3
import json

# Bedrockクライアントの初期化
bedrock = boto3.client(
    service_name='bedrock-runtime',
    region_name='us-west-2'
)

# RAGを使用した推論の実行
response = bedrock.invoke_model(
    modelId='anthropic.claude-v2',
    body=json.dumps({
        "prompt": "当社の製品ポリシーについて説明してください。",
        "max_tokens": 500,
        "temperature": 0.7,
        "knowledgeBaseConfig": {
            "knowledgeBaseId": "kb-123456789",
            "retrievalConfiguration": {
                "vectorSearchConfiguration": {
                    "numberOfResults": 3,
                    "overrideSearchType": "HYBRID"
                }
            }
        }
    })
)

# レスポンスの処理
response_body = json.loads(response['body'].read())
generated_text = response_body['completion']
```

### カスタムRAGパイプラインの実装
```python
import boto3
import json
from typing import List, Dict

class BedrockRAGPipeline:
    def __init__(self, knowledge_base_id: str):
        self.bedrock = boto3.client(
            service_name='bedrock-runtime',
            region_name='us-west-2'
        )
        self.knowledge_base_id = knowledge_base_id

    def retrieve_relevant_documents(self, query: str) -> List[Dict]:
        # 関連ドキュメントの検索
        response = self.bedrock.retrieve(
            knowledgeBaseId=self.knowledge_base_id,
            retrievalQuery=query,
            retrievalConfiguration={
                "vectorSearchConfiguration": {
                    "numberOfResults": 5,
                    "overrideSearchType": "HYBRID"
                }
            }
        )
        return response['retrievalResults']

    def generate_response(self, query: str, context: List[Dict]) -> str:
        # コンテキストを含めたプロンプトの作成
        context_text = "\n".join([doc['content'] for doc in context])
        prompt = f"""以下の情報を参考に、質問に答えてください。

参考情報:
{context_text}

質問: {query}"""

        # 推論の実行
        response = self.bedrock.invoke_model(
            modelId='anthropic.claude-v2',
            body=json.dumps({
                "prompt": prompt,
                "max_tokens": 500,
                "temperature": 0.7
            })
        )
        return json.loads(response['body'].read())['completion']

    def process_query(self, query: str) -> str:
        # 関連ドキュメントの検索
        relevant_docs = self.retrieve_relevant_documents(query)
        # 応答の生成
        return self.generate_response(query, relevant_docs)

# 使用例
rag_pipeline = BedrockRAGPipeline('kb-123456789')
response = rag_pipeline.process_query("当社の新製品の特徴は何ですか？")
```

## まとめ
Amazon BedrockのRAGとKnowledge Basesは、生成AIの応答品質を大幅に向上させる重要な機能です。Knowledge Basesを使用することで、企業のナレッジを効果的に管理し、RAGを活用することで、その知識を生成AIの応答に組み込むことができます。これにより、より正確で、関連性の高い、そして最新の情報に基づいた応答を生成することが可能になります。また、これらの機能はカスタマイズ可能で、様々なユースケースに合わせて最適化することができます。 
