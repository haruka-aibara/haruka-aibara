# Amazon Bedrockのベクトルデータベース

## 概要
Amazon Bedrockのベクトルデータベースは、テキストや画像などのデータをベクトル表現に変換し、効率的に検索・管理するための機能です。これにより、セマンティック検索や類似性検索を実現し、RAGシステムの基盤として重要な役割を果たします。

## 詳細

### ベクトルデータベースの特徴
- 高次元ベクトルの効率的な保存と検索
- 主な機能：
  - セマンティック検索
  - 類似性検索
  - ハイブリッド検索（キーワード + セマンティック）
- 使用シーン：
  - ドキュメント検索
  - 画像検索
  - レコメンデーションシステム

### サポートされるベクトルDB
- Amazon OpenSearch Service
- Amazon Aurora PostgreSQL
- Amazon Neptune
- Amazon DocumentDB
- その他サードパーティのベクトルDB

## 具体例

### ベクトルDBの設定
```python
import boto3
import json

# Bedrockクライアントの初期化
bedrock = boto3.client(
    service_name='bedrock',
    region_name='us-west-2'
)

# ベクトルDBの設定
vector_db_config = bedrock.create_vector_database_configuration(
    name='my-vector-db',
    description='製品ドキュメント用ベクトルDB',
    vectorDatabaseType='OPENSEARCH',
    configuration={
        'endpoint': 'https://my-opensearch-domain.region.es.amazonaws.com',
        'indexName': 'product-documents',
        'embeddingModelArn': 'arn:aws:bedrock:region:account:model/amazon.titan-embed-text-v1',
        'dimensions': 1536
    }
)
```

### ドキュメントのインデックス作成
```python
import boto3
import json

# Bedrockクライアントの初期化
bedrock = boto3.client(
    service_name='bedrock',
    region_name='us-west-2'
)

# ドキュメントのベクトル化とインデックス作成
def index_document(document_id: str, content: str):
    # テキストのベクトル化
    embedding_response = bedrock.invoke_model(
        modelId='amazon.titan-embed-text-v1',
        body=json.dumps({
            "inputText": content
        })
    )
    embedding = json.loads(embedding_response['body'].read())['embedding']

    # ベクトルDBへの保存
    bedrock.index_document(
        vectorDatabaseId=vector_db_config['vectorDatabaseId'],
        documentId=document_id,
        content=content,
        embedding=embedding,
        metadata={
            'title': '製品仕様書',
            'category': '技術文書',
            'created_at': '2024-03-20'
        }
    )

# 使用例
document = {
    'id': 'doc-001',
    'content': 'この製品は高性能なAIチップを搭載し、低消費電力で動作します。'
}
index_document(document['id'], document['content'])
```

### セマンティック検索の実装
```python
import boto3
import json
from typing import List, Dict

class VectorDBSearcher:
    def __init__(self, vector_db_id: str):
        self.bedrock = boto3.client(
            service_name='bedrock',
            region_name='us-west-2'
        )
        self.vector_db_id = vector_db_id

    def semantic_search(self, query: str, top_k: int = 5) -> List[Dict]:
        # クエリのベクトル化
        embedding_response = self.bedrock.invoke_model(
            modelId='amazon.titan-embed-text-v1',
            body=json.dumps({
                "inputText": query
            })
        )
        query_embedding = json.loads(embedding_response['body'].read())['embedding']

        # ベクトル検索の実行
        search_response = self.bedrock.search(
            vectorDatabaseId=self.vector_db_id,
            queryEmbedding=query_embedding,
            searchConfiguration={
                'topK': top_k,
                'searchType': 'SEMANTIC',
                'scoreThreshold': 0.7
            }
        )
        return search_response['results']

    def hybrid_search(self, query: str, top_k: int = 5) -> List[Dict]:
        # ハイブリッド検索の実行
        search_response = self.bedrock.search(
            vectorDatabaseId=self.vector_db_id,
            queryText=query,
            searchConfiguration={
                'topK': top_k,
                'searchType': 'HYBRID',
                'scoreThreshold': 0.7,
                'keywordWeight': 0.3,
                'semanticWeight': 0.7
            }
        )
        return search_response['results']

# 使用例
searcher = VectorDBSearcher(vector_db_config['vectorDatabaseId'])
results = searcher.semantic_search("省電力なAIチップの特徴は？")
```

### ベクトルDBの管理
```python
import boto3
import json

# Bedrockクライアントの初期化
bedrock = boto3.client(
    service_name='bedrock',
    region_name='us-west-2'
)

# インデックスの最適化
def optimize_index():
    bedrock.optimize_index(
        vectorDatabaseId=vector_db_config['vectorDatabaseId'],
        optimizationConfiguration={
            'type': 'FULL',
            'schedule': 'WEEKLY'
        }
    )

# インデックスのバックアップ
def backup_index():
    bedrock.backup_index(
        vectorDatabaseId=vector_db_config['vectorDatabaseId'],
        backupConfiguration={
            'type': 'FULL',
            'destination': 's3://my-backup-bucket/vector-db-backups/'
        }
    )

# インデックスの監視
def monitor_index():
    metrics = bedrock.get_index_metrics(
        vectorDatabaseId=vector_db_config['vectorDatabaseId'],
        metrics=['QUERY_LATENCY', 'INDEX_SIZE', 'DOCUMENT_COUNT']
    )
    return metrics
```

## まとめ
Amazon Bedrockのベクトルデータベースは、効率的なセマンティック検索と類似性検索を実現するための重要な機能です。複数のベクトルDBオプションをサポートし、柔軟な設定と管理が可能です。RAGシステムの基盤として、より正確で関連性の高い検索結果を提供し、生成AIの応答品質を向上させることができます。また、スケーラビリティとパフォーマンスの最適化のための機能も提供されており、エンタープライズレベルのアプリケーション開発に適しています。 
