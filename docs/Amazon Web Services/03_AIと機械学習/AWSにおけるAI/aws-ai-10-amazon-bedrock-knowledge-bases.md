# Amazon BedrockのKnowledge Bases

## 概要
Amazon BedrockのKnowledge Basesは、企業のデータやドキュメントを効率的に管理し、生成AIモデルと統合するための機能です。これにより、企業固有の知識を活用した正確で関連性の高い応答を生成することができます。

## 詳細

### Knowledge Basesの主な機能
- データソースの統合
  - S3バケット
  - Amazon OpenSearch Service
  - Amazon Aurora PostgreSQL
  - その他のデータソース
- 自動インデックス作成
  - テキストの分割
  - 埋め込みの生成
  - メタデータの抽出
- セマンティック検索
  - 意味的な類似性に基づく検索
  - ハイブリッド検索（キーワード + セマンティック）
- セキュリティとコンプライアンス
  - データの暗号化
  - アクセス制御
  - コンプライアンス対応

### 使用シーン
- 社内ナレッジベースの構築
- カスタマーサポートの自動化
- ドキュメント管理システム
- 研究開発の知識共有
- トレーニング資料の管理

## 具体例

### Knowledge Baseの作成と設定
```python
import boto3
import json
from typing import Dict, List

class KnowledgeBaseManager:
    def __init__(self):
        self.bedrock = boto3.client(
            service_name='bedrock',
            region_name='us-west-2'
        )

    def create_knowledge_base(self, 
                            name: str,
                            description: str,
                            role_arn: str) -> Dict:
        # Knowledge Baseの作成
        response = self.bedrock.create_knowledge_base(
            name=name,
            description=description,
            roleArn=role_arn,
            knowledgeBaseConfiguration={
                'type': 'VECTOR',
                'vectorKnowledgeBaseConfiguration': {
                    'embeddingModelArn': 'arn:aws:bedrock:region:account:model/amazon.titan-embed-text-v1'
                }
            },
            storageConfiguration={
                'type': 'OPENSEARCH_SERVERLESS',
                'opensearchServerlessConfiguration': {
                    'collectionArn': 'arn:aws:aoss:region:account:collection/collection-id',
                    'vectorIndexName': 'knowledge-base-index',
                    'fieldMapping': {
                        'vectorField': 'vector',
                        'textField': 'text',
                        'metadataField': 'metadata'
                    }
                }
            }
        )
        return response

    def add_data_source(self,
                       knowledge_base_id: str,
                       data_source_config: Dict) -> Dict:
        # データソースの追加
        response = self.bedrock.create_data_source(
            knowledgeBaseId=knowledge_base_id,
            name=data_source_config['name'],
            description=data_source_config['description'],
            dataSourceConfiguration={
                'type': data_source_config['type'],
                's3Configuration': {
                    'bucketArn': data_source_config['bucketArn'],
                    'inclusionPrefixes': data_source_config['inclusionPrefixes']
                }
            },
            roleArn=data_source_config['roleArn']
        )
        return response

# 使用例
manager = KnowledgeBaseManager()
kb_config = {
    'name': 'company-knowledge-base',
    'description': '企業のナレッジベース',
    'role_arn': 'arn:aws:iam::account:role/bedrock-knowledge-base-role'
}
knowledge_base = manager.create_knowledge_base(**kb_config)

data_source_config = {
    'name': 'product-docs',
    'description': '製品ドキュメント',
    'type': 'S3',
    'bucketArn': 'arn:aws:s3:::my-company-docs',
    'inclusionPrefixes': ['products/'],
    'roleArn': 'arn:aws:iam::account:role/bedrock-data-source-role'
}
data_source = manager.add_data_source(knowledge_base['knowledgeBaseId'], data_source_config)
```

