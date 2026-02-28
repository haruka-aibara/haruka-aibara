<!-- Space: harukaaibarapublic -->
<!-- Parent: GitHub-Confluence同期 -->
<!-- Title: mark イメージを ECR で管理して GitHub Actions から使う -->

# mark イメージを ECR で管理して GitHub Actions から使う

ghcr.io への外部依存をなくし、mark の Docker イメージを自社 ECR で管理する構成。
GitHub Actions からは OIDC 認証で AWS に接続するため、静的な AWS 認証情報を Secrets に持たせる必要がない。

## 全体構成

```
ghcr.io/kovetskiy/mark  ──(一度だけミラーリング)──▶  ECR
                                                        ▲
GitHub Actions  ──OIDC──▶  AWS IAM Role  ──▶  ECR pull  ──▶  docker run
```

## 前提条件

- AWS アカウントがある
- Terraform で AWS リソースを管理している
- GitHub リポジトリに GitHub Actions が使える

---

## Step 1: Terraform で ECR リポジトリと IAM ロールを作成する

### ECR リポジトリ

```hcl
resource "aws_ecr_repository" "mark" {
  name                 = "mark"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
```

### GitHub Actions 用 OIDC IAM ロール

GitHub Actions の OIDC プロバイダーがまだない場合は作成する：

```hcl
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}
```

既にある場合は `data` で参照する：

```hcl
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}
```

IAM ロール（`repo:` の部分を自分のリポジトリに変更）：

```hcl
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:<GITHUB_ORG>/<REPO_NAME>:*"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "github_actions_confluence_sync" {
  name               = "github-actions-confluence-sync"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}
```

ECR pull 権限をアタッチ：

```hcl
data "aws_iam_policy_document" "ecr_pull" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]
    resources = [aws_ecr_repository.mark.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecr_pull" {
  name   = "ecr-pull-mark"
  policy = data.aws_iam_policy_document.ecr_pull.json
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr_pull" {
  role       = aws_iam_role.github_actions_confluence_sync.name
  policy_arn = aws_iam_policy.ecr_pull.arn
}
```

`apply` 後、出力された IAM ロール ARN を GitHub Secrets に登録する：

| Secret 名 | 値 |
|---|---|
| `AWS_IAM_ROLE_ARN` | `arn:aws:iam::<ACCOUNT_ID>:role/github-actions-confluence-sync` |

---

## Step 2: mark イメージを ECR にミラーリングする（初回のみ）

```bash
# ECR にログイン
aws ecr get-login-password --region ap-northeast-1 | \
  docker login --username AWS --password-stdin \
  $(aws sts get-caller-identity --query Account --output text).dkr.ecr.ap-northeast-1.amazonaws.com

# Docker Hub から pull
docker pull kovetskiy/mark:latest

# ECR 用にタグを付け直す
ECR_REGISTRY=$(aws sts get-caller-identity --query Account --output text).dkr.ecr.ap-northeast-1.amazonaws.com
docker tag kovetskiy/mark:latest ${ECR_REGISTRY}/mark:latest

# ECR に push
docker push ${ECR_REGISTRY}/mark:latest
```

バージョンを固定して管理する場合：

```bash
docker pull kovetskiy/mark:v15.3.0
docker tag kovetskiy/mark:v15.3.0 ${ECR_REGISTRY}/mark:v15.3.0
docker push ${ECR_REGISTRY}/mark:v15.3.0
```

---

## Step 3: GitHub Actions workflow を更新する

IAM ロール ARN をコードに直接書かず、`AWS_IAM_ROLE_ARN` Secret 経由で渡す。
ECR のレジストリ URL は `amazon-ecr-login` の出力から取得するため、アカウント ID をファイルに書く必要がない。

```yaml
name: Sync to Confluence

on:
  push:
    branches:
      - main
    paths:
      - 'Confluence/**'
  workflow_dispatch:

permissions:
  id-token: write
  contents: read

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_IAM_ROLE_ARN }}
          aws-region: ap-northeast-1

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Sync Markdown to Confluence
        run: |
          docker run --rm \
            -e MARK_USERNAME="${{ secrets.CONFLUENCE_USER }}" \
            -e MARK_PASSWORD="${{ secrets.CONFLUENCE_API_TOKEN }}" \
            -e MARK_BASE_URL="${{ secrets.CONFLUENCE_BASE_URL }}" \
            -v "${{ github.workspace }}:/workspace" \
            -w /workspace \
            ${{ steps.login-ecr.outputs.registry }}/mark:latest \
            -files "Confluence/**/*.md"
```

### permissions について

| 権限 | 用途 |
|---|---|
| `id-token: write` | OIDC トークンの発行（AWS 認証に必要） |
| `contents: read` | リポジトリのチェックアウト |

---

## 運用メモ

### mark イメージの更新

mark の新バージョンがリリースされたら Step 2 と同じ手順でミラーリングし直す。

### ECR のイメージスキャン

`scan_on_push = true` により push のたびに脆弱性スキャンが走る。
ECR コンソール → リポジトリ → mark → イメージ → 脆弱性 から確認できる。

### 親ページの指定

Confluence のページ階層を管理したい場合は各 Markdown ファイルのヘッダーに追記する：

```markdown
<!-- Space: <SPACE_KEY> -->
<!-- Parent: 親ページのタイトル -->
<!-- Title: このページのタイトル -->
```
