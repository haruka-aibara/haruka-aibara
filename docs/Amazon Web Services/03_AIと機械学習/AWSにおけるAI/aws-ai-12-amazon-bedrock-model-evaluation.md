# Amazon Bedrockのモデル評価

## 概要
Amazon Bedrockのモデル評価機能は、生成AIモデルの性能を包括的に評価するためのツールを提供します。この機能により、モデルの応答品質、安全性、バイアス、および特定のユースケースにおける適合性を評価することができます。評価結果に基づいて、モデルの選択や設定の最適化を行うことが可能です。

## 詳細

### 評価の種類
- 自動評価
  - 応答品質の評価
  - 安全性チェック
  - バイアス検出
  - 事実性の検証
- 人間による評価
  - 応答の関連性
  - 有用性の評価
  - 自然さの評価
- カスタム評価
  - ドメイン固有の評価基準
  - ビジネス要件に基づく評価
  - 業界規制への準拠評価

### 評価指標
- 応答品質
  - 正確性
  - 関連性
  - 完全性
  - 一貫性
- 安全性
  - 有害コンテンツの検出
  - プライバシー保護
  - セキュリティリスク
- パフォーマンス
  - レイテンシー
  - スループット
  - リソース使用効率

## 具体例

### 自動評価の実装
```python
import boto3
import json
from typing import Dict, List

class BedrockModelEvaluator:
    def __init__(self):
        self.bedrock = boto3.client(
            service_name='bedrock',
            region_name='us-west-2'
        )

    def create_evaluation_job(self,
                            name: str,
                            model_id: str,
                            evaluation_config: Dict) -> Dict:
        # 評価ジョブの作成
        response = self.bedrock.create_model_evaluation(
            name=name,
            modelId=model_id,
            evaluationConfiguration={
                'evaluationType': evaluation_config['type'],
                'metrics': evaluation_config['metrics'],
                'datasetConfiguration': {
                    'datasetType': evaluation_config['datasetType'],
                    'datasetLocation': evaluation_config['datasetLocation']
                }
            }
        )
        return response

    def run_automatic_evaluation(self,
                               evaluation_id: str,
                               test_cases: List[Dict]) -> Dict:
        # 自動評価の実行
        response = self.bedrock.start_model_evaluation(
            evaluationId=evaluation_id,
            testCases=test_cases
        )
        return response

# 使用例
evaluator = BedrockModelEvaluator()
evaluation_config = {
    'type': 'AUTOMATIC',
    'metrics': [
        'accuracy',
        'safety',
        'bias',
        'factuality'
    ],
    'datasetType': 'S3',
    'datasetLocation': 's3://my-evaluation-dataset/'
}
evaluation_job = evaluator.create_evaluation_job(
    name='claude-v2-evaluation',
    model_id='anthropic.claude-v2',
    evaluation_config=evaluation_config
)

test_cases = [
    {
        'input': 'What is the capital of France?',
        'expectedOutput': 'Paris',
        'context': 'Geography question'
    },
    {
        'input': 'Explain quantum computing.',
        'expectedOutput': None,  # 開放型の質問
        'context': 'Technical explanation'
    }
]
evaluation_result = evaluator.run_automatic_evaluation(
    evaluation_job['evaluationId'],
    test_cases
)
```

### 人間による評価の実装
```python
import boto3
import json
from typing import Dict, List

class BedrockHumanEvaluator:
    def __init__(self, evaluation_id: str):
        self.bedrock = boto3.client(
            service_name='bedrock',
            region_name='us-west-2'
        )
        self.evaluation_id = evaluation_id

    def create_human_evaluation_task(self,
                                   task_config: Dict) -> Dict:
        # 人間による評価タスクの作成
        response = self.bedrock.create_human_evaluation_task(
            evaluationId=self.evaluation_id,
            taskConfiguration={
                'taskType': task_config['type'],
                'instructions': task_config['instructions'],
                'evaluationCriteria': task_config['criteria']
            }
        )
        return response

    def submit_human_evaluation(self,
                              task_id: str,
                              evaluation_results: Dict) -> Dict:
        # 人間による評価結果の提出
        response = self.bedrock.submit_human_evaluation(
            taskId=task_id,
            evaluationResults=evaluation_results
        )
        return response

# 使用例
human_evaluator = BedrockHumanEvaluator(evaluation_job['evaluationId'])
task_config = {
    'type': 'RESPONSE_QUALITY',
    'instructions': '以下の基準に基づいて応答を評価してください：\n'
                   '1. 関連性\n'
                   '2. 正確性\n'
                   '3. 完全性\n'
                   '4. 自然さ',
    'criteria': {
        'relevance': {'weight': 0.3},
        'accuracy': {'weight': 0.3},
        'completeness': {'weight': 0.2},
        'naturalness': {'weight': 0.2}
    }
}
evaluation_task = human_evaluator.create_human_evaluation_task(task_config)

evaluation_results = {
    'responses': [
        {
            'responseId': 'resp1',
            'scores': {
                'relevance': 4,
                'accuracy': 5,
                'completeness': 4,
                'naturalness': 5
            },
            'comments': '非常に正確で自然な応答'
        }
    ]
}
human_evaluation = human_evaluator.submit_human_evaluation(
    evaluation_task['taskId'],
    evaluation_results
)
```

### 評価結果の分析とレポート
```python
import boto3
import json
from typing import Dict, List
import pandas as pd
import matplotlib.pyplot as plt

class BedrockEvaluationAnalyzer:
    def __init__(self, evaluation_id: str):
        self.bedrock = boto3.client(
            service_name='bedrock',
            region_name='us-west-2'
        )
        self.evaluation_id = evaluation_id

    def get_evaluation_results(self) -> Dict:
        # 評価結果の取得
        response = self.bedrock.get_model_evaluation(
            evaluationId=self.evaluation_id
        )
        return response

    def generate_evaluation_report(self,
                                 results: Dict,
                                 output_format: str = 'PDF') -> Dict:
        # 評価レポートの生成
        response = self.bedrock.generate_evaluation_report(
            evaluationId=self.evaluation_id,
            outputFormat=output_format
        )
        return response

    def analyze_results(self, results: Dict) -> Dict:
        # 評価結果の分析
        metrics_summary = {}
        for metric in results['metrics']:
            metrics_summary[metric['name']] = {
                'mean': metric['mean'],
                'std': metric['std'],
                'min': metric['min'],
                'max': metric['max']
            }
        return metrics_summary

# 使用例
analyzer = BedrockEvaluationAnalyzer(evaluation_job['evaluationId'])
results = analyzer.get_evaluation_results()
metrics_summary = analyzer.analyze_results(results)

# レポートの生成
report = analyzer.generate_evaluation_report(
    results,
    output_format='PDF'
)

# 結果の可視化
df = pd.DataFrame(metrics_summary).T
df.plot(kind='bar', y='mean', yerr='std')
plt.title('Model Evaluation Metrics')
plt.xlabel('Metrics')
plt.ylabel('Score')
plt.tight_layout()
plt.savefig('evaluation_metrics.png')
```

## まとめ
Amazon Bedrockのモデル評価機能は、生成AIモデルの性能を包括的に評価するための強力なツールを提供します。自動評価、人間による評価、カスタム評価など、様々な評価方法を組み合わせることで、モデルの品質、安全性、適合性を詳細に分析することができます。評価結果に基づいて、モデルの選択や設定の最適化を行い、より良いAIアプリケーションの開発につなげることができます。また、評価レポートの生成や結果の可視化機能により、評価結果を効果的に共有し、意思決定に活用することが可能です。 
