# Amazon Bedrockのバッチ推論

## 概要
Amazon Bedrockのバッチ推論機能は、大量のデータに対して効率的に生成AIモデルを実行するための機能です。この機能により、複数の入力データをまとめて処理し、スケーラブルでコスト効率の良い推論を実現することができます。バッチ処理は、レポート生成、データ分析、コンテンツ生成など、大量のデータを処理する必要があるユースケースに特に適しています。

## 詳細

### バッチ推論の特徴
- 効率的な処理
  - 並列処理による高速化
  - リソースの最適化
  - コスト効率の向上
- 柔軟な設定
  - バッチサイズの調整
  - エラーハンドリング
  - リトライポリシー
- モニタリングと管理
  - 進捗状況の追跡
  - エラーログの収集
  - パフォーマンスメトリクス

### 使用シーン
- 大量のドキュメント処理
- データセットの分析
- レポートの自動生成
- コンテンツの一括生成
- データの前処理

## 具体例

### バッチ推論ジョブの作成と実行
```python
import boto3
import json
from typing import Dict, List
import pandas as pd

class BedrockBatchInference:
    def __init__(self):
        self.bedrock = boto3.client(
            service_name='bedrock',
            region_name='us-west-2'
        )

    def create_batch_job(self,
                        name: str,
                        model_id: str,
                        input_config: Dict,
                        output_config: Dict) -> Dict:
        # バッチ推論ジョブの作成
        response = self.bedrock.create_batch_inference_job(
            name=name,
            modelId=model_id,
            inputConfiguration={
                'inputLocation': input_config['location'],
                'inputFormat': input_config['format'],
                'batchSize': input_config.get('batchSize', 100)
            },
            outputConfiguration={
                'outputLocation': output_config['location'],
                'outputFormat': output_config['format']
            },
            jobConfiguration={
                'maxConcurrentBatches': input_config.get('maxConcurrentBatches', 10),
                'timeoutInSeconds': input_config.get('timeoutInSeconds', 3600)
            }
        )
        return response

    def start_batch_job(self, job_id: str) -> Dict:
        # バッチ推論ジョブの開始
        response = self.bedrock.start_batch_inference_job(
            jobId=job_id
        )
        return response

# 使用例
batch_inference = BedrockBatchInference()
input_config = {
    'location': 's3://my-input-bucket/batch-input/',
    'format': 'JSON',
    'batchSize': 50,
    'maxConcurrentBatches': 5,
    'timeoutInSeconds': 1800
}
output_config = {
    'location': 's3://my-output-bucket/batch-output/',
    'format': 'JSON'
}
batch_job = batch_inference.create_batch_job(
    name='document-analysis-batch',
    model_id='anthropic.claude-v2',
    input_config=input_config,
    output_config=output_config
)
job_execution = batch_inference.start_batch_job(batch_job['jobId'])
```

### バッチ推論の入力データ準備
```python
import pandas as pd
import json
from typing import List, Dict

class BatchInputPreparator:
    def __init__(self, input_path: str):
        self.input_path = input_path

    def prepare_input_data(self,
                          data: List[Dict],
                          batch_size: int = 100) -> None:
        # 入力データの準備
        df = pd.DataFrame(data)
        
        # バッチに分割
        batches = [df[i:i + batch_size] for i in range(0, len(df), batch_size)]
        
        # 各バッチをJSONファイルとして保存
        for i, batch in enumerate(batches):
            batch_data = batch.to_dict('records')
            output_file = f"{self.input_path}/batch_{i}.json"
            with open(output_file, 'w') as f:
                json.dump(batch_data, f)

# 使用例
input_preparator = BatchInputPreparator('batch-input')
sample_data = [
    {
        'id': 'doc1',
        'content': 'This is the first document for analysis.',
        'metadata': {'type': 'report', 'date': '2024-01-01'}
    },
    {
        'id': 'doc2',
        'content': 'This is the second document for analysis.',
        'metadata': {'type': 'article', 'date': '2024-01-02'}
    }
    # より多くのデータ...
]
input_preparator.prepare_input_data(sample_data, batch_size=50)
```

### バッチ推論結果の処理
```python
import boto3
import json
import pandas as pd
from typing import Dict, List

class BatchOutputProcessor:
    def __init__(self, output_path: str):
        self.s3 = boto3.client('s3')
        self.output_path = output_path

    def process_output(self,
                      job_id: str,
                      output_format: str = 'JSON') -> pd.DataFrame:
        # 出力結果の処理
        results = []
        
        # S3バケットから結果ファイルを取得
        paginator = self.s3.get_paginator('list_objects_v2')
        for page in paginator.paginate(Bucket=self.output_path.split('/')[2],
                                     Prefix=f"{self.output_path.split('/')[3]}/{job_id}/"):
            for obj in page.get('Contents', []):
                response = self.s3.get_object(
                    Bucket=self.output_path.split('/')[2],
                    Key=obj['Key']
                )
                batch_results = json.loads(response['Body'].read())
                results.extend(batch_results)
        
        # 結果をDataFrameに変換
        df = pd.DataFrame(results)
        return df

    def analyze_results(self, results_df: pd.DataFrame) -> Dict:
        # 結果の分析
        analysis = {
            'total_processed': len(results_df),
            'success_rate': (results_df['status'] == 'SUCCESS').mean(),
            'average_processing_time': results_df['processing_time'].mean(),
            'error_count': (results_df['status'] == 'ERROR').sum()
        }
        return analysis

# 使用例
output_processor = BatchOutputProcessor('s3://my-output-bucket/batch-output/')
results_df = output_processor.process_output(batch_job['jobId'])
analysis = output_processor.analyze_results(results_df)

# 結果の保存
results_df.to_csv('batch_results.csv', index=False)
with open('batch_analysis.json', 'w') as f:
    json.dump(analysis, f)
```

### バッチ推論のモニタリング
```python
import boto3
import time
from typing import Dict

class BatchJobMonitor:
    def __init__(self, job_id: str):
        self.bedrock = boto3.client(
            service_name='bedrock',
            region_name='us-west-2'
        )
        self.job_id = job_id

    def get_job_status(self) -> Dict:
        # ジョブのステータス取得
        response = self.bedrock.get_batch_inference_job(
            jobId=self.job_id
        )
        return response

    def monitor_progress(self, interval: int = 60) -> None:
        # 進捗状況のモニタリング
        while True:
            status = self.get_job_status()
            print(f"Job Status: {status['status']}")
            print(f"Processed Items: {status['processedItems']}")
            print(f"Total Items: {status['totalItems']}")
            print(f"Progress: {status['progress']}%")
            
            if status['status'] in ['COMPLETED', 'FAILED', 'STOPPED']:
                break
                
            time.sleep(interval)

# 使用例
monitor = BatchJobMonitor(batch_job['jobId'])
monitor.monitor_progress(interval=30)
```

## まとめ
Amazon Bedrockのバッチ推論機能は、大量のデータを効率的に処理するための強力なツールを提供します。並列処理による高速化、リソースの最適化、コスト効率の向上などの特徴により、大規模なデータ処理タスクを効果的に実行することができます。また、柔軟な設定オプションや包括的なモニタリング機能により、バッチ処理の管理と最適化が容易になります。バッチ推論を活用することで、ドキュメント処理、データ分析、レポート生成など、様々なユースケースに対応できます。 
