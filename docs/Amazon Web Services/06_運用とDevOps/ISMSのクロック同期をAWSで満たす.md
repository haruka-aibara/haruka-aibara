# ISMS のクロック同期を AWS で満たす

ISO 27002 8.17。

**結論：EC2 全台に Run Command を流し、Amazon Time Sync を向いているか確認する。コマンドは OS ごとに変える。**

| 主体 | やること |
|---|---|
| CloudTrail・Config・Flow Logs・Lambda・Fargate・RDS など | なし。AWS の管理範囲（AWS Artifact の第三者認証報告書で担保） |
| EC2・EKS/ECS のノード | 時刻源を Amazon Time Sync Service（`169.254.169.123`）に向ける |
| コンテナ | なし（ホストの時計を使う） |

Amazon Time Sync は AWS の NTP サーバ。VPC 内から直接届く。うるう秒をスメアするので公開 NTP と混ぜない。

## EC2 の初期設定

- Amazon Linux・Bottlerocket・EKS 最適化 AMI・AWS 提供の Windows：最初から向いている
- Ubuntu・RHEL：初期設定は `ntp.ubuntu.com`・`2.rhel.pool.ntp.org`。AWS 向け AMI で上書きされているかは未確認

外れていたら AMI のビルドか SSM State Manager で `server 169.254.169.123 prefer iburst` に差し替える。

## 確認（OS ごと）

```sh
timedatectl show -p NTPSynchronized --value   # yes なら同期済み
chronyc tracking                              # Reference ID が 169.254.169.123 か
```

Windows は `w32tm /query /status`。ポートの疎通は見なくてよい。

定期的に回すなら State Manager に登録し、結果を S3 に残す。SSM 未登録の台は確認できないので、EC2 の台数と突き合わせる。

## タイムゾーン

ログは UTC で保存し、表示だけ JST。OS のタイムゾーンは変えない。

## 方針文書の叩き台

> - AWS マネージドサービスの時刻は AWS の管理範囲とし、第三者認証報告書で確認する
> - EC2 は Amazon Time Sync Service に同期し、承認 AMI の標準設定で担保する
> - ログは UTC で記録し、表示時に JST へ変換する
