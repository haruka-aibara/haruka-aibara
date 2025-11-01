# GitHub Renovate ガイド

## はじめに

依存関係の更新管理に時間を取られていませんか？Renovateは、プロジェクトの依存関係（npm、Docker、GitHub Actions、**Terraform Provider（AWS Provider、AWSCC Providerなど）**など）を自動的に監視し、更新可能なバージョンがあると自動的にPull Requestを作成してくれるツールです。このガイドでは、Renovateの基本的な理解から導入方法、そして実際の利点までを解説します。特にTerraformを使用しているプロジェクトでは、インフラレベルの依存関係も自動で最新に保てるため、セキュリティと運用効率の両面で大きなメリットがあります。

## ざっくり理解しよう

### Renovateとは

- **依存関係の自動更新ツール**：プロジェクトで使用しているライブラリやツールの新しいバージョンを自動検知
- **自動PR作成**：更新可能なバージョンを発見すると、自動的にPull Requestを作成
- **多様なパッケージマネージャーに対応**：npm、yarn、Docker、GitHub Actions、Maven、Gradleなど、30種類以上のパッケージマネージャーをサポート
- **柔軟な設定**：更新の頻度、対象、グループ化など、プロジェクトのニーズに合わせてカスタマイズ可能

### なぜRenovateが必要なのか

1. **セキュリティの向上**：脆弱性のある依存関係を早期に更新可能
2. **開発効率の向上**：手動での依存関係チェックや更新作業が不要に
3. **技術負債の削減**：古いバージョンへの依存を防ぎ、常に最新の状態を維持
4. **チームの負担軽減**：定期的なメンテナンス作業を自動化

### RenovateとDependabotの違い

GitHubには依存関係の自動更新ツールとして、RenovateとDependabotの2つがあります。どちらも似た機能を提供しますが、重要な違いがあります。

#### 主な違いの比較

| 項目 | Renovate | Dependabot |
|------|----------|------------|
| **対応プラットフォーム** | GitHub、GitLab、Bitbucket、Azure DevOpsなど複数プラットフォーム | GitHub専用 |
| **PRの作成方法** | 複数の更新を1つのPRにまとめられる（グループ化） | 1つの依存関係につき1つのPR（グループ化不可） |
| **カスタマイズ性** | 非常に柔軟な設定が可能（スケジュール、自動マージ、ラベルなど） | 基本的な設定のみ（Dependabot設定ファイル） |
| **更新スケジュール** | 自由に設定可能（例：週末のみ、特定の日時） | 毎日自動実行（カスタマイズ不可） |
| **対応パッケージマネージャー** | 30種類以上（Terraform、Kubernetes、Helmなども含む） | 主なパッケージマネージャーに対応（npm、Docker、GitHub Actionsなど） |
| **自動マージの設定** | 細かく条件を指定可能 | 基本的な自動マージ設定のみ |
| **ラベル付け** | カスタムラベルを自動付与可能 | GitHubの標準ラベルのみ |
| **セキュリティ更新** | カスタマイズ可能な優先度設定 | セキュリティ更新を優先的に処理 |

#### どちらを選ぶべきか

**Renovateが向いている場合：**
- ✅ 複数のプラットフォーム（GitLab、Bitbucketなど）でも使用したい
- ✅ PRをグループ化して、レビュー負荷を減らしたい
- ✅ 更新スケジュールを細かく制御したい
- ✅ TerraformやKubernetesなどのインフラツールの依存関係も管理したい
- ✅ より柔軟なカスタマイズが必要
- ✅ プロジェクトごとに異なる更新戦略を持ちたい

**Dependabotが向いている場合：**
- ✅ GitHub専用のプロジェクト
- ✅ シンプルな設定で運用したい
- ✅ GitHubの標準機能として無料で使いたい（Renovateも無料だが、GitHub Appとして提供）
- ✅ 各依存関係を個別にレビューしたい（PRが分かれている方が良い）

#### 実例：PR作成の違い

**Dependabotの場合：**
```
PR #1: Bump aws-sdk from 2.1000.0 to 2.1001.0
PR #2: Bump express from 4.18.0 to 4.18.1
PR #3: Bump terraform-provider-aws from 5.0.0 to 5.1.0
```
→ 更新ごとに個別のPRが作成される

