# Amazon Bedrockのモデル推論オプション：オンデマンドとプロビジョンドスループット

## 概要
Amazon Bedrockでは、モデル推論の実行方法として「オンデマンド」と「プロビジョンドスループット」の2つのオプションを提供しています。これらのオプションは、異なるユースケースや要件に応じて最適な推論パフォーマンスとコスト効率を実現するために設計されています。

## 詳細

### オンデマンド推論
- 使用した分だけ支払う従量課金モデル
- 主な特徴：
  - 柔軟なスケーリング
  - 初期コストなし
  - 予測不可能なワークロードに適している
- 使用シーン：
  - 開発・テスト環境
  - 低頻度の推論リクエスト
  - 変動の大きいワークロード

### プロビジョンドスループット
- 事前に容量を確保する固定課金モデル
- 主な特徴：
  - 予測可能なパフォーマンス
  - コスト効率の良い大量リクエスト
  - 低レイテンシー
- 使用シーン：
  - 本番環境
  - 高頻度の推論リクエスト
  - 安定したワークロード

## 具体例

### オンデマンド推論の実装例
```python
import boto3
import json

# Bedrockクライアントの初期化
bedrock = boto3.client(
    service_name='bedrock-runtime',
    region_name='us-west-2'
)

# オンデマンド推論の実行
response = bedrock.invoke_model(
    modelId='anthropic.claude-v2',
    body=json.dumps({
        "prompt": "AWSのクラウドコンピューティングの利点について説明してください。",
        "max_tokens": 500,
        "temperature": 0.7
    })
)

# レスポンスの処理
response_body = json.loads(response['body'].read())
generated_text = response_body['completion']
```

### プロビジョンドスループットの設定例
```python
import boto3
import json

# Bedrockクライアントの初期化
bedrock = boto3.client(
    service_name='bedrock',
    region_name='us-west-2'
)

# プロビジョンドスループットの設定
provisioned_throughput = bedrock.create_provisioned_throughput(
    modelId='anthropic.claude-v2',
    provisionedThroughputName='my-production-throughput',
    throughputUnits=100,  # 1分あたりのリクエスト数
    commitmentDuration='1 month'  # コミットメント期間
)

# プロビジョンドスループットを使用した推論
response = bedrock.invoke_model(
    modelId='anthropic.claude-v2',
    body=json.dumps({
        "prompt": "製品の特徴について説明してください。",
        "max_tokens": 500,
        "temperature": 0.7
    }),
    provisionedThroughputArn=provisioned_throughput['provisionedThroughputArn']
)
```

### ワークロードに応じた選択例
```python
import boto3
import json
from datetime import datetime, time

# Bedrockクライアントの初期化
bedrock = boto3.client(
    service_name='bedrock-runtime',
    region_name='us-west-2'
)

def get_inference_client():
    current_time = datetime.now().time()
    # 営業時間中はプロビジョンドスループットを使用
    if time(9, 0) <= current_time <= time(17, 0):
        return {
            'client': bedrock,
            'provisioned_throughput_arn': 'arn:aws:bedrock:region:account:provisioned-throughput/my-production-throughput'
        }
    # 営業時間外はオンデマンドを使用
    return {
        'client': bedrock,
        'provisioned_throughput_arn': None
    }

# 推論の実行
def run_inference(prompt):
    client_info = get_inference_client()
    response = client_info['client'].invoke_model(
        modelId='anthropic.claude-v2',
        body=json.dumps({
            "prompt": prompt,
            "max_tokens": 500,
            "temperature": 0.7
        }),
        provisionedThroughputArn=client_info['provisioned_throughput_arn']
    )
    return json.loads(response['body'].read())['completion']
```

## まとめ
Amazon Bedrockの推論オプションは、異なるユースケースに応じて最適な選択が可能です。オンデマンド推論は柔軟性と初期コストの低さを提供し、プロビジョンドスループットは予測可能なパフォーマンスとコスト効率を実現します。アプリケーションの要件、予想されるワークロード、コスト考慮事項に基づいて、適切な推論オプションを選択することが重要です。また、両方のオプションを組み合わせて使用することで、より効率的な運用が可能になります。 
