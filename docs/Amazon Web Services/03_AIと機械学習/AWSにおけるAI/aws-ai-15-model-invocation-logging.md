# モデル呼び出しログ

## 概要
モデル呼び出しログ機能は、生成AIモデルの使用状況を追跡し、監視するための重要な機能です。この機能により、モデルの呼び出し履歴、パフォーマンスメトリクス、エラー情報などを詳細に記録し、分析することができます。モデル呼び出しログは、運用監視、コスト管理、パフォーマンス最適化、セキュリティ監査など、様々な目的で活用できます。

## 詳細

### モデル呼び出しログの主な機能
- 呼び出し履歴の記録
  - リクエストとレスポンスの内容
  - タイムスタンプと実行時間
  - モデルパラメータ
- パフォーマンスメトリクス
  - レイテンシー
  - スループット
  - リソース使用率
- エラーと例外の追跡
  - エラーメッセージ
  - スタックトレース
  - エラーの種類と頻度
- セキュリティ監査
  - アクセスログ
  - 認証情報
  - リソース使用状況

### 使用シーン
- 運用監視とトラブルシューティング
- コスト管理と最適化
- パフォーマンス分析
- セキュリティ監査
- コンプライアンス対応

## 具体例

### モデル呼び出しログの設定と管理
```python
import boto3
import json
from typing import Dict, List
from datetime import datetime, timedelta

class LoggingManager:
    def __init__(self):
        self.bedrock = boto3.client(
            service_name='bedrock',
            region_name='us-west-2'
        )
        self.cloudwatch = boto3.client('cloudwatch')
        self.s3 = boto3.client('s3')

    def configure_logging(self,
                         log_group_name: str,
                         s3_bucket: str,
                         retention_days: int = 30) -> Dict:
        # ログ設定の構成
        response = self.bedrock.configure_logging(
            loggingConfiguration={
                'cloudWatchLogGroup': log_group_name,
                's3Bucket': s3_bucket,
                'retentionInDays': retention_days,
                'logLevel': 'INFO',
                'includeModelInputs': True,
                'includeModelOutputs': True
            }
        )
        return response

    def update_logging_config(self,
                            config_id: str,
                            update_config: Dict) -> Dict:
        # ログ設定の更新
        response = self.bedrock.update_logging_configuration(
            configurationId=config_id,
            loggingConfiguration=update_config
        )
        return response

# 使用例
logging_manager = LoggingManager()
logging_config = logging_manager.configure_logging(
    log_group_name='/aws/bedrock/model-invocation-logs',
    s3_bucket='my-bedrock-logs',
    retention_days=90
)
```

### モデル呼び出しログの収集と分析
```python
import boto3
import json
import pandas as pd
from typing import Dict, List
from datetime import datetime, timedelta

class LogAnalyzer:
    def __init__(self, log_group_name: str):
        self.cloudwatch = boto3.client('cloudwatch-logs')
        self.log_group_name = log_group_name

    def get_model_invocation_logs(self,
                                start_time: datetime,
                                end_time: datetime,
                                model_id: str = None) -> List[Dict]:
        # モデル呼び出しログの取得
        response = self.cloudwatch.filter_log_events(
            logGroupName=self.log_group_name,
            startTime=int(start_time.timestamp() * 1000),
            endTime=int(end_time.timestamp() * 1000),
            filterPattern=f'{{ $.modelId = "{model_id}" }}' if model_id else None
        )
        return response['events']

    def analyze_performance(self, logs: List[Dict]) -> Dict:
        # パフォーマンス分析
        df = pd.DataFrame([json.loads(log['message']) for log in logs])
        analysis = {
            'total_invocations': len(df),
            'average_latency': df['latency'].mean(),
            'p95_latency': df['latency'].quantile(0.95),
            'error_rate': (df['status'] == 'ERROR').mean(),
            'model_usage': df['modelId'].value_counts().to_dict()
        }
        return analysis

    def generate_performance_report(self,
                                 analysis: Dict,
                                 output_format: str = 'PDF') -> Dict:
        # パフォーマンスレポートの生成
        report = {
            'timestamp': datetime.now().isoformat(),
            'summary': {
                'total_invocations': analysis['total_invocations'],
                'average_latency_ms': round(analysis['average_latency'], 2),
                'p95_latency_ms': round(analysis['p95_latency'], 2),
                'error_rate_percent': round(analysis['error_rate'] * 100, 2)
            },
            'model_usage': analysis['model_usage']
        }
        return report

# 使用例
log_analyzer = LogAnalyzer('/aws/bedrock/model-invocation-logs')

# 過去24時間のログを取得
end_time = datetime.now()
start_time = end_time - timedelta(days=1)
logs = log_analyzer.get_model_invocation_logs(
    start_time,
    end_time,
    model_id='anthropic.claude-v2'
)

# パフォーマンス分析
analysis = log_analyzer.analyze_performance(logs)

# レポート生成
report = log_analyzer.generate_performance_report(analysis)
print("モデル呼び出しパフォーマンスレポート:")
print(f"総呼び出し回数: {report['summary']['total_invocations']}")
print(f"平均レイテンシー: {report['summary']['average_latency_ms']}ms")
print(f"95パーセンタイルレイテンシー: {report['summary']['p95_latency_ms']}ms")
print(f"エラー率: {report['summary']['error_rate_percent']}%")
```

