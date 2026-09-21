# Amazon BedrockのAgents

## 概要
Amazon BedrockのAgentsは、生成AIモデルを活用して複雑なタスクを自動的に実行するための機能です。エージェントは、ユーザーの要求を理解し、必要なアクションを実行し、適切な応答を生成することができます。これにより、より高度な自動化とインテリジェントなタスク実行が可能になります。

## 詳細

### Agentsの主な機能
- タスクの理解と実行
  - 自然言語による指示の理解
  - 複数ステップのタスク実行
  - 動的な意思決定
- ツールの統合
  - AWSサービスの利用
  - カスタムツールの統合
  - APIの呼び出し
- コンテキスト管理
  - 会話履歴の保持
  - 状態の管理
  - エラーハンドリング

### 使用シーン
- カスタマーサポートの自動化
- データ分析とレポート生成
- システム管理と監視
- ドキュメント処理
- ワークフローの自動化

## 具体例

### Agentの作成と設定
```python
import boto3
import json
from typing import Dict, List

class BedrockAgentManager:
    def __init__(self):
        self.bedrock = boto3.client(
            service_name='bedrock',
            region_name='us-west-2'
        )

    def create_agent(self,
                    name: str,
                    description: str,
                    role_arn: str,
                    model_id: str = 'anthropic.claude-v2') -> Dict:
        # Agentの作成
        response = self.bedrock.create_agent(
            name=name,
            description=description,
            roleArn=role_arn,
            agentConfiguration={
                'modelId': model_id,
                'temperature': 0.7,
                'maxTokens': 500
            }
        )
        return response

    def add_tool(self,
                agent_id: str,
                tool_config: Dict) -> Dict:
        # ツールの追加
        response = self.bedrock.create_agent_tool(
            agentId=agent_id,
            name=tool_config['name'],
            description=tool_config['description'],
            toolConfiguration={
                'type': tool_config['type'],
                'apiConfiguration': {
                    'apiEndpoint': tool_config['apiEndpoint'],
                    'apiKey': tool_config['apiKey']
                }
            }
        )
        return response

# 使用例
manager = BedrockAgentManager()
agent_config = {
    'name': 'support-agent',
    'description': 'カスタマーサポート用エージェント',
    'role_arn': 'arn:aws:iam::account:role/bedrock-agent-role'
}
agent = manager.create_agent(**agent_config)

tool_config = {
    'name': 'ticket-system',
    'description': 'サポートチケットシステム',
    'type': 'API',
    'apiEndpoint': 'https://api.support-system.com',
    'apiKey': 'your-api-key'
}
tool = manager.add_tool(agent['agentId'], tool_config)
```

### Agentの実行と対話
```python
import boto3
import json
from typing import Dict, List

class BedrockAgentExecutor:
    def __init__(self, agent_id: str):
        self.bedrock = boto3.client(
            service_name='bedrock-runtime',
            region_name='us-west-2'
        )
        self.agent_id = agent_id
        self.conversation_history = []

    def execute(self,
               user_input: str,
               context: Dict = None) -> Dict:
        # 会話履歴の更新
        self.conversation_history.append({
            'role': 'user',
            'content': user_input
        })

        # Agentの実行
        response = self.bedrock.invoke_agent(
            agentId=self.agent_id,
            inputText=user_input,
            sessionAttributes={
                'conversationHistory': json.dumps(self.conversation_history),
                'context': json.dumps(context or {})
            }
        )

        # 応答の処理
        result = json.loads(response['body'].read())
        
        # 会話履歴の更新
        self.conversation_history.append({
            'role': 'assistant',
            'content': result['completion']
        })

        return result

    def reset_conversation(self):
        # 会話履歴のリセット
        self.conversation_history = []

# 使用例
executor = BedrockAgentExecutor(agent['agentId'])

# サポートチケットの作成
response = executor.execute(
    "新しいサポートチケットを作成してください。製品の不具合について報告します。",
    context={
        'customer_id': '12345',
        'product_id': 'P789'
    }
)

# チケットの状態確認
response = executor.execute(
    "先ほど作成したチケットの状態を確認してください。"
)
```

### Agentの管理と監視
```python
import boto3
import json
from typing import Dict, List

class BedrockAgentMonitor:
    def __init__(self, agent_id: str):
        self.bedrock = boto3.client(
            service_name='bedrock',
            region_name='us-west-2'
        )
        self.agent_id = agent_id

    def get_status(self) -> Dict:
        # Agentのステータス取得
        response = self.bedrock.get_agent(
            agentId=self.agent_id
        )
        return response

    def list_tools(self) -> List[Dict]:
        # ツールの一覧取得
        response = self.bedrock.list_agent_tools(
            agentId=self.agent_id
        )
        return response['tools']

    def get_execution_history(self,
                            max_results: int = 10) -> List[Dict]:
        # 実行履歴の取得
        response = self.bedrock.list_agent_executions(
            agentId=self.agent_id,
            maxResults=max_results
        )
        return response['executions']

    def update_agent(self,
                    update_config: Dict) -> Dict:
        # Agentの更新
        response = self.bedrock.update_agent(
            agentId=self.agent_id,
            name=update_config['name'],
            description=update_config['description'],
            agentConfiguration=update_config['configuration']
        )
        return response

# 使用例
monitor = BedrockAgentMonitor(agent['agentId'])
status = monitor.get_status()
tools = monitor.list_tools()
execution_history = monitor.get_execution_history()

# Agentの更新
update_config = {
    'name': 'enhanced-support-agent',
    'description': '機能強化されたサポートエージェント',
    'configuration': {
        'modelId': 'anthropic.claude-v2',
        'temperature': 0.5,
        'maxTokens': 1000
    }
}
updated_agent = monitor.update_agent(update_config)
```

## まとめ
Amazon BedrockのAgentsは、生成AIモデルを活用して複雑なタスクを自動的に実行するための強力な機能を提供します。自然言語による指示の理解、複数ステップのタスク実行、ツールの統合などの機能により、より高度な自動化とインテリジェントなタスク実行が可能になります。また、会話履歴の保持や状態管理の機能も備えており、継続的な対話や複雑なワークフローの実行にも対応できます。Agentsを活用することで、カスタマーサポートの自動化、データ分析、システム管理など、様々なユースケースに対応できます。 
