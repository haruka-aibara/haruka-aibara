# gcloud CLI セットアップ手順

Google Cloud CLI（gcloud）をインストールして使用できるようになるまでの手順を説明します。

## 概要

gcloud CLI は、コマンドラインから Google Cloud Platform のリソースを管理するためのツールです。インストール後、認証を設定することで、Google Cloud のサービスをコマンドラインから操作できます。

## 前提条件

- Google Cloud アカウントとプロジェクトが作成済みであること
- 使用しているOSがサポートされていること（Linux、macOS、Windows）

## インストール手順

### Linux / WSL でのインストール

#### 1. リポジトリの追加とインストール

```bash
# 環境変数の設定（プロジェクトIDを設定）
export CLOUDSDK_CORE_PROJECT=YOUR_PROJECT_ID

# リポジトリの追加
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# 公開鍵のインポート
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# パッケージリストの更新とインストール
sudo apt-get update && sudo apt-get install google-cloud-cli
```

#### 2. インストールの確認

```bash
gcloud --version
```

### macOS でのインストール

#### Homebrew を使用する場合（推奨）

```bash
# Homebrew でインストール
brew install --cask google-cloud-sdk
```

#### インストーラーを使用する場合

1. [Google Cloud SDK ダウンロードページ](https://cloud.google.com/sdk/docs/install) からインストーラーをダウンロード
2. ダウンロードした `.tar.gz` ファイルを展開
3. インストールスクリプトを実行：

```bash
./google-cloud-sdk/install.sh
```

### Windows でのインストール

1. [Google Cloud SDK インストーラー](https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe) をダウンロード
2. インストーラーを実行してウィザードに従う
3. PowerShell またはコマンドプロンプトで確認：

```powershell
gcloud --version
```

## 初期設定（初回セットアップ）

### 1. gcloud CLI の初期化

```bash
gcloud init
```

このコマンドを実行すると、以下の設定が対話形式で行われます：

1. **Google アカウントのログイン**
   - ブラウザが開き、Google アカウントでログインします
   - 認証コードが表示されるので、コマンドラインに入力します

2. **デフォルトプロジェクトの選択**
   - 使用する Google Cloud プロジェクトを選択します

3. **デフォルトコンピューティングゾーンの設定**
   - リージョンとゾーンを選択します（例: `asia-northeast1`, `asia-northeast1-a`）

### 2. アプリケーション認証情報の設定（推奨）

サービスアカウントを使用する場合は、以下の手順で認証情報を設定します：

```bash
# サービスアカウントキーを使用する場合
gcloud auth activate-service-account --key-file=PATH_TO_KEY_FILE.json

# または、現在のユーザーで認証
gcloud auth login
```

### 3. 設定の確認

```bash
# 現在の設定を確認
gcloud config list

# アクティブなアカウントを確認
gcloud auth list

# 現在のプロジェクトを確認
gcloud config get-value project
```

## よく使用する設定コマンド

### プロジェクトの切り替え

```bash
# プロジェクト一覧の表示
gcloud projects list

# デフォルトプロジェクトの設定
gcloud config set project PROJECT_ID
```

### リージョン・ゾーンの設定

```bash
# デフォルトリージョンの設定
gcloud config set compute/region asia-northeast1

# デフォルトゾーンの設定
gcloud config set compute/zone asia-northeast1-a
```

### 複数の設定をまとめて確認・変更

```bash
# 設定一覧の確認
gcloud config list

# 設定の表示（全設定）
gcloud config list --all

# 設定のリセット
gcloud config unset SECTION/PROPERTY
```

## 環境変数による動作制御

gcloud CLI の動作は環境変数で制御できます。よく使用する環境変数は以下の通りです。

### ログ出力の制御

```bash
# ファイルログ出力を無効化
export CLOUDSDK_DISABLE_FILE_LOGGING=true

# ログファイルのパスを指定（デフォルト: ~/.config/gcloud/logs/）
export CLOUDSDK_LOG_FILE=/path/to/log/file.log

# ログレベルを設定（DEBUG, INFO, WARNING, ERROR）
export CLOUDSDK_CORE_LOG_LEVEL=INFO
```

### プロンプトと対話の制御

```bash
# すべてのプロンプトを無効化（自動承認）
export CLOUDSDK_CORE_DISABLE_PROMPTS=1

# 確認プロンプトをスキップ（デフォルトで yes）
export CLOUDSDK_CORE_DISABLE_PROMPTS=1
```

### プロジェクトと認証の設定

```bash
# デフォルトプロジェクトIDを設定
export CLOUDSDK_CORE_PROJECT=YOUR_PROJECT_ID

# 認証情報ファイルのパスを指定
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json

# サービスアカウントの使用を強制
export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE=/path/to/service-account-key.json
```

### 出力形式の制御

```bash
# デフォルトの出力形式を設定（json, yaml, table, csv, text）
export CLOUDSDK_CORE_OUTPUT_FORMAT=json

# パフォーマンスの向上（一部のコマンドで）
export CLOUDSDK_COMPONENT_MANAGER_DISABLE_UPDATE_CHECK=true
```

### 環境変数の設定方法

#### 一時的な設定（現在のセッションのみ）

```bash
# 単一の環境変数を設定
export CLOUDSDK_DISABLE_FILE_LOGGING=true

# 複数の環境変数を一度に設定
export CLOUDSDK_DISABLE_FILE_LOGGING=true
export CLOUDSDK_CORE_PROJECT=my-project-id
```

#### 永続的な設定（シェルの設定ファイルに追加）

```bash
# ~/.bashrc または ~/.zshrc に追加（Linux/macOS）
echo 'export CLOUDSDK_DISABLE_FILE_LOGGING=true' >> ~/.bashrc
echo 'export CLOUDSDK_CORE_PROJECT=YOUR_PROJECT_ID' >> ~/.bashrc

# 設定を反映
source ~/.bashrc
```

#### コマンド実行時に一時的に設定

```bash
# 単一コマンドで環境変数を指定
CLOUDSDK_DISABLE_FILE_LOGGING=true gcloud projects list

# 複数の環境変数を指定
CLOUDSDK_DISABLE_FILE_LOGGING=true CLOUDSDK_CORE_PROJECT=my-project-id gcloud projects describe
```

### 環境変数の確認

```bash
# 現在の環境変数を確認
echo $CLOUDSDK_DISABLE_FILE_LOGGING
echo $CLOUDSDK_CORE_PROJECT

# すべての gcloud 関連の環境変数を確認
env | grep CLOUDSDK
env | grep GOOGLE
```

### よくある使用例

#### CI/CD パイプラインでの使用

```bash
# 非対話モードでファイルログを無効化
export CLOUDSDK_CORE_DISABLE_PROMPTS=1
export CLOUDSDK_DISABLE_FILE_LOGGING=true
export CLOUDSDK_CORE_PROJECT=my-ci-project

# サービスアカウント認証
gcloud auth activate-service-account --key-file=/path/to/key.json
```

#### デバッグモードでの使用

```bash
# デバッグログを有効化
export CLOUDSDK_CORE_LOG_LEVEL=DEBUG
export CLOUDSDK_LOG_FILE=~/gcloud-debug.log

# コマンド実行（デバッグログがファイルに出力される）
gcloud projects list
```

#### ログ出力を完全に無効化

```bash
# ファイルログとコンソールログの両方を制御
export CLOUDSDK_DISABLE_FILE_LOGGING=true
# コンソールログレベルを最小限に
export CLOUDSDK_CORE_LOG_LEVEL=ERROR
```

## 動作確認

### 基本的なコマンドのテスト

```bash
# プロジェクト情報の取得
gcloud projects describe YOUR_PROJECT_ID

# サービスアカウント一覧の確認
gcloud iam service-accounts list

# Compute Engine のインスタンス一覧（該当プロジェクトにCompute Engine APIが有効な場合）
gcloud compute instances list
```

## トラブルシューティング

### 認証エラーが発生する場合

```bash
# 認証状態の確認
gcloud auth list

# 再認証
gcloud auth login

# 認証情報のクリアと再設定
gcloud auth revoke
gcloud auth login
```

### プロジェクトが見つからない場合

```bash
# アクセス可能なプロジェクト一覧を確認
gcloud projects list

# プロジェクトが表示されない場合、権限を確認
# Google Cloud Console で IAM 設定を確認してください
```

### コマンドが見つからない場合

```bash
# PATH の確認（Linux/macOS）
echo $PATH

# gcloud のパスを確認
which gcloud

# PATH に追加する必要がある場合（通常は自動的に追加されます）
# ~/.bashrc または ~/.zshrc に以下を追加：
# export PATH=$PATH:/usr/lib/google-cloud-sdk/bin
```

## 参考リソース

- [Google Cloud SDK 公式ドキュメント](https://cloud.google.com/sdk/docs)
- [gcloud CLI コマンドリファレンス](https://cloud.google.com/sdk/gcloud/reference)
- [インストールガイド](https://cloud.google.com/sdk/docs/install)
- [クイックスタートガイド](https://cloud.google.com/sdk/docs/quickstart)

## 次のステップ

gcloud CLI が使えるようになったら、以下のような操作が可能になります：

- サービスアカウントの作成と管理
- リソースの作成・削除
- プロジェクトの管理
- Terraform など他のツールとの連携

詳細は、各機能のドキュメントを参照してください。

