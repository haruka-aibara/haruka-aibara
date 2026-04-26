<!-- Space: harukaaibarapublic -->
<!-- Parent: IAM -->
<!-- Title: SCP（サービスコントロールポリシー） -->

# SCP（サービスコントロールポリシー）

「開発者が誤って東京リージョン以外にリソースを作ってしまった」「本番アカウントで IAM の管理操作をされた」——IAM ポリシーで制限しても、管理者権限を持つユーザーはそれを変更できてしまう。SCP は AWS Organizations レベルでルールを強制できるため、アカウント内の全ユーザー・ロール（管理者含む）に適用される。

---

## SCP の仕組み

SCP は IAM ポリシーと AND で評価される。

```
有効な権限 = IAM ポリシーで許可 AND SCP で許可
```

SCP で拒否されている操作は、たとえ IAM に `AdministratorAccess` がついていても実行できない。組織全体のガードレールとして機能する。

---

## 代表的なユースケース

### 利用リージョンを制限する

東京リージョン以外へのリソース作成を禁止する。

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "NotAction": [
        "iam:*",
        "organizations:*",
        "support:*",
        "sts:*"
      ],
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": "ap-northeast-1"
        }
      }
    }
  ]
}
```

`iam` や `organizations` などのグローバルサービスは `NotAction` で除外する必要がある。

### CloudTrail の無効化を禁止する

監査ログを消されないようにする。

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "cloudtrail:StopLogging",
        "cloudtrail:DeleteTrail",
        "cloudtrail:UpdateTrail"
      ],
      "Resource": "*"
    }
  ]
}
```

### root ユーザーの操作を制限する

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:PrincipalArn": "arn:aws:iam::*:root"
        }
      }
    }
  ]
}
```

### 高リスクなサービスを禁止する

開発アカウントで本番に影響するサービス（Direct Connect 等）の作成を禁止。

```json
{
  "Effect": "Deny",
  "Action": [
    "directconnect:*",
    "ec2:CreateVpnConnection",
    "route53domains:*"
  ],
  "Resource": "*"
}
```

---

## SCP の適用範囲

SCP は OU（組織単位）またはアカウントに適用する。

```
Organizations Root
├── Management Account（SCP 適用外）
├── OU: 本番
│   ├── Account: prod-app
│   └── Account: prod-data
└── OU: 開発
    ├── Account: dev-app
    └── Account: dev-sandbox ← より緩い SCP を適用
```

- Management Account（マスターアカウント）は SCP の影響を受けない
- OU に適用すると配下の全アカウントに継承される

---

## 注意点

- SCP はアカウントに「許可の上限」を設定するものであり、権限を付与するものではない
- `FullAWSAccess`（デフォルトで全アカウントに適用済み）を削除すると全操作が拒否される
- 最初は `Deny` ルールから始める。`Allow` のみの SCP は誤解を招きやすい