**Renovateの場合（グループ化設定時）：**
```
PR #1: Update dependencies (minor/patch updates)
  - aws-sdk: 2.1000.0 → 2.1001.0
  - express: 4.18.0 → 4.18.1
  - terraform-provider-aws: 5.0.0 → 5.1.0
```
→ 複数の更新を1つのPRにまとめられる

#### 移行について

DependabotからRenovateへの移行は簡単です：
1. Renovate Appをインストール
2. `renovate.json`で設定をカスタマイズ
3. Dependabotの設定を無効化

両方同時に使用することも可能ですが、同じ依存関係に対してPRが重複する可能性があるため、通常はどちらか一方を選択することをおすすめします。

## 実際の使い方

### 1. GitHub Appのインストール

1. **Renovate Appにアクセス**
   - [GitHub Marketplace - Renovate](https://github.com/marketplace/renovate) にアクセス
   - 「Install」ボタンをクリック

2. **リポジトリの選択**
   - インストールするリポジトリを選択
   - 個別のリポジトリ、もしくはすべてのリポジトリにインストール可能
   - 「Install」をクリックして完了

3. **初期設定PRの確認**
   - インストール後、リポジトリに「Configure Renovate」というタイトルのPRが自動的に作成されます
   - このPRには `renovate.json` または `.github/renovate.json` という設定ファイルが含まれています

### 2. 初期設定の確認とマージ

```markdown
# Configure Renovate

このPRは、Renovateがこのリポジトリで動作するための設定ファイルを含んでいます。

このPRをマージすることで、Renovateが依存関係の更新を開始します。
```

- PRの内容を確認し、問題がなければマージ
- マージ後、Renovateが依存関係のスキャンを開始

### 3. 設定ファイルのカスタマイズ

リポジトリのルートまたは `.github` ディレクトリに `renovate.json` を作成・編集して設定をカスタマイズできます。

#### 基本的な設定例

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": [
    "config:base"
  ],
  "timezone": "Asia/Tokyo",
  "schedule": ["every weekend"],
  "packageRules": [
    {
      "matchDepTypes": ["dependencies"],
      "semanticCommitType": "feat"
    },
    {
      "matchDepTypes": ["devDependencies"],
      "semanticCommitType": "chore"
    }
  ]
}
```

#### よく使う設定オプション

- **`extends`**: ベースとなる設定を継承（`config:base`は推奨設定）
- **`timezone`**: スケジュールのタイムゾーンを指定
- **`schedule`**: 更新チェックの頻度（例：`["every weekend"]`, `["before 10am on monday"]`）
- **`packageRules`**: パッケージごとのルールを定義
- **`automerge`**: 条件を満たす場合に自動マージ
- **`groupName`**: 複数の更新を1つのPRにまとめる

## 手を動かしてみよう

### 実践的な設定例

#### 例1: セキュリティ更新を優先する設定

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": [
    "config:base"
  ],
  "vulnerabilityAlerts": {
    "enabled": true
  },
  "packageRules": [
    {
      "matchUpdateTypes": ["security"],
      "automerge": true,
      "labels": ["security", "automerge"]
    }
  ]
}
```

#### 例2: メジャーバージョンアップをグループ化

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": [
    "config:base"
  ],
  "packageRules": [
    {
      "matchUpdateTypes": ["major"],
      "groupName": "Major updates",
      "labels": ["major-update"],
      "schedule": ["every 3 months on the first day of the month"]
    }
  ]
}
```

#### 例3: 特定のパッケージを無視

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": [
    "config:base"
  ],
  "ignoreDeps": [
    "package-name-to-ignore"
  ]
}
```

#### 例4: Dockerイメージの更新設定

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": [
    "config:base"
  ],
  "dockerfile": {
    "enabled": true
  },
  "docker-compose": {
    "enabled": true
  },
  "packageRules": [
    {
      "matchManagers": ["dockerfile", "docker-compose"],
      "groupName": "Docker updates"
    }
  ]
}
```

#### 例5: GitHub Actionsの更新設定

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": [
    "config:base"
  ],
  "github-actions": {
    "enabled": true
  },
  "packageRules": [
    {
      "matchManagers": ["github-actions"],
      "groupName": "GitHub Actions updates",
      "labels": ["ci", "github-actions"]
    }
  ]
}
```

#### 例6: TerraformとTerraform Providerの更新設定

