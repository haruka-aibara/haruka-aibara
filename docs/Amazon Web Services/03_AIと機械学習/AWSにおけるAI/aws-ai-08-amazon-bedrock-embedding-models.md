# Amazon Bedrockの埋め込みモデル

## 概要
Amazon Bedrockの埋め込みモデルは、テキストや画像などのデータを高次元のベクトル（埋め込み）に変換するためのAIモデルです。これらの埋め込みベクトルは、セマンティック検索、類似性比較、クラスタリングなどのタスクに使用され、RAGシステムの重要な基盤となります。

## 詳細

### 主な埋め込みモデル
- Amazon Titan Embed
  - テキスト埋め込み用
  - 多言語対応
  - 最大512トークンまで処理可能
- Amazon Titan Multimodal Embed
  - テキストと画像の埋め込み用
  - マルチモーダル検索に対応
  - 画像とテキストの意味的な関連性を捉える

### 埋め込みモデルの特徴
- 高品質なベクトル表現
  - 意味的な類似性の保持
  - 文脈を考慮した表現
  - 多言語対応
- スケーラビリティ
  - バッチ処理対応
  - 低レイテンシー
  - 高スループット

## 具体例

### テキスト埋め込みの実装
```python
import boto3
import json
from typing import List, Dict

class TextEmbedder:
    def __init__(self):
        self.bedrock = boto3.client(
            service_name='bedrock-runtime',
            region_name='us-west-2'
        )

    def get_embedding(self, text: str) -> List[float]:
        # テキストの埋め込みを取得
        response = self.bedrock.invoke_model(
            modelId='amazon.titan-embed-text-v1',
            body=json.dumps({
                "inputText": text
            })
        )
        return json.loads(response['body'].read())['embedding']

    def get_batch_embeddings(self, texts: List[str]) -> List[List[float]]:
        # 複数テキストの埋め込みを一括取得
        response = self.bedrock.invoke_model(
            modelId='amazon.titan-embed-text-v1',
            body=json.dumps({
                "inputTexts": texts
            })
        )
        return json.loads(response['body'].read())['embeddings']

# 使用例
embedder = TextEmbedder()
text = "この製品は高性能なAIチップを搭載し、低消費電力で動作します。"
embedding = embedder.get_embedding(text)
```

### マルチモーダル埋め込みの実装
```python
import boto3
import json
import base64
from typing import List, Dict

class MultimodalEmbedder:
    def __init__(self):
        self.bedrock = boto3.client(
            service_name='bedrock-runtime',
            region_name='us-west-2'
        )

    def get_image_embedding(self, image_path: str) -> List[float]:
        # 画像をBase64エンコード
        with open(image_path, 'rb') as image_file:
            image_bytes = image_file.read()
            image_base64 = base64.b64encode(image_bytes).decode('utf-8')

        # 画像の埋め込みを取得
        response = self.bedrock.invoke_model(
            modelId='amazon.titan-embed-image-v1',
            body=json.dumps({
                "inputImage": image_base64
            })
        )
        return json.loads(response['body'].read())['embedding']

    def get_multimodal_embedding(self, text: str, image_path: str) -> List[float]:
        # 画像をBase64エンコード
        with open(image_path, 'rb') as image_file:
            image_bytes = image_file.read()
            image_base64 = base64.b64encode(image_bytes).decode('utf-8')

        # テキストと画像の埋め込みを取得
        response = self.bedrock.invoke_model(
            modelId='amazon.titan-embed-multimodal-v1',
            body=json.dumps({
                "inputText": text,
                "inputImage": image_base64
            })
        )
        return json.loads(response['body'].read())['embedding']

# 使用例
multimodal_embedder = MultimodalEmbedder()
text = "製品の外観写真"
image_path = "product_image.jpg"
embedding = multimodal_embedder.get_multimodal_embedding(text, image_path)
```

### 埋め込みベクトルの類似性計算
```python
import numpy as np
from typing import List, Tuple

class EmbeddingSimilarity:
    @staticmethod
    def cosine_similarity(vec1: List[float], vec2: List[float]) -> float:
        # コサイン類似度の計算
        vec1_norm = np.linalg.norm(vec1)
        vec2_norm = np.linalg.norm(vec2)
        dot_product = np.dot(vec1, vec2)
        return dot_product / (vec1_norm * vec2_norm)

    @staticmethod
    def find_most_similar(query_embedding: List[float], 
                         embeddings: List[List[float]], 
                         top_k: int = 5) -> List[Tuple[int, float]]:
        # 最も類似した埋め込みを検索
        similarities = [
            (i, EmbeddingSimilarity.cosine_similarity(query_embedding, emb))
            for i, emb in enumerate(embeddings)
        ]
        return sorted(similarities, key=lambda x: x[1], reverse=True)[:top_k]

# 使用例
text_embedder = TextEmbedder()
similarity_calculator = EmbeddingSimilarity()

# クエリテキストと比較対象テキストの埋め込みを取得
query_text = "省電力なAIチップ"
query_embedding = text_embedder.get_embedding(query_text)

comparison_texts = [
    "高性能なAIプロセッサ",
    "低消費電力のCPU",
    "画像処理用GPU",
    "エッジコンピューティングデバイス"
]
comparison_embeddings = text_embedder.get_batch_embeddings(comparison_texts)

# 類似度の計算と結果の表示
similar_items = similarity_calculator.find_most_similar(
    query_embedding, 
    comparison_embeddings
)
for idx, score in similar_items:
    print(f"テキスト: {comparison_texts[idx]}, 類似度: {score:.4f}")
```

## まとめ
Amazon Bedrockの埋め込みモデルは、テキストや画像を高次元のベクトルに変換し、意味的な類似性を保持する重要な機能を提供します。これらの埋め込みベクトルは、セマンティック検索、類似性比較、クラスタリングなどの様々なタスクに活用できます。また、マルチモーダル埋め込みモデルを使用することで、テキストと画像の意味的な関連性を捉えることも可能です。これらの機能は、RAGシステムやその他のAIアプリケーションの基盤として重要な役割を果たします。 
