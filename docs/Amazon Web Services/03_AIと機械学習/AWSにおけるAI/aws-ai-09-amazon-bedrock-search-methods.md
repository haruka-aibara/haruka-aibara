# Amazon Bedrockの検索方法：ベクトル検索とキーワード検索

## 概要
Amazon Bedrockでは、データの検索方法としてベクトル検索（セマンティック検索）とキーワード検索（全文検索）の2つの主要なアプローチを提供しています。これらの検索方法は、それぞれ異なる特徴と利点を持ち、ユースケースに応じて適切に選択・組み合わせることができます。

## 詳細

### ベクトル検索（セマンティック検索）
- 特徴
  - 意味的な類似性に基づく検索
  - 同義語や関連概念の理解
  - 文脈を考慮した検索結果
- 利点
  - より直感的な検索結果
  - キーワードの完全一致を必要としない
  - 多言語対応

### キーワード検索（全文検索）
- 特徴
  - テキストの完全一致や部分一致による検索
  - ブール演算子の使用（AND, OR, NOT）
  - ワイルドカード検索
- 利点
  - 高速な検索処理
  - 正確なキーワードマッチング
  - シンプルな実装

### ハイブリッド検索
- ベクトル検索とキーワード検索の組み合わせ
- 両方の利点を活かした検索結果
- 重み付けによる検索結果の調整

## 具体例

### ベクトル検索の実装
```python
import boto3
import json
from typing import List, Dict

class VectorSearcher:
    def __init__(self):
        self.bedrock = boto3.client(
            service_name='bedrock-runtime',
            region_name='us-west-2'
        )

    def search(self, query: str, documents: List[str], top_k: int = 5) -> List[Dict]:
        # クエリの埋め込みを取得
        query_embedding = self._get_embedding(query)
        
        # ドキュメントの埋め込みを取得
        document_embeddings = self._get_batch_embeddings(documents)
        
        # 類似度に基づいて検索結果を取得
        results = self._find_similar_documents(
            query_embedding,
            document_embeddings,
            documents,
            top_k
        )
        return results

    def _get_embedding(self, text: str) -> List[float]:
        response = self.bedrock.invoke_model(
            modelId='amazon.titan-embed-text-v1',
            body=json.dumps({
                "inputText": text
            })
        )
        return json.loads(response['body'].read())['embedding']

    def _get_batch_embeddings(self, texts: List[str]) -> List[List[float]]:
        response = self.bedrock.invoke_model(
            modelId='amazon.titan-embed-text-v1',
            body=json.dumps({
                "inputTexts": texts
            })
        )
        return json.loads(response['body'].read())['embeddings']

    def _find_similar_documents(self, 
                              query_embedding: List[float],
                              document_embeddings: List[List[float]],
                              documents: List[str],
                              top_k: int) -> List[Dict]:
        similarities = []
        for i, doc_embedding in enumerate(document_embeddings):
            similarity = self._cosine_similarity(query_embedding, doc_embedding)
            similarities.append({
                'document': documents[i],
                'similarity': similarity
            })
        
        # 類似度でソート
        similarities.sort(key=lambda x: x['similarity'], reverse=True)
        return similarities[:top_k]

    def _cosine_similarity(self, vec1: List[float], vec2: List[float]) -> float:
        import numpy as np
        vec1_norm = np.linalg.norm(vec1)
        vec2_norm = np.linalg.norm(vec2)
        dot_product = np.dot(vec1, vec2)
        return dot_product / (vec1_norm * vec2_norm)

# 使用例
searcher = VectorSearcher()
documents = [
    "この製品は高性能なAIチップを搭載しています。",
    "低消費電力で動作するCPUの特徴について説明します。",
    "画像処理用のGPUの性能比較を行います。",
    "エッジコンピューティングデバイスの選び方"
]
results = searcher.search("省電力なAIプロセッサ", documents)
```