Renovateは、Terraform本体のバージョンやTerraform Provider（AWS Provider、AWSCC Providerなど）のバージョン更新も自動化できます。これは特にインフラ管理をTerraformで行っているプロジェクトで非常に有用です。

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": [
    "config:base"
  ],
  "terraform": {
    "enabled": true
  },
  "packageRules": [
    {
      "matchManagers": ["terraform"],
      "groupName": "Terraform Provider updates",
      "labels": ["terraform", "infrastructure"]
    },
    {
      "matchPackagePatterns": ["^hashicorp/aws$", "^hashicorp/awscc$"],
      "groupName": "AWS Provider updates",
      "labels": ["terraform", "aws", "provider"]
    }
  ]
}
```

##### Terraformファイルでの記述例

Renovateは以下のようなTerraformファイルを解析して、バージョンを更新します：

```hcl
# versions.tf または terraformブロックがあるファイル
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Renovateがこのバージョンを監視・更新
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.0"  # Renovateがこのバージョンを監視・更新
    }
  }
}
```

また、`.terraform-version`ファイルがある場合も更新対象になります：

```text
# .terraform-version
1.6.0  # RenovateがTerraform本体のバージョンを更新
```

##### より実践的なTerraform設定例

プロジェクトでTerraformを使用している場合の推奨設定：

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": [
    "config:base"
  ],
  "terraform": {
    "enabled": true
  },
  "packageRules": [
    {
      "matchManagers": ["terraform"],
      "semanticCommitType": "chore"
    },
    {
      "matchManagers": ["terraform"],
      "matchUpdateTypes": ["patch", "minor"],
      "groupName": "Terraform Provider minor/patch updates",
      "labels": ["terraform", "automerge"],
      "automerge": true
    },
    {
      "matchManagers": ["terraform"],
      "matchUpdateTypes": ["major"],
      "groupName": "Terraform Provider major updates",
      "labels": ["terraform", "major-update"],
      "schedule": ["every 3 months on the first day of the month"]
    },
    {
      "matchPackagePatterns": ["^hashicorp/aws$"],
      "groupName": "AWS Provider updates",
      "labels": ["terraform", "aws"]
    },
    {
      "matchPackagePatterns": ["^hashicorp/awscc$"],
      "groupName": "AWSCC Provider updates",
      "labels": ["terraform", "awscc"]
    },
    {
      "matchDepTypes": ["terraform_version"],
      "groupName": "Terraform version updates",
      "labels": ["terraform", "version"]
    }
  ]
}
```

この設定により：
- **パッチ・マイナー更新**: 自動マージで迅速に適用
- **メジャー更新**: 四半期ごとにグループ化してレビューしやすい形でPR作成
- **AWS Provider/AWSCC Provider**: 個別にグループ化して管理しやすく
- **Terraform本体**: バージョン更新を別途グループ化

## Renovateがうれしいポイント

### 1. 自動化による時間削減

- **手動チェック不要**：毎週、毎月の依存関係チェック作業が不要
- **PR自動作成**：更新可能なバージョンがあると自動でPRを作成
- **更新情報の一元管理**：RenovateのPRで、どの依存関係が更新可能かが一目瞭然

### 2. セキュリティの向上

- **脆弱性の早期検知**：セキュリティパッチがあると優先的にPRを作成
- **自動セキュリティ更新**：設定により、セキュリティ更新を自動マージ可能
- **依存関係の透明性**：どの依存関係が古いかが明確になる
- **インフラのセキュリティ**：Terraform Providerのセキュリティパッチも自動検知・更新可能

### 3. 柔軟なカスタマイズ

- **プロジェクトごとの設定**：リポジトリごとに異なる更新戦略を設定可能
- **更新頻度の制御**：週末のみ更新、特定の日時に更新など、スケジュールを制御可能
- **グループ化**：関連する更新を1つのPRにまとめることで、レビュー負荷を軽減

### 4. チーム開発での利点

- **コードレビューの効率化**：更新内容が明確なPRで、レビューがしやすい
- **技術負債の可視化**：どのパッケージが古いかが明確に
- **ドキュメント化**：PRの説明で、更新内容や変更理由が自動で記載される

### 5. 多様なパッケージマネージャーに対応

Renovateがサポートしている主なパッケージマネージャー：

