# aws-config-custodian

[Cloud Custodian](https://cloudcustodian.io/)（c7n）のポリシーを、AWS Config のカスタムルールとしてデプロイするモジュール。判定ロジックは c7n 本体を使い、Lambda のコードは書かない。デプロイは c7n の CLI ではなく Terraform が行う。

## 仕組み

`policies/` の YAML 1 ファイルが Config ルール 1 本になる。

| リソース | 数 | 中身 |
|---|---|---|
| Lambda layer `cloud-custodian` | 1 | `vendor/` にある c7n の wheel をそのまま使う |
| Lambda 関数 `custodian-<ファイル名>` | ポリシーごと | ハンドラ（`src/custodian_policy.py`）と、YAML から生成した `config.json` の 2 ファイルだけ |
| Config ルール `custodian-<ファイル名>` | ポリシーごと | 定期実行（既定は 24 時間ごと）。フィルタに一致したリソースを NON_COMPLIANT、それ以外を COMPLIANT にする |
| ロググループ、Lambda の実行許可 | ポリシーごと | |
| IAM ロール `cloud-custodian-config-rule` | 1 | 読み取りは `SecurityAudit`。このアカウントの中だけで完結する |
| Config レコーダー、配信先 S3 バケット、レコーダー用 IAM ロール | 1 | Config ルールを作るための前提。記録料金がかからないよう、記録対象は個人アカウントにまず存在しないタイプ 1 つに絞っている |

Lambda の中身は、c7n の CLI（`custodian run`）が `config-poll-rule` モードでデプロイするものと同じ形にしてある。違いは、c7n 本体を関数の zip に入れずに layer に分けている点だけ。

Config のレコーダーはリージョンに 1 つしか作れない。既にあるアカウントで使う場合は `main_config_recorder.tf` を消し、`main_config.tf` の `depends_on` から外す。

## ポリシーを足す

`policies/<名前>.yml` を置く。書くのは `resource` と `filters`（と任意で `description`）だけで、`name` と `mode` はモジュールが付ける。

```yaml
description: 90 日以上使われていない IAM ロール
resource: aws.iam-role
filters:
  - type: value
    key: RoleLastUsed.LastUsedDate
    value_type: age
    op: gt
    value: 90
```

フィルタの書き方は c7n のドキュメントの各リソースのページ（例: [aws.iam-role](https://cloudcustodian.io/docs/aws/resources/iam-role.html)）を見る。

## c7n を上げる

1. `pip download --no-deps c7n==<版> -d vendor/` で wheel を取り、古い wheel を消す
2. `locals.tf` の `c7n_version` を書き換える

layer に入れるのは c7n だけ。依存ライブラリは入れず、Lambda ランタイムに入っている boto3 を使う（c7n の CLI がデプロイする場合と同じ）。