### キーワード検索の実装
```python
import boto3
import json
from typing import List, Dict
import re

class KeywordSearcher:
    def __init__(self):
        self.bedrock = boto3.client(
            service_name='bedrock-runtime',
            region_name='us-west-2'
        )

    def search(self, 
              query: str, 
              documents: List[str], 
              use_wildcards: bool = False) -> List[Dict]:
        # クエリの解析
        keywords = self._parse_query(query)
        
        # ドキュメントの検索
        results = []
        for i, doc in enumerate(documents):
            score = self._calculate_relevance(doc, keywords, use_wildcards)
            if score > 0:
                results.append({
                    'document': doc,
                    'score': score
                })
        
        # スコアでソート
        results.sort(key=lambda x: x['score'], reverse=True)
        return results

    def _parse_query(self, query: str) -> List[str]:
        # クエリをキーワードに分割
        return [word.lower() for word in query.split()]

    def _calculate_relevance(self, 
                           document: str, 
                           keywords: List[str],
                           use_wildcards: bool) -> float:
        doc_lower = document.lower()
        score = 0
        
        for keyword in keywords:
            if use_wildcards:
                # ワイルドカード検索
                pattern = keyword.replace('*', '.*')
                if re.search(pattern, doc_lower):
                    score += 1
            else:
                # 通常のキーワード検索
                if keyword in doc_lower:
                    score += 1
        
        return score

# 使用例
keyword_searcher = KeywordSearcher()
documents = [
    "この製品は高性能なAIチップを搭載しています。",
    "低消費電力で動作するCPUの特徴について説明します。",
    "画像処理用のGPUの性能比較を行います。",
    "エッジコンピューティングデバイスの選び方"
]
results = keyword_searcher.search("AI チップ", documents)
```

### ハイブリッド検索の実装
```python
import boto3
import json
from typing import List, Dict

class HybridSearcher:
    def __init__(self):
        self.vector_searcher = VectorSearcher()
        self.keyword_searcher = KeywordSearcher()

    def search(self, 
              query: str, 
              documents: List[str],
              vector_weight: float = 0.7,
              keyword_weight: float = 0.3,
              top_k: int = 5) -> List[Dict]:
        # ベクトル検索の実行
        vector_results = self.vector_searcher.search(query, documents, top_k)
        
        # キーワード検索の実行
        keyword_results = self.keyword_searcher.search(query, documents)
        
        # 結果の統合
        combined_results = self._combine_results(
            vector_results,
            keyword_results,
            vector_weight,
            keyword_weight
        )
        
        return combined_results[:top_k]

    def _combine_results(self,
                        vector_results: List[Dict],
                        keyword_results: List[Dict],
                        vector_weight: float,
                        keyword_weight: float) -> List[Dict]:
        # 結果の統合とスコアの計算
        combined = {}
        
        # ベクトル検索結果の処理
        for result in vector_results:
            doc = result['document']
            combined[doc] = {
                'document': doc,
                'vector_score': result['similarity'],
                'keyword_score': 0
            }
        
        # キーワード検索結果の処理
        for result in keyword_results:
            doc = result['document']
            if doc in combined:
                combined[doc]['keyword_score'] = result['score']
            else:
                combined[doc] = {
                    'document': doc,
                    'vector_score': 0,
                    'keyword_score': result['score']
                }
        
        # 最終スコアの計算
        final_results = []
        for doc, scores in combined.items():
            final_score = (
                scores['vector_score'] * vector_weight +
                scores['keyword_score'] * keyword_weight
            )
            final_results.append({
                'document': doc,
                'score': final_score,
                'vector_score': scores['vector_score'],
                'keyword_score': scores['keyword_score']
            })
        
        # スコアでソート
        final_results.sort(key=lambda x: x['score'], reverse=True)
        return final_results

# 使用例
hybrid_searcher = HybridSearcher()
documents = [
    "この製品は高性能なAIチップを搭載しています。",
    "低消費電力で動作するCPUの特徴について説明します。",
    "画像処理用のGPUの性能比較を行います。",
    "エッジコンピューティングデバイスの選び方"
]
results = hybrid_searcher.search(
    "省電力なAIプロセッサ",
    documents,
    vector_weight=0.7,
    keyword_weight=0.3
)
```

## まとめ
Amazon Bedrockの検索機能は、ベクトル検索とキーワード検索の2つの主要なアプローチを提供しています。ベクトル検索は意味的な類似性に基づく検索を可能にし、キーワード検索は正確なテキストマッチングを実現します。これらの検索方法を組み合わせたハイブリッド検索により、より正確で関連性の高い検索結果を得ることができます。ユースケースや要件に応じて、適切な検索方法を選択・組み合わせることで、最適な検索体験を提供できます。 
