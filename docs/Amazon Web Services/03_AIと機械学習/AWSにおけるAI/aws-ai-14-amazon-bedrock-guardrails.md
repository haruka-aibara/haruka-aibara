# Amazon BedrockのGuardrails

## 概要
Amazon BedrockのGuardrailsは、生成AIモデルの出力を制御し、安全で適切な応答を確保するための機能です。この機能により、有害なコンテンツの生成を防止し、プライバシーを保護し、ビジネスルールやコンプライアンス要件に準拠した応答を生成することができます。Guardrailsは、生成AIの安全な利用を促進し、企業のリスク管理を強化する重要なツールです。

## 詳細

### Guardrailsの主な機能
- コンテンツフィルタリング
  - 有害コンテンツの検出
  - 不適切な表現の制御
  - 機密情報の保護
- プライバシー保護
  - 個人情報の検出と保護
  - データの匿名化
  - アクセス制御
- コンプライアンス管理
  - 業界規制への準拠
  - 企業ポリシーの適用
  - 監査ログの記録

### 使用シーン
- カスタマーサポートの自動化
- コンテンツ生成の品質管理
- データプライバシーの保護
- コンプライアンス要件の遵守
- リスク管理の強化

## 具体例

### Guardrailsの設定と管理
```python
import boto3
import json
from typing import Dict, List

class BedrockGuardrailsManager:
    def __init__(self):
        self.bedrock = boto3.client(
            service_name='bedrock',
            region_name='us-west-2'
        )

    def create_guardrail(self,
                        name: str,
                        description: str,
                        rules: Dict) -> Dict:
        # Guardrailの作成
        response = self.bedrock.create_guardrail(
            name=name,
            description=description,
            rulesConfiguration={
                'contentFiltering': rules.get('contentFiltering', {}),
                'privacyProtection': rules.get('privacyProtection', {}),
                'complianceRules': rules.get('complianceRules', {})
            }
        )
        return response

    def update_guardrail(self,
                        guardrail_id: str,
                        update_config: Dict) -> Dict:
        # Guardrailの更新
        response = self.bedrock.update_guardrail(
            guardrailId=guardrail_id,
            name=update_config.get('name'),
            description=update_config.get('description'),
            rulesConfiguration=update_config.get('rulesConfiguration')
        )
        return response

# 使用例
guardrails_manager = BedrockGuardrailsManager()
rules_config = {
    'contentFiltering': {
        'harmfulContent': {
            'enabled': True,
            'threshold': 'HIGH',
            'categories': ['HARASSMENT', 'HATE_SPEECH', 'SEXUAL_CONTENT']
        },
        'inappropriateContent': {
            'enabled': True,
            'threshold': 'MEDIUM',
            'categories': ['PROFANITY', 'VIOLENCE']
        }
    },
    'privacyProtection': {
        'piiDetection': {
            'enabled': True,
            'types': ['EMAIL', 'PHONE', 'SSN', 'CREDIT_CARD'],
            'action': 'REDACT'
        },
        'dataAnonymization': {
            'enabled': True,
            'rules': [
                {
                    'pattern': r'\d{3}-\d{2}-\d{4}',
                    'replacement': '[REDACTED]'
                }
            ]
        }
    },
    'complianceRules': {
        'industryStandards': ['HIPAA', 'GDPR'],
        'customRules': [
            {
                'name': 'company_policy',
                'description': '社内ポリシーに基づく制限',
                'conditions': [
                    {
                        'field': 'content',
                        'operator': 'CONTAINS',
                        'value': '機密情報'
                    }
                ],
                'action': 'BLOCK'
            }
        ]
    }
}
guardrail = guardrails_manager.create_guardrail(
    name='enterprise-guardrail',
    description='企業向けGuardrail設定',
    rules=rules_config
)
```

