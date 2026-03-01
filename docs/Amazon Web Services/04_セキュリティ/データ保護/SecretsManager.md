<!-- Space: harukaaibarapublic -->
<!-- Parent: データ保護 -->
<!-- Title: AWS Secrets Manager -->

# AWS Secrets Manager

DB パスワードや API キーを環境変数や設定ファイルに直書きしている——これはコードレビューで見落とされると Git に入るし、エンジニアが退職しても認証情報が残り続ける。Secrets Manager はシークレットを安全に保管・配布・ローテーションする仕組み。

---

## Parameter Store との比較

| | Secrets Manager | SSM Parameter Store |
|---|---|---|
| 料金 | シークレット 1 件あたり $0.40/月 | Standard は無料、Advanced は有料 |
| 自動ローテーション | あり（Lambda で実装） | なし |
| クロスアカウント共有 | あり | 制限あり |
| 適用対象 | DB パスワード・API キー | 設定値全般・シークレット |

DB パスワードや外部 API キーは Secrets Manager、環境ごとの設定値（エンドポイント URL 等）は Parameter Store、という使い分けが多い。

---

## シークレットの保存と取得

```bash
# シークレットを保存
aws secretsmanager create-secret \
  --name prod/myapp/db \
  --secret-string '{"username":"admin","password":"s3cr3t"}'

# シークレットを取得
aws secretsmanager get-secret-value \
  --secret-id prod/myapp/db \
  --query SecretString \
  --output text
```

---

## アプリケーションからの取得

```python
import boto3
import json

def get_db_credentials():
    client = boto3.client('secretsmanager', region_name='ap-northeast-1')
    response = client.get_secret_value(SecretId='prod/myapp/db')
    return json.loads(response['SecretString'])

credentials = get_db_credentials()
# credentials['username'], credentials['password'] で使う
```

環境変数にパスワードを渡す必要がなくなる。

---

## RDS パスワードの自動ローテーション

Secrets Manager は Lambda を使った自動ローテーションをサポートしている。RDS は組み込みのローテーション関数が用意されている。

```bash
# RDS パスワードのローテーションを有効化（30日ごと）
aws secretsmanager rotate-secret \
  --secret-id prod/myapp/db \
  --rotation-rules AutomaticallyAfterDays=30 \
  --rotation-lambda-arn arn:aws:lambda:ap-northeast-1:123456789012:function:SecretsManagerRDSRotation
```

ローテーション中もアプリケーションはシークレット ID でアクセスするだけで、パスワード変更は透過的に行われる。

---

## IAM ポリシーでのアクセス制御

```json
{
  "Effect": "Allow",
  "Action": "secretsmanager:GetSecretValue",
  "Resource": "arn:aws:secretsmanager:ap-northeast-1:123456789012:secret:prod/myapp/*"
}
```

シークレット名のパスで絞ることで、本番のシークレットには本番ロールしかアクセスできない構成を作れる。

---

## ECS タスクでの活用

ECS タスク定義でシークレットを直接参照できる。コンテナに環境変数として渡される。

```json
{
  "containerDefinitions": [{
    "name": "app",
    "secrets": [
      {
        "name": "DB_PASSWORD",
        "valueFrom": "arn:aws:secretsmanager:ap-northeast-1:123456789012:secret:prod/myapp/db:password::"
      }
    ]
  }]
}
```
