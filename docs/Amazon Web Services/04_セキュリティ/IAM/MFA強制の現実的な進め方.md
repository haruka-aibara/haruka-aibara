<!-- Space: harukaaibarapublic -->
<!-- Parent: IAM -->
<!-- Title: MFA 強制の現実的な進め方 -->

# MFA 強制の現実的な進め方

「MFA を有効にしてください」と言うのは簡単だ。問題はどうやって**全員に強制するか**、そして**既存のシステムを壊さずに移行するか**。

ルートアカウント・IAM ユーザー・IAM Identity Center（SSO）で、それぞれアプローチが違う。現実的に使える手順を整理する。

---

## ルートアカウントの MFA（最優先）

ルートアカウントは「最後の砦」であり「最大の攻撃対象」。まずここから始める。

### 設定手順

1. AWS マネジメントコンソールにルートアカウントでログイン
2. 右上のアカウント名 → セキュリティ認証情報
3. 多要素認証（MFA）→ MFA デバイスを割り当て
4. **推奨**：ハードウェア MFA（YubiKey 等）。スマホアプリより紛失・盗難リスクが低い

### 組織アカウント（メンバーアカウント）のルート MFA

Organizations でメンバーアカウントが多い場合、各アカウントのルートにログインして設定するのは現実的ではない。

```bash
# ルート MFA が未設定のアカウントを一覧表示
aws organizations list-accounts --query 'Accounts[*].[Id, Name, Status]' --output table

# Security Hub の IAM.6 コントロールで一括検知
aws securityhub get-findings \
  --filters '{"ProductFields": [{"Key": "ControlId", "Value": "IAM.6", "Comparison": "EQUALS"}], "ComplianceStatus": [{"Value": "FAILED", "Comparison": "EQUALS"}]}' \
  --query 'Findings[*].[AwsAccountId, Title]' \
  --output table
```

Organizations のルート MFA 強制ポリシー（2024年〜順次展開中の機能）も確認する価値がある。

---

## IAM ユーザーの MFA 強制

IAM ユーザーが残っている環境での MFA 強制。新規構築なら IAM Identity Center（SSO）に移行するほうが正解だが、既存環境では IAM ユーザーが残っていることが多い。

### SCP で MFA なしのコンソールアクセスを遮断する

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyWithoutMFA",
      "Effect": "Deny",
      "NotAction": [
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:GetUser",
        "iam:ListMFADevices",
        "iam:ListVirtualMFADevices",
        "iam:ResyncMFADevice",
        "sts:GetSessionToken"
      ],
      "Resource": "*",
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": "false"
        }
      }
    }
  ]
}
```

`NotAction` で MFA 設定操作自体は許可する。これがないと「MFA を設定する権限すらない」状態になる。

### 適用前の注意

**CLI やツールで長期クレデンシャル（アクセスキー）を使っている場合、MFA 強制が適用されるとアクセスキーでの API 呼び出しもブロックされる**。

```bash
# 長期アクセスキーを使っている IAM ユーザーを確認
aws iam generate-credential-report && sleep 5
aws iam get-credential-report --query 'Content' --output text | base64 -d | \
  grep -v "^#" | awk -F, '$9 == "true" {print $1, $9, $10}' 
# access_key_1_active == true のユーザーがいたら要確認
```

アクセスキーを使う CI/CD やアプリには MFA 強制の例外が必要になる（ロールを使うように変更するのが正解）。

---

## IAM Identity Center（SSO）での MFA 強制

新規環境や Identity Center に移行済みの環境では、こちらが主な設定箇所。

### MFA 設定を強制する

IAM Identity Center コンソール → 設定 → 多要素認証

| 設定項目 | 推奨値 |
|---|---|
| MFA の要求 | **常に要求する**（コンテキストに基づく MFA は信頼できない環境では不十分） |
| MFA 未登録ユーザーへの対応 | **MFA 登録をブロック**（登録まで強制する） |
| 許可する MFA タイプ | TOTP アプリ + セキュリティキー（SMS は避ける） |
| デバイスの信頼 | **オフ**（オンにすると30日間 MFA スキップできる。リスクが高い） |

```bash
# Identity Center の MFA 設定を確認
aws sso-admin list-instances --query 'Instances[*].InstanceArn' --output text

# 上記 ARN を使って MFA 設定確認
aws sso-admin describe-instance-access-control-attribute-configuration \
  --instance-arn arn:aws:sso:::instance/ssoins-xxxxxx
```

### MFA 未設定ユーザーの洗い出し

```bash
# MFA デバイスが登録されていないユーザーを確認（Identity Center）
aws identitystore list-users \
  --identity-store-id d-xxxxxxxxxx \
  --query 'Users[*].[UserId, UserName]' \
  --output table
```

---

## 移行シナリオ別の進め方

### シナリオ A：既存 IAM ユーザーが多数いる環境

1. まずルートアカウントの MFA を全アカウントで設定
2. Security Hub IAM.6・IAM.5 で MFA 未設定ユーザーを検出
3. MFA 設定期限をアナウンス（例：2週間後）
4. 期限後に SCP で MFA なしアクセスを Deny
5. 段階的に IAM Identity Center へ移行

### シナリオ B：IAM Identity Center 移行済みの環境

1. Identity Center の MFA 設定を「常に要求」にする
2. 既存ユーザーに MFA デバイス登録を依頼
3. 登録期限後に「MFA 未登録ユーザーをブロック」に設定変更

### シナリオ C：新規アカウント・ゼロベース構築

1. Identity Center のみ使う（IAM ユーザーは最小化）
2. 初日から MFA 常時要求を設定
3. CLI アクセスは `aws sso login` の一時トークンのみ使う

---

## よくある落とし穴

**「MFA を設定した」≠「強制されている」**

MFA を任意で使えるようにしても、使わない人が出る。重要なのは「MFA なしではログインできない状態」を作ること。

**SMS 認証は避ける**

SIM スワッピング攻撃（電話番号の乗っ取り）のリスクがある。TOTP アプリ（Google Authenticator, Authy 等）かハードウェアセキュリティキーを使う。

**「デバイスの信頼」機能**

Identity Center の「デバイスの信頼」は、一度認証したデバイスで30日間 MFA をスキップできる機能。使い勝手はいいが、デバイス盗難時のリスクがある。セキュリティ要件が高い環境では無効化する。

---

## 参考

- [Security Hub IAM コントロール一覧](https://docs.aws.amazon.com/securityhub/latest/userguide/iam-controls.html)
- [IAM Identity Center での MFA 設定](https://docs.aws.amazon.com/singlesignon/latest/userguide/mfa-types.html)
- [Organizations での MFA 強制（SCP）](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_aws_mfa-dates.html)
