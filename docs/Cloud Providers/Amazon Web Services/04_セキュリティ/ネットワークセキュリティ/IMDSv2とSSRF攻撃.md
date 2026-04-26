<!-- Space: harukaaibarapublic -->
<!-- Parent: ネットワークセキュリティ -->
<!-- Title: IMDSv2 と SSRF 攻撃 -->

# IMDSv2 と SSRF 攻撃

EC2 インスタンスで動くアプリに SSRF（Server-Side Request Forgery）の脆弱性があると、攻撃者は `http://169.254.169.254/` にリクエストを送ることでインスタンスの IAM クレデンシャルを盗める。これが「IMDS（Instance Metadata Service）攻撃」だ。

Capital One の 2019 年大規模情報漏洩（1億人超のデータ流出）もこの攻撃が起点だった。AWS はこれを受けて IMDSv2 を導入したが、**デフォルトでは IMDSv1 も有効のまま**なので、意識して対応しないと守られていない。

---

## IMDS 攻撃の仕組み

EC2 インスタンス上のアプリは `http://169.254.169.254/latest/meta-data/` にアクセスすることで、自分の IAM ロールの一時クレデンシャルを取得できる。これはアプリが AWS API を使うための正規の仕組みだ。

```bash
# EC2 上で実行すると IAM クレデンシャルが取れる
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/my-role-name
# → AccessKeyId, SecretAccessKey, Token が返ってくる
```

SSRF 脆弱性があるアプリは「任意の URL にリクエストを送れる」状態になっている。攻撃者はこれを利用して、**アプリを踏み台にして IMDS にアクセスさせ、クレデンシャルを外部に持ち出す**。

---

## IMDSv1 と IMDSv2 の違い

| | IMDSv1 | IMDSv2 |
|---|---|---|
| リクエスト方式 | GET だけで取得できる | 先にセッショントークンを取得してから使う（2ステップ） |
| SSRF への耐性 | **ない**（1リクエストで完結するため SSRF で悪用可能） | **あり**（トークン取得に PUT が必要で SSRF では届かない） |
| デフォルト | 有効 | 有効（v1 も同時に有効） |

IMDSv2 では最初に PUT リクエストでセッショントークンを取得する必要がある。SSRF は通常 GET しか送れないため、攻撃が成立しない。

```bash
# IMDSv2 の使い方
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

---

## IMDSv2 を強制する（v1 を無効化する）

### 新規 EC2 インスタンスに設定する

```bash
aws ec2 run-instances \
  --image-id ami-xxxxxxxx \
  --instance-type t3.micro \
  --metadata-options HttpTokens=required,HttpEndpoint=enabled
```

`HttpTokens=required` が IMDSv2 強制。`optional`（デフォルト）だと v1 も使える。

### 既存インスタンスを変更する

```bash
aws ec2 modify-instance-metadata-options \
  --instance-id i-xxxxxxxx \
  --http-tokens required \
  --http-endpoint enabled
```

### アカウント全体でデフォルトを v2 強制にする

```bash
aws ec2 modify-instance-metadata-defaults \
  --http-tokens required \
  --region ap-northeast-1
```

これで新規起動するインスタンスはすべて v2 強制になる。

### AWS Config で v1 のインスタンスを検出する

```bash
# v1 が有効なインスタンスを一覧表示
aws ec2 describe-instances \
  --filters Name=metadata-options.http-tokens,Values=optional \
  --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0]]' \
  --output table
```

Security Hub の FSBP に「EC2.8: EC2 instances should use IMDSv2」というルールがある。有効化すると v1 のインスタンスが自動で検出される。

---

## IMDSv2 でも防げないこと

IMDSv2 は SSRF 攻撃に対して有効だが、**以下には効果がない**：

- EC2 上で直接コードを実行できる場合（RCE 脆弱性）
- EC2 にログインできる攻撃者（セッションハイジャック等）
- コンテナブレイクアウト（ECS・EKS でコンテナから抜け出した場合）

IMDSv2 はあくまで SSRF への対策。アプリの脆弱性そのものは別途修正が必要。

---

## 合わせてやること

**IAM ロールの権限を最小化する**

IMDS からクレデンシャルが盗まれたとき、そのロールの権限が広ければ広いほど被害が大きい。EC2 に付与するロールは最小権限にする。

```bash
# インスタンスに付いているロールの権限を確認
aws iam get-instance-profile \
  --instance-profile-name my-profile \
  --query 'InstanceProfile.Roles[*].RoleName'
```

**IMDSv1 を使っているリクエストを CloudTrail で検出する**

```bash
# v1 アクセスは CloudTrail の MetadataNoToken イベントで記録される
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=GetInstanceMetadata
```

---

## 参考

- [IMDSv2 を使用するようにインスタンスを設定する](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html)
- [EC2.8 — Security Hub FSBP](https://docs.aws.amazon.com/securityhub/latest/userguide/ec2-controls.html#ec2-8)
- [Capital One データ漏洩事件の概要（2019）](https://krebsonsecurity.com/2019/07/capital-one-data-theft-impacts-106m-people/)
