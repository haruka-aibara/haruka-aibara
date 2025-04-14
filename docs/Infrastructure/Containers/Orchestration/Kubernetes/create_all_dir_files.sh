#!/bin/bash

# ディレクトリが存在しない場合は作成する関数
create_dir_if_not_exists() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
    echo "ディレクトリを作成しました: $1"
  fi
}

# 空のマークダウンファイルを作成する関数
create_markdown_file() {
  if [ ! -f "$1" ]; then
    touch "$1"
    echo "マークダウンファイルを作成しました: $1"
  fi
}

# メインディレクトリを作成
create_dir_if_not_exists "Kubernetesロードマップ"
cd "Kubernetesロードマップ"

# 関連ロードマップのディレクトリを作成
create_dir_if_not_exists "00_関連ロードマップ"
create_markdown_file "00_関連ロードマップ/00-01_DevOpsロードマップ.md"
create_markdown_file "00_関連ロードマップ/00-02_システム設計ロードマップ.md"

# 主要カテゴリのディレクトリとマークダウンファイルを作成
# 階層順に作成し、線のつながりに従って番号付け

# 01 イントロダクション
create_dir_if_not_exists "01_イントロダクション"
create_markdown_file "01_イントロダクション/01-01_Kubernetesの概要.md"
create_markdown_file "01_イントロダクション/01-02_なぜKubernetesか.md"
create_markdown_file "01_イントロダクション/01-03_重要な概念と用語.md"
create_markdown_file "01_イントロダクション/01-04_Kubernetesの代替手段.md"

# 02 コンテナ
create_dir_if_not_exists "02_コンテナ"
create_markdown_file "02_コンテナ/02-01_コンテナの概要.md"

# 03 Kubernetesのセットアップ
create_dir_if_not_exists "03_Kubernetesのセットアップ"
create_markdown_file "03_Kubernetesのセットアップ/03-01_初めてのアプリケーションのデプロイ.md"
create_markdown_file "03_Kubernetesのセットアップ/03-02_マネージドプロバイダの選択.md"
create_markdown_file "03_Kubernetesのセットアップ/03-03_ローカルクラスタのインストール.md"

# 04 アプリケーションの実行
create_dir_if_not_exists "04_アプリケーションの実行"
create_markdown_file "04_アプリケーションの実行/04-01_ポッド.md"
create_markdown_file "04_アプリケーションの実行/04-02_レプリカセット.md"
create_markdown_file "04_アプリケーションの実行/04-03_デプロイメント.md"
create_markdown_file "04_アプリケーションの実行/04-04_StatefulSet.md"
create_markdown_file "04_アプリケーションの実行/04-05_ジョブ.md"

# 05 サービスとネットワーキング
create_dir_if_not_exists "05_サービスとネットワーキング"
create_markdown_file "05_サービスとネットワーキング/05-01_外部サービスへのアクセス.md"
create_markdown_file "05_サービスとネットワーキング/05-02_ロードバランシング.md"
create_markdown_file "05_サービスとネットワーキング/05-03_ネットワーキングとポッド間通信.md"

# 06 設定管理
create_dir_if_not_exists "06_設定管理"
create_markdown_file "06_設定管理/06-01_ConfigMapを使用したPod設定の注入.md"
create_markdown_file "06_設定管理/06-02_機密データ用のSecretsの使用.md"

# 07 リソース管理
create_dir_if_not_exists "07_リソース管理"
create_markdown_file "07_リソース管理/07-01_リソース要求と制限の設定.md"
create_markdown_file "07_リソース管理/07-02_名前空間へのクォータ割り当て.md"
create_markdown_file "07_リソース管理/07-03_リソース使用状況の監視と最適化.md"

# 08 セキュリティ
create_dir_if_not_exists "08_セキュリティ"
create_markdown_file "08_セキュリティ/08-01_ロールベースアクセス制御（RBAC）.md"
create_markdown_file "08_セキュリティ/08-02_ネットワークセキュリティ.md"
create_markdown_file "08_セキュリティ/08-03_コンテナとポッドのセキュリティ.md"
create_markdown_file "08_セキュリティ/08-04_セキュリティスキャナー.md"

# 09 モニタリングとロギング
create_dir_if_not_exists "09_モニタリングとロギング"
create_markdown_file "09_モニタリングとロギング/09-01_ログ.md"
create_markdown_file "09_モニタリングとロギング/09-02_メトリクス.md"
create_markdown_file "09_モニタリングとロギング/09-03_トレース.md"
create_markdown_file "09_モニタリングとロギング/09-04_リソースヘルス.md"
create_markdown_file "09_モニタリングとロギング/09-05_可観測性エンジン.md"

# 10 オートスケーリング
create_dir_if_not_exists "10_オートスケーリング"
create_markdown_file "10_オートスケーリング/10-01_水平ポッドオートスケーラー（HPA）.md"
create_markdown_file "10_オートスケーリング/10-02_垂直ポッドオートスケーラー（VPA）.md"
create_markdown_file "10_オートスケーリング/10-03_クラスターオートスケーリング.md"

# 11 スケジューリング
create_dir_if_not_exists "11_スケジューリング"
create_markdown_file "11_スケジューリング/11-01_基本.md"
create_markdown_file "11_スケジューリング/11-02_テイントと許容.md"
create_markdown_file "11_スケジューリング/11-03_トポロジー分散制約.md"
create_markdown_file "11_スケジューリング/11-04_ポッド優先度.md"
create_markdown_file "11_スケジューリング/11-05_退去.md"

# 12 ストレージとボリューム
create_dir_if_not_exists "12_ストレージとボリューム"
create_markdown_file "12_ストレージとボリューム/12-01_CSIドライバ.md"
create_markdown_file "12_ストレージとボリューム/12-02_ステートフルアプリケーション.md"

# 13 デプロイメントパターン
create_dir_if_not_exists "13_デプロイメントパターン"
create_markdown_file "13_デプロイメントパターン/13-01_Canaryデプロイメント.md"
create_markdown_file "13_デプロイメントパターン/13-02_Blue-Greenデプロイメント.md"
create_markdown_file "13_デプロイメントパターン/13-03_ローリングアップデート・ロールバック.md"
create_markdown_file "13_デプロイメントパターン/13-04_CI／CD統合.md"
create_markdown_file "13_デプロイメントパターン/13-05_GitOps.md"
create_markdown_file "13_デプロイメントパターン/13-06_Helmチャート.md"

# 14 高度なトピック
create_dir_if_not_exists "14_高度なトピック"
create_markdown_file "14_高度なトピック/14-01_カスタムコントローラの作成.md"
create_markdown_file "14_高度なトピック/14-02_カスタムスケジューラと拡張機能.md"
create_markdown_file "14_高度なトピック/14-03_カスタムリソース定義（CRD）.md"
create_markdown_file "14_高度なトピック/14-04_Kubernetes拡張機能とAPI.md"

# 15 クラスター運用
create_dir_if_not_exists "15_クラスター運用"
create_markdown_file "15_クラスター運用/15-01_自分でクラスタを管理すべきか.md"
create_markdown_file "15_クラスター運用/15-02_コントロールプレーンのインストール.md"
create_markdown_file "15_クラスター運用/15-03_ワーカーノードの追加と管理.md"
create_markdown_file "15_クラスター運用/15-04_マルチクラスター管理.md"

echo "Kubernetesロードマップのディレクトリとファイル構造の作成が完了しました！"
cd ..

# 構造を表示
echo "作成したディレクトリとファイル構造:"
find "Kubernetesロードマップ" -type d | sort
echo "------------------------"
find "Kubernetesロードマップ" -type f | sort
