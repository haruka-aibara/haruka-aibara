<!-- Space: harukaaibarapublic -->
<!-- Parent: IAM -->
<!-- Title: IAM Identity Center -->

# IAM Identity Center（旧 AWS SSO）

複数の AWS アカウントごとに IAM ユーザーを作って管理している——メンバーが増えるほど「どのアカウントに誰のアクセス権があるか」が把握できなくなる。IAM Identity Center は組織の全アカウントへのアクセスを一元管理できる仕組み。Google Workspace や Azure AD と連携してシングルサインオンも実現できる。

---

## 何を解決するか

| 課題 | Identity Center の解決策 |
|---|---|
| アカウントごとに IAM ユーザーを作る手間 | 一箇所でアクセス権を管理 |
| アクセスキーの管理リスク | ブラウザまたは CLI で一時認証情報を取得 |
| メンバー退職時の全アカウント対応 | Identity Center から無効化するだけ |
| どのアカウントに誰が入れるか把握 | 一覧で確認できる |

---

## 基本的な仕組み

```
IdP（Google / Azure AD / Okta 等）または Identity Center 内蔵ディレクトリ
          ↓
    IAM Identity Center
          ↓
  Permission Set（どのサービスをどの権限で使えるか）
          ↓
  AWS アカウント への割り当て
          ↓
  開発者がブラウザまたは AWS CLI でサインイン
```

---

## Permission Set

Permission Set はロールのテンプレート。IAM ポリシーと同等のものを定義して、アカウントに割り当てる。

よく使う Permission Set の例：

| Permission Set 名 | 付与するポリシー | 用途 |
|---|---|---|
| AdministratorAccess | AdministratorAccess | 管理者 |
| DeveloperAccess | カスタム（EC2/ECS/RDS の読み書き等） | 開発者 |
| ReadOnlyAccess | ReadOnlyAccess | 監査・閲覧のみ |
| SecurityAudit | SecurityAudit | セキュリティ担当者 |

---

## CLI でのアクセス方法

```bash
# AWS CLI v2 で Identity Center にサインイン
aws configure sso

# プロファイル一覧確認
aws configure list-profiles

# プロファイルを使って操作
aws s3 ls --profile my-dev-account

# ブラウザ経由でサインイン（トークンの有効期限切れ時）
aws sso login --profile my-dev-account
```

---

## Google Workspace との連携手順（概要）

1. **IAM Identity Center 側**：外部 IdP（Google）を設定
2. **Google 側**：SAML アプリとして AWS を設定し、証明書を発行
3. **Identity Center 側**：Google の SAML メタデータをアップロード
4. **ユーザーのプロビジョニング**：SCIM で Google のユーザー/グループを Identity Center に自動同期

---

## アクセスキーとの比較

```
# アクセスキー（非推奨）
AWS_ACCESS_KEY_ID=AKIAXXXXXXXX      ← 長期的に有効。漏洩リスク
AWS_SECRET_ACCESS_KEY=XXXXXXXX

# Identity Center（推奨）
aws sso login                       ← 一時的な認証情報（デフォルト8時間）
AWS_ACCESS_KEY_ID=ASIAXXXXXXXX     ← STS が発行。有効期限付き
AWS_SESSION_TOKEN=XXXXXXXX
```

Identity Center 経由の認証情報は有効期限があるため、漏洩してもリスクが限定される。