### Knowledge Baseの検索と利用
```python
import boto3
import json
from typing import Dict, List

class KnowledgeBaseSearcher:
    def __init__(self, knowledge_base_id: str):
        self.bedrock = boto3.client(
            service_name='bedrock-runtime',
            region_name='us-west-2'
        )
        self.knowledge_base_id = knowledge_base_id

    def search(self, 
              query: str,
              top_k: int = 5,
              search_type: str = 'HYBRID') -> List[Dict]:
        # Knowledge Baseの検索
        response = self.bedrock.retrieve(
            knowledgeBaseId=self.knowledge_base_id,
            retrievalQuery=query,
            retrievalConfiguration={
                'vectorSearchConfiguration': {
                    'numberOfResults': top_k,
                    'searchType': search_type
                }
            }
        )
        return response['retrievalResults']

    def generate_response(self,
                         query: str,
                         search_results: List[Dict],
                         model_id: str = 'anthropic.claude-v2') -> str:
        # 検索結果を使用して応答を生成
        context = "\n".join([result['content'] for result in search_results])
        
        prompt = f"""以下の情報を参考に、質問に答えてください。

参考情報:
{context}

質問: {query}

回答:"""

        response = self.bedrock.invoke_model(
            modelId=model_id,
            body=json.dumps({
                "prompt": prompt,
                "max_tokens": 500,
                "temperature": 0.7
            })
        )
        return json.loads(response['body'].read())['completion']

# 使用例
searcher = KnowledgeBaseSearcher(knowledge_base['knowledgeBaseId'])
search_results = searcher.search("製品の省電力機能について教えてください")
response = searcher.generate_response(
    "製品の省電力機能について教えてください",
    search_results
)
```

### Knowledge Baseの管理と監視
```python
import boto3
import json
from typing import Dict, List

class KnowledgeBaseMonitor:
    def __init__(self, knowledge_base_id: str):
        self.bedrock = boto3.client(
            service_name='bedrock',
            region_name='us-west-2'
        )
        self.knowledge_base_id = knowledge_base_id

    def get_status(self) -> Dict:
        # Knowledge Baseのステータス取得
        response = self.bedrock.get_knowledge_base(
            knowledgeBaseId=self.knowledge_base_id
        )
        return response

    def list_data_sources(self) -> List[Dict]:
        # データソースの一覧取得
        response = self.bedrock.list_data_sources(
            knowledgeBaseId=self.knowledge_base_id
        )
        return response['dataSources']

    def get_data_source_status(self, data_source_id: str) -> Dict:
        # データソースのステータス取得
        response = self.bedrock.get_data_source(
            knowledgeBaseId=self.knowledge_base_id,
            dataSourceId=data_source_id
        )
        return response

    def update_data_source(self,
                          data_source_id: str,
                          update_config: Dict) -> Dict:
        # データソースの更新
        response = self.bedrock.update_data_source(
            knowledgeBaseId=self.knowledge_base_id,
            dataSourceId=data_source_id,
            name=update_config['name'],
            description=update_config['description'],
            dataSourceConfiguration=update_config['configuration']
        )
        return response

# 使用例
monitor = KnowledgeBaseMonitor(knowledge_base['knowledgeBaseId'])
status = monitor.get_status()
data_sources = monitor.list_data_sources()

# データソースの更新
update_config = {
    'name': 'updated-product-docs',
    'description': '更新された製品ドキュメント',
    'configuration': {
        'type': 'S3',
        's3Configuration': {
            'bucketArn': 'arn:aws:s3:::my-company-docs',
            'inclusionPrefixes': ['products/', 'updates/']
        }
    }
}
updated_source = monitor.update_data_source(
    data_sources[0]['dataSourceId'],
    update_config
)
```

## まとめ
Amazon BedrockのKnowledge Basesは、企業のデータを効率的に管理し、生成AIモデルと統合するための強力な機能を提供します。データソースの統合、自動インデックス作成、セマンティック検索などの機能により、企業固有の知識を活用した正確で関連性の高い応答を生成することができます。また、セキュリティとコンプライアンスの機能も備えており、企業の要件に合わせた安全な運用が可能です。Knowledge Basesを活用することで、社内ナレッジベースの構築、カスタマーサポートの自動化、ドキュメント管理システムの実装など、様々なユースケースに対応できます。 
