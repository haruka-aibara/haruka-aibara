# 請求先アカウントIDの確認方法

Google Cloud で請求先アカウントIDを確認する方法を説明します。請求先アカウントIDは、プロジェクトを請求先アカウントにリンクする際や、APIでの操作時に必要になります。

## 参考

- [公式ドキュメント: 請求先アカウント ID を確認する](https://docs.cloud.google.com/billing/docs/how-to/find-billing-account-id?hl=ja)

## 方法1: Cloud Billing コンソールで確認（推奨）

請求先アカウントの権限（請求先アカウント閲覧者以上）がある場合、Cloud Billing コンソールから直接確認できます。

### 手順

1. [Google Cloud コンソール](https://console.cloud.google.com/) にアクセス
2. **お支払い**セクションの **[自分の請求先アカウント]** ページに移動
   - コンソールで「お支払い」→「自分の請求先アカウント」を選択
   - または直接: `https://console.cloud.google.com/billing`
3. 請求先アカウントのリストが表示されます
   - **請求先アカウント名**と**請求先アカウントID**が表示されます
   - 請求先アカウントIDは `01XXXX-XXXXXX-XXXXXX` のような形式です

### リストの表示設定

請求先アカウントID列が表示されない場合：

1. テーブルの右上にある **列の表示/非表示** アイコンをクリック
2. 「**請求先アカウント ID**」にチェックを入れる

### フィルタリング

閉鎖されたアカウントを非表示にする場合：

1. ページ上部の **フィルタ** アイコンをクリック
2. **ステータス: アクティブ** を選択
   - または、ステータス: **閉鎖** フィルタを**削除**

### その他の情報

請求先アカウントのリストには、以下の情報も表示されます：

- **ステータス**: アクティブ/閉鎖など
- **アカウントの種類**: 組織/個人など
- **組織**: 関連する組織（該当する場合）
- **過去30日間の費用**: `billing.accounts.getSpendingInformation` 権限が必要

**ヒント**: 過去30日間の費用列を表示するには、請求先アカウントユーザーロールでは権限が不足しています。以下のロールには権限が含まれています：

- 請求先アカウント閲覧者
- 請求先アカウントの費用管理者
- 請求先アカウント管理者

### CSV エクスポート

テーブルの上部にある **「CSV 形式でダウンロード」** セレクタを使用すると、アカウントのリストをCSVファイルとしてダウンロードできます。

## 方法2: マイプロジェクトページで確認

プロジェクトのみの権限があり、請求先アカウントの権限がない場合でも、アクセスできるプロジェクトにリンクされている請求先アカウントのIDを確認できます。

### 手順

1. [Google Cloud コンソール](https://console.cloud.google.com/) にアクセス
2. **お支払い**セクションの **[マイ プロジェクト]** ページに移動
   - コンソールで「お支払い」→「マイ プロジェクト」を選択
3. プロジェクトのリストが表示されます
   - 各プロジェクトに関連する**請求先アカウント名**と**請求先アカウントID**が表示されます

### 必要な権限

以下のいずれかのロールが必要です：

- プロジェクト オーナー
- プロジェクト編集者
- プロジェクト閲覧者
- プロジェクト支払い管理者

## 方法3: gcloud CLI で確認

コマンドラインから請求先アカウントIDを確認することもできます。

### 請求先アカウントの一覧表示

```bash
# アクセス可能なすべての請求先アカウントを表示
gcloud billing accounts list

# 出力例:
# ACCOUNT_ID              NAME              OPEN
# 01XXXX-XXXXXX-XXXXXX   My Billing Account   True
```

### 特定のプロジェクトの請求先アカウントを確認

```bash
# プロジェクトにリンクされている請求先アカウントを表示
gcloud billing projects describe PROJECT_ID

# 出力例:
# billingAccountName: billingAccounts/01XXXX-XXXXXX-XXXXXX
# billingAccountId: 01XXXX-XXXXXX-XXXXXX
# name: projects/123456789012
# projectId: PROJECT_ID
```

### フォーマット指定

```bash
# JSON形式で出力
gcloud billing accounts list --format=json

# YAML形式で出力
gcloud billing accounts list --format=yaml

# テーブル形式で出力（デフォルト）
gcloud billing accounts list --format=table(displayName,name,open)
```

## 請求先アカウントIDの形式

請求先アカウントIDは以下の形式です：

```
01XXXX-XXXXXX-XXXXXX
```

- 先頭に `01` が付く
- ハイフンで区切られた3つのセクション
- 合計16文字（ハイフン含む）

## 使用例

### プロジェクトを請求先アカウントにリンクする場合

```bash
# プロジェクトを請求先アカウントにリンク
gcloud billing projects link PROJECT_ID \
  --billing-account=01XXXX-XXXXXX-XXXXXX
```

### Terraform で使用する場合

```hcl
resource "google_project" "project" {
  name       = "My Project"
  project_id = "my-project-id"
}

resource "google_billing_project_info" "project_billing" {
  project         = google_project.project.id
  billing_account = "01XXXX-XXXXXX-XXXXXX"
}
```

## トラブルシューティング

### 請求先アカウントIDが表示されない場合

1. **権限の確認**
   - 請求先アカウントの権限があるか確認
   - プロジェクトの権限があるか確認

2. **列の表示設定を確認**
   - Cloud Billing コンソールで「列の表示/非表示」を確認
   - 「請求先アカウント ID」にチェックが入っているか確認

3. **フィルタの確認**
   - 閉鎖されたアカウントが非表示になっていないか確認

### アクセスできない場合

```bash
# 認証状態の確認
gcloud auth list

# プロジェクトの設定確認
gcloud config get-value project

# 権限の確認
gcloud projects get-iam-policy PROJECT_ID
```

## 関連ドキュメント

- [Google Cloud のプロジェクトについて](./Google%20Cloud%20のプロジェクトについて.md)
- [gcloud CLI セットアップ手順](./gcloud%20CLI%20セットアップ手順.md)
- [請求先アカウント ID を確認する - 公式ドキュメント](https://docs.cloud.google.com/billing/docs/how-to/find-billing-account-id?hl=ja)

## 参考情報

- [Cloud Billing API](https://cloud.google.com/billing/docs/reference/rest)
- [請求先アカウントの管理](https://cloud.google.com/billing/docs/how-to/manage-billing-account)