### Guardrailsの適用と監視
```python
import boto3
import json
from typing import Dict, List

class BedrockGuardrailsEnforcer:
    def __init__(self, guardrail_id: str):
        self.bedrock = boto3.client(
            service_name='bedrock-runtime',
            region_name='us-west-2'
        )
        self.guardrail_id = guardrail_id

    def apply_guardrails(self,
                        input_text: str,
                        context: Dict = None) -> Dict:
        # Guardrailsの適用
        response = self.bedrock.invoke_model(
            modelId='anthropic.claude-v2',
            body=json.dumps({
                'prompt': input_text,
                'guardrailId': self.guardrail_id,
                'context': context or {}
            })
        )
        return json.loads(response['body'].read())

    def check_violations(self,
                        response: Dict) -> List[Dict]:
        # 違反のチェック
        violations = []
        if 'guardrailViolations' in response:
            for violation in response['guardrailViolations']:
                violations.append({
                    'type': violation['type'],
                    'severity': violation['severity'],
                    'description': violation['description']
                })
        return violations

# 使用例
enforcer = BedrockGuardrailsEnforcer(guardrail['guardrailId'])

# 入力テキストの処理
input_text = "顧客のメールアドレスは example@company.com です。"
response = enforcer.apply_guardrails(
    input_text,
    context={'department': 'customer_support'}
)

# 違反のチェック
violations = enforcer.check_violations(response)
if violations:
    print("Guardrail違反が検出されました:")
    for violation in violations:
        print(f"- {violation['type']}: {violation['description']}")
```

### Guardrailsの監査とレポート
```python
import boto3
import json
from typing import Dict, List
import pandas as pd
from datetime import datetime, timedelta

class BedrockGuardrailsAuditor:
    def __init__(self, guardrail_id: str):
        self.bedrock = boto3.client(
            service_name='bedrock',
            region_name='us-west-2'
        )
        self.guardrail_id = guardrail_id

    def get_audit_logs(self,
                      start_time: datetime,
                      end_time: datetime) -> List[Dict]:
        # 監査ログの取得
        response = self.bedrock.get_guardrail_audit_logs(
            guardrailId=self.guardrail_id,
            startTime=start_time.isoformat(),
            endTime=end_time.isoformat()
        )
        return response['auditLogs']

    def generate_audit_report(self,
                            logs: List[Dict],
                            output_format: str = 'PDF') -> Dict:
        # 監査レポートの生成
        response = self.bedrock.generate_guardrail_audit_report(
            guardrailId=self.guardrail_id,
            auditLogs=logs,
            outputFormat=output_format
        )
        return response

    def analyze_violations(self, logs: List[Dict]) -> Dict:
        # 違反の分析
        df = pd.DataFrame(logs)
        analysis = {
            'total_requests': len(df),
            'violation_count': len(df[df['hasViolation']]),
            'violation_types': df[df['hasViolation']]['violationType'].value_counts().to_dict(),
            'severity_distribution': df[df['hasViolation']]['severity'].value_counts().to_dict()
        }
        return analysis

# 使用例
auditor = BedrockGuardrailsAuditor(guardrail['guardrailId'])

# 過去24時間の監査ログを取得
end_time = datetime.now()
start_time = end_time - timedelta(days=1)
audit_logs = auditor.get_audit_logs(start_time, end_time)

# 監査レポートの生成
report = auditor.generate_audit_report(audit_logs)

# 違反の分析
analysis = auditor.analyze_violations(audit_logs)
print("Guardrail違反の分析:")
print(f"総リクエスト数: {analysis['total_requests']}")
print(f"違反数: {analysis['violation_count']}")
print("違反タイプの分布:")
for violation_type, count in analysis['violation_types'].items():
    print(f"- {violation_type}: {count}")
```

## まとめ
Amazon BedrockのGuardrailsは、生成AIモデルの安全で適切な利用を確保するための重要な機能を提供します。コンテンツフィルタリング、プライバシー保護、コンプライアンス管理などの機能により、企業のリスク管理を強化し、生成AIの安全な利用を促進します。また、監査ログの記録やレポート生成機能により、Guardrailsの効果を継続的にモニタリングし、必要に応じて設定を最適化することができます。Guardrailsを活用することで、カスタマーサポートの自動化、コンテンツ生成の品質管理、データプライバシーの保護など、様々なユースケースで安全なAIの利用を実現できます。 
