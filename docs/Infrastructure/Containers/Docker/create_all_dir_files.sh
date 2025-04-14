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
create_dir_if_not_exists "Dockerロードマップ"
cd "Dockerロードマップ"

# 前提条件（左側のボックス）
create_dir_if_not_exists "00_前提条件"
create_markdown_file "00_前提条件/00-01_パッケージマネージャ.md"
create_markdown_file "00_前提条件/00-02_ユーザとグループの権限.md"
create_markdown_file "00_前提条件/00-03_シェルコマンド.md"
create_markdown_file "00_前提条件/00-04_シェルスクリプト.md"
create_markdown_file "00_前提条件/00-05_Linuxの基礎.md"
create_markdown_file "00_前提条件/00-06_プログラミング言語.md"
create_markdown_file "00_前提条件/00-07_アプリケーションアーキテクチャ.md"
create_markdown_file "00_前提条件/00-08_Web開発.md"

# メインフローに従ってディレクトリとファイルを作成
# 黄色の四角をメインディレクトリとして、実線の流れに特に注意する

# 01 イントロダクション
create_dir_if_not_exists "01_イントロダクション"
create_markdown_file "01_イントロダクション/01-01_コンテナとは何か.md"
create_markdown_file "01_イントロダクション/01-02_なぜコンテナが必要か.md"
create_markdown_file "01_イントロダクション/01-03_ベアメタルvsVMvsコンテナ.md"
create_markdown_file "01_イントロダクション/01-04_DockerとOCI.md"

# 02 基盤技術
create_dir_if_not_exists "02_基盤技術"
create_markdown_file "02_基盤技術/02-01_名前空間.md"
create_markdown_file "02_基盤技術/02-02_cgroups.md"
create_markdown_file "02_基盤技術/02-03_ユニオンファイルシステム.md"

# 03 インストールとセットアップ
create_dir_if_not_exists "03_インストールとセットアップ"
create_markdown_file "03_インストールとセットアップ/03-01_Docker_Desktop（Win・Mac・Linux）.md"
create_markdown_file "03_インストールとセットアップ/03-02_Dockerエンジン（Linux）.md"

# 04 Dockerの基本
create_dir_if_not_exists "04_Dockerの基本"

# 05 データ永続化
create_dir_if_not_exists "05_データ永続化"
create_markdown_file "05_データ永続化/05-01_一時的なコンテナファイルシステム.md"
create_markdown_file "05_データ永続化/05-02_ボリュームマウント.md"
create_markdown_file "05_データ永続化/05-03_バインドマウント.md"

# 06 サードパーティコンテナイメージの使用（実線で05と接続）
create_dir_if_not_exists "06_サードパーティコンテナイメージの使用"
create_markdown_file "06_サードパーティコンテナイメージの使用/06-01_データベース.md"
create_markdown_file "06_サードパーティコンテナイメージの使用/06-02_インタラクティブなテスト環境.md"
create_markdown_file "06_サードパーティコンテナイメージの使用/06-03_コマンドラインユーティリティ.md"

# 07 コンテナイメージのビルド（実線で10と接続）
create_dir_if_not_exists "07_コンテナイメージのビルド"
create_markdown_file "07_コンテナイメージのビルド/07-01_Dockerfiles.md"
create_markdown_file "07_コンテナイメージのビルド/07-02_効率的なレイヤーキャッシング.md"
create_markdown_file "07_コンテナイメージのビルド/07-03_イメージサイズとセキュリティ.md"

# 08 コンテナレジストリ
create_dir_if_not_exists "08_コンテナレジストリ"
create_markdown_file "08_コンテナレジストリ/08-01_イメージタグ付けのベストプラクティス.md"
create_markdown_file "08_コンテナレジストリ/08-02_その他（ghcr、ecr、acr、gcr等）.md"
create_markdown_file "08_コンテナレジストリ/08-03_Dockerhub.md"

# 09 コンテナの実行
create_dir_if_not_exists "09_コンテナの実行"
create_markdown_file "09_コンテナの実行/09-01_docker_compose.md"
create_markdown_file "09_コンテナの実行/09-02_docker_run.md"
create_markdown_file "09_コンテナの実行/09-03_ランタイム設定オプション.md"

# 10 コンテナセキュリティ
create_dir_if_not_exists "10_コンテナセキュリティ"
create_markdown_file "10_コンテナセキュリティ/10-01_ランタイムセキュリティ.md"
create_markdown_file "10_コンテナセキュリティ/10-02_イメージセキュリティ.md"

# 11 Docker_CLI
create_dir_if_not_exists "11_Docker_CLI"
create_markdown_file "11_Docker_CLI/11-01_イメージ.md"
create_markdown_file "11_Docker_CLI/11-02_コンテナ.md"
create_markdown_file "11_Docker_CLI/11-03_ボリューム.md"
create_markdown_file "11_Docker_CLI/11-04_ネットワーク.md"

# 12 開発者エクスペリエンス
create_dir_if_not_exists "12_開発者エクスペリエンス"
create_markdown_file "12_開発者エクスペリエンス/12-01_ホットリロード.md"
create_markdown_file "12_開発者エクスペリエンス/12-02_デバッガー.md"
create_markdown_file "12_開発者エクスペリエンス/12-03_テスト.md"
create_markdown_file "12_開発者エクスペリエンス/12-04_継続的インテグレーション.md"

# 13 コンテナのデプロイ
create_dir_if_not_exists "13_コンテナのデプロイ"
create_markdown_file "13_コンテナのデプロイ/13-01_PaaSオプション.md"
create_markdown_file "13_コンテナのデプロイ/13-02_Kubernetes.md"
create_markdown_file "13_コンテナのデプロイ/13-03_Docker_Swarm.md"
create_markdown_file "13_コンテナのデプロイ/13-04_Nomad.md"

echo "Dockerロードマップのディレクトリとファイル構造の作成が完了しました！"
cd ..

# 構造を表示
echo "作成したディレクトリとファイル構造:"
find "Dockerロードマップ" -type d | sort
echo "------------------------"
find "Dockerロードマップ" -type f | sort
