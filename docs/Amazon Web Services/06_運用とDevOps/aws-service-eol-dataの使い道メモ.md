# aws-service-eol-data の使い道メモ

2026-09 に awslabs が公開した、AWS サービスのバージョンのサポート終了日をまとめた JSON データセット。

- リポジトリ: https://github.com/awslabs/aws-service-eol-data （`data/eol.json`）
- 延長サポート料金の姉妹データセット: https://github.com/awslabs/aws-service-extended-support-pricing
- 対象: EKS / RDS / Aurora / Lambda / ElastiCache / OpenSearch / MSK / Amazon MQ / DocumentDB
- バージョンごとに持つ情報: 標準サポートと延長サポートの終了日、終了後の挙動（`CHARGES_APPLY` / `AUTO_UPGRADE` / `CREATE_BLOCKED` / `NO_PATCHES` / `DOMAIN_ISOLATED`）、日付の確定度（`COMMITTED` / `PROJECTED` / `TENTATIVE`）、出典 URL
- 非公式のコミュニティデータ。自動判定に使う場合は出典 URL で確認する前提

## 結論: 自分の用途ではあまり使い道がない

普段使うのは Lambda くらいで、Lambda ランタイムの非推奨は次の2つで足りる。

- **AWS Health**: 該当する関数があるアカウントに非推奨化の通知が届く（無料、EventBridge でも受け取れる）
- **Trusted Advisor**: 「AWS Lambda Functions Using Deprecated Runtimes」チェック（Business 以上のサポートプランが必要）

どちらもデプロイ済みの関数を後から見つける仕組み。データセットが効くのは、`terraform plan` や PR の段階でデプロイ前に止めたいときくらい。

## 使い道が出てくる条件

- RDS / Aurora / EKS などを使い始め、延長サポート料金や強制アップグレードが気になるようになったとき
- 考えたアイデア: plan の JSON から runtime やエンジンのバージョンを抜き出して照合する reusable workflow、料金データセットと組み合わせた延命コストの PR コメント、`PROJECTED` から `COMMITTED` に変わったことの検知
