# Grafana & Prometheus Monitoring Hands-on

このリポジトリは、GrafanaとPrometheusを使用したモニタリング環境の構築を実践するためのハンズオンリポジトリです。

## 概要

このプロジェクトでは、AWS上に以下のコンポーネントを構築します：

- Grafanaサーバー（可視化ダッシュボード）
- Prometheus Exporter（メトリクス収集）
- 必要なネットワークリソース（VPC、サブネット等）

## 前提条件

- AWSアカウント
- Terraform（v1.0.0以上）
- AWS CLIの設定済み

## 使用方法

1. リポジトリをクローン
```bash
git clone https://github.com/haruka-aibara/grafana-prometheus-monitoring-hands-on.git
cd grafana-prometheus-monitoring-hands-on
```

2. Terraformの初期化
```bash
terraform init
```

3. インフラのデプロイ
```bash
terraform apply
```

## アクセス方法

デプロイ完了後、以下のURLでGrafanaダッシュボードにアクセスできます：

```
http://<Grafana-Public-IP>:3000
```

デフォルトのログイン情報：
- ユーザー名: admin
- パスワード: admin（初回ログイン時に変更が必要）

## アーキテクチャ

- VPC: 10.0.0.0/16
- パブリックサブネット: 10.0.1.0/24
- リージョン: ap-northeast-1
- インスタンスタイプ: t2.micro

## クリーンアップ

環境を削除する場合は、以下のコマンドを実行してください：

```bash
terraform destroy
```

## ライセンス

MIT License