- **JavaScript/TypeScript**: npm, yarn, pnpm
- **Python**: pip, pipenv, poetry, setuptools
- **Java**: Maven, Gradle
- **Ruby**: Bundler
- **Go**: go mod, dep
- **Docker**: Dockerfile, docker-compose.yml
- **GitHub Actions**: .github/workflows/*.yml
- **Terraform**: Terraform本体、Terraform Provider（AWS Provider、AWSCC Providerなど）
  - `versions.tf`や`.terraform-version`ファイルを自動検知
  - Providerのバージョン制約（`~>`, `>=`, `=`など）を自動更新
  - `.terraform.lock.hcl`の更新も検知可能
- **その他**: Kubernetes, Helm, など30種類以上

### 6. 実際の開発フローでの活用

```
1. 依存関係が更新される
   ↓
2. Renovateが自動検知
   ↓
3. PRが自動作成（更新内容、変更点が記載）
   ↓
4. CI/CDが実行され、テストが通ることを確認
   ↓
5. レビュー後にマージ
   ↓
6. 常に最新の依存関係を維持
```

## 困ったときは

### よくある問題と解決方法

#### PRが作成されない

- Renovate Appが正しくインストールされているか確認
- `renovate.json` が正しくマージされているか確認
- Renovateのログを確認（Settings > Integrations > Renovate から確認可能）

#### 更新頻度を調整したい

```json
{
  "schedule": ["every weekend"],
  "timezone": "Asia/Tokyo"
}
```

#### 特定のパッケージの更新を停止したい

```json
{
  "packageRules": [
    {
      "matchPackageNames": ["package-name"],
      "enabled": false
    }
  ]
}
```

#### プライベートパッケージレジストリを使用している場合

環境変数やSecretで認証情報を設定する必要があります。詳細はRenovateのドキュメントを参照してください。

#### PRが多すぎる場合

```json
{
  "packageRules": [
    {
      "matchUpdateTypes": ["patch", "minor"],
      "groupName": "Minor and patch updates"
    }
  ]
}
```

これにより、パッチとマイナーアップデートが1つのPRにまとめられます。

#### Terraform Providerの更新が検知されない場合

- `versions.tf`ファイルが正しい形式で記述されているか確認
- Providerの`source`が正しく指定されているか確認（例：`hashicorp/aws`）
- `renovate.json`で`terraform`マネージャーが有効になっているか確認

```json
{
  "terraform": {
    "enabled": true
  }
}
```

- `.terraform.lock.hcl`が存在する場合、これも更新対象になるため、`.gitignore`に含まれていないか確認

## もっと知りたい人へ

### 公式ドキュメント

- [Renovate公式ドキュメント](https://docs.renovatebot.com/)
- [Renovate設定オプション一覧](https://docs.renovatebot.com/configuration-options/)
- [Renovate GitHub App](https://github.com/apps/renovate)

### 参考リソース

- [Renovate GitHub リポジトリ](https://github.com/renovatebot/renovate)
- [Renovateサポートされているマネージャー](https://docs.renovatebot.com/modules/manager/)
- [Renovate設定例集](https://docs.renovatebot.com/config-presets/)

### 実践的なヒント

1. **段階的な導入**：最初はセキュリティ更新のみ有効にし、徐々に範囲を広げる
2. **グループ化の活用**：関連する更新はグループ化して、レビュー負荷を軽減
3. **スケジュールの調整**：チームの作業スケジュールに合わせて更新頻度を調整
4. **ラベルの活用**：PRにラベルを自動付与して、フィルタリングしやすくする

## まとめ

Renovateを導入することで、依存関係の管理が自動化され、開発チームの負担が大幅に軽減されます。特に、以下のような場合に効果的です：

- 複数のプロジェクトで多数の依存関係を管理している
- セキュリティパッチを迅速に適用したい
- 定期的な依存関係の更新作業を自動化したい
- 技術負債を削減し、常に最新の状態を維持したい
- **Terraformを使用してインフラを管理している場合**
  - Terraform本体のバージョン更新
  - Terraform Provider（AWS Provider、AWSCC Providerなど）のバージョン更新
  - インフラレベルの依存関係も自動的に最新状態を維持

まずは基本的な設定から始めて、プロジェクトのニーズに合わせて徐々にカスタマイズしていくことをおすすめします。Terraformプロジェクトでは、Providerの更新を適切にグループ化し、パッチ・マイナー更新は自動マージ、メジャー更新はレビュー対象とする設定が効果的です。