### コスト分析と最適化
```python
import boto3
import json
import pandas as pd
from typing import Dict, List
from datetime import datetime, timedelta

class CostAnalyzer:
    def __init__(self):
        self.cloudwatch = boto3.client('cloudwatch')
        self.ce = boto3.client('ce')

    def get_cost_metrics(self,
                        start_time: datetime,
                        end_time: datetime) -> Dict:
        # コストメトリクスの取得
        response = self.ce.get_cost_and_usage(
            TimePeriod={
                'Start': start_time.strftime('%Y-%m-%d'),
                'End': end_time.strftime('%Y-%m-%d')
            },
            Granularity='DAILY',
            Metrics=['UnblendedCost'],
            GroupBy=[
                {'Type': 'DIMENSION', 'Key': 'SERVICE'},
                {'Type': 'DIMENSION', 'Key': 'USAGE_TYPE'}
            ]
        )
        return response

    def analyze_costs(self, cost_data: Dict) -> Dict:
        # コスト分析
        df = pd.DataFrame(cost_data['ResultsByTime'])
        analysis = {
            'total_cost': df['Total']['UnblendedCost']['Amount'].sum(),
            'cost_by_service': df.groupby('SERVICE')['Total']['UnblendedCost']['Amount'].sum().to_dict(),
            'cost_by_usage': df.groupby('USAGE_TYPE')['Total']['UnblendedCost']['Amount'].sum().to_dict()
        }
        return analysis

    def generate_cost_report(self,
                           analysis: Dict,
                           output_format: str = 'PDF') -> Dict:
        # コストレポートの生成
        report = {
            'timestamp': datetime.now().isoformat(),
            'summary': {
                'total_cost_usd': round(float(analysis['total_cost']), 2),
                'cost_by_service': analysis['cost_by_service'],
                'cost_by_usage': analysis['cost_by_usage']
            }
        }
        return report

# 使用例
cost_analyzer = CostAnalyzer()

# 過去30日間のコストデータを取得
end_time = datetime.now()
start_time = end_time - timedelta(days=30)
cost_data = cost_analyzer.get_cost_metrics(start_time, end_time)

# コスト分析
analysis = cost_analyzer.analyze_costs(cost_data)

# レポート生成
report = cost_analyzer.generate_cost_report(analysis)
print("モデル呼び出しコストレポート:")
print(f"総コスト: ${report['summary']['total_cost_usd']}")
print("サービス別コスト:")
for service, cost in report['summary']['cost_by_service'].items():
    print(f"- {service}: ${round(float(cost), 2)}")
```

## まとめ
モデル呼び出しログ機能は、生成AIモデルの使用状況を包括的に監視・分析するための強力なツールを提供します。呼び出し履歴の記録、パフォーマンスメトリクスの収集、エラーの追跡、セキュリティ監査などの機能により、モデルの運用管理を効率化し、コスト最適化を実現することができます。また、CloudWatch LogsやS3との統合により、ログデータの長期保存や詳細な分析が可能になります。モデル呼び出しログを活用することで、生成AIモデルの運用をより安全で効率的に行うことができます。 
