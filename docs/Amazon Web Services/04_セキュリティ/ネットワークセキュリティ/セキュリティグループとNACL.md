<!-- Space: harukaaibarapublic -->
<!-- Parent: ネットワークセキュリティ -->
<!-- Title: セキュリティグループと NACL -->

# セキュリティグループと NACL

「EC2 に SSH できなくなった」「意図せずポート 3306 がインターネットに開いていた」——VPC のアクセス制御を正しく理解していないと、開けすぎるか絞りすぎるかのどちらかになる。AWS には 2 層のネットワークアクセス制御がある。

---

## セキュリティグループ vs NACL

| | セキュリティグループ | NACL |
|---|---|---|
| 適用単位 | ENI（インスタンス） | サブネット |
| ステートフル/レス | ステートフル | ステートレス |
| デフォルト動作 | 全拒否（許可ルールのみ） | 全許可 |
| 拒否ルール | 書けない | 書ける |
| 評価順序 | 全ルールを評価 | 番号順（最初にマッチしたもの） |

**ステートフル**（セキュリティグループ）: インバウンドを許可した接続のアウトバウンド返答は自動で許可される。
**ステートレス**（NACL）: インバウンドとアウトバウンドを別々にルール定義しないと通信が通らない。

---

## セキュリティグループの典型的な設定

```bash
# Web サーバー向けセキュリティグループ
aws ec2 create-security-group \
  --group-name web-sg \
  --description "Web server security group" \
  --vpc-id vpc-xxxxxxxx

# HTTPS（443）をインターネットから許可
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxx \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0

# SSH（22）は踏み台サーバーのセキュリティグループからのみ許可
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxx \
  --protocol tcp \
  --port 22 \
  --source-group sg-bastion-id
```

---

## セキュリティグループのソースにセキュリティグループを指定する

IP アドレスではなくセキュリティグループを指定すると、スケールしても管理しなくていい。

```
ALB セキュリティグループ (sg-alb)
  └── EC2 セキュリティグループ (sg-app)
        └── RDS セキュリティグループ (sg-db)
```

- EC2 の SG: `sg-alb` からの 8080 を許可
- RDS の SG: `sg-app` からの 3306 を許可

IP を使わないので、インスタンスが増減しても設定変更不要。

---

## NACL の活用場面

NACL は「特定 IP を完全にブロックしたい」ときに有効。セキュリティグループは拒否ルールを書けないため。

```bash
# 攻撃元 IP を NACL でブロック
aws ec2 create-network-acl-entry \
  --network-acl-id acl-xxxxxxxx \
  --rule-number 10 \
  --protocol -1 \
  --rule-action deny \
  --cidr-block 203.0.113.0/24 \
  --ingress
```

ルール番号が小さいほど先に評価される。ブロックしたい IP は低い番号で定義する。

---

## よくある設定ミス

| ミス | リスク | 対策 |
|---|---|---|
| `0.0.0.0/0` で SSH（22）を開放 | ブルートフォース攻撃 | 踏み台サーバーか VPN の IP に絞る |
| RDS を public subnet に配置 | DB へ直接アクセス可能 | private subnet + SG で EC2 経由のみに |
| セキュリティグループで全ポートを許可 | 意図しないポートへのアクセス | 必要なポートだけ開く |
| NACL でアウトバウンドを忘れる | 通信が片道になり接続できない | エフェメラルポート（1024-65535）のアウトバウンドを忘れずに |

---

## Config ルールでの自動チェック

```bash
# SSH がインターネットに開いているセキュリティグループを検出
aws configservice put-config-rule \
  --config-rule '{
    "ConfigRuleName": "restricted-ssh",
    "Source": {
      "Owner": "AWS",
      "SourceIdentifier": "INCOMING_SSH_DISABLED"
    }
  }'
```

`RESTRICTED_INCOMING_TRAFFIC` ルールで 22 番・3389 番の開放を継続監視できる。
