# GitHub REST API

## はじめに

「GitHubの機能をプログラムから操作したい」「自動化スクリプトを作成したい」「カスタムツールを開発したい」そんな要望はありませんか？GitHub REST APIは、GitHubの機能をプログラムから利用するための強力なインターフェースです。この記事では、GitHub REST APIの基本的な使い方から実践的な活用方法まで解説します。

## ざっくり理解しよう

GitHub REST APIの重要なポイントは以下の3つです：

1. **豊富な機能**
   - リポジトリの操作
   - イシューとプルリクエストの管理
   - ユーザーと組織の情報取得

2. **認証とセキュリティ**
   - 個人アクセストークン（PAT）
   - OAuth認証
   - レート制限

3. **柔軟な利用方法**
   - HTTPリクエスト
   - クライアントライブラリ
   - Webhookとの連携

## 実際の使い方

### 基本的な使い方

1. 認証の設定
```bash
# 個人アクセストークンの生成
# GitHubの設定画面から生成

# 環境変数に設定
export GITHUB_TOKEN='your-token-here'
```

2. 基本的なAPIリクエスト
```bash
# リポジトリ情報の取得
curl -H "Authorization: token $GITHUB_TOKEN" \
     https://api.github.com/repos/owner/repo

# イシューの作成
curl -X POST -H "Authorization: token $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     https://api.github.com/repos/owner/repo/issues \
     -d '{"title":"New Issue","body":"Issue description"}'
```

3. レート制限の確認
```bash
# レート制限情報の取得
curl -H "Authorization: token $GITHUB_TOKEN" \
     https://api.github.com/rate_limit
```

## 手を動かしてみよう

### 基本的な手順

1. 認証の設定
```bash
# 個人アクセストークンの生成
# 1. GitHubの設定画面に移動
# 2. Developer settings > Personal access tokens
# 3. Generate new token
# 4. 必要な権限を選択
# 5. トークンをコピー
```

2. リポジトリの操作
```bash
# リポジトリの作成
curl -X POST -H "Authorization: token $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     https://api.github.com/user/repos \
     -d '{"name":"new-repo","private":true}'

# リポジトリのクローン
git clone https://github.com/owner/new-repo.git
```

3. イシューの管理
```bash
# イシューの一覧取得
curl -H "Authorization: token $GITHUB_TOKEN" \
     https://api.github.com/repos/owner/repo/issues

# イシューの作成
curl -X POST -H "Authorization: token $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     https://api.github.com/repos/owner/repo/issues \
     -d '{"title":"Bug Fix","body":"Description","labels":["bug"]}'
```

## 実践的なサンプル

### Pythonでの使用例

```python
import requests
import os

# 認証情報の設定
token = os.getenv('GITHUB_TOKEN')
headers = {
    'Authorization': f'token {token}',
    'Accept': 'application/vnd.github.v3+json'
}

# リポジトリ情報の取得
def get_repo_info(owner, repo):
    url = f'https://api.github.com/repos/{owner}/{repo}'
    response = requests.get(url, headers=headers)
    return response.json()

# イシューの作成
def create_issue(owner, repo, title, body, labels=None):
    url = f'https://api.github.com/repos/{owner}/{repo}/issues'
    data = {
        'title': title,
        'body': body,
        'labels': labels or []
    }
    response = requests.post(url, headers=headers, json=data)
    return response.json()

# 使用例
repo_info = get_repo_info('octocat', 'Hello-World')
issue = create_issue('octocat', 'Hello-World', 'New Issue', 'Description', ['bug'])
```

### Node.jsでの使用例

```javascript
const axios = require('axios');

// 認証情報の設定
const token = process.env.GITHUB_TOKEN;
const headers = {
    'Authorization': `token ${token}`,
    'Accept': 'application/vnd.github.v3+json'
};

// リポジトリ情報の取得
async function getRepoInfo(owner, repo) {
    const response = await axios.get(
        `https://api.github.com/repos/${owner}/${repo}`,
        { headers }
    );
    return response.data;
}

// イシューの作成
async function createIssue(owner, repo, title, body, labels = []) {
    const response = await axios.post(
        `https://api.github.com/repos/${owner}/${repo}/issues`,
        { title, body, labels },
        { headers }
    );
    return response.data;
}

// 使用例
async function main() {
    const repoInfo = await getRepoInfo('octocat', 'Hello-World');
    const issue = await createIssue('octocat', 'Hello-World', 'New Issue', 'Description', ['bug']);
}
```

## 困ったときは

### よくあるトラブルと解決方法

1. **認証エラーが発生する場合**
```bash
# トークンの権限を確認
# GitHubの設定画面で確認

# トークンを再生成
# 1. 古いトークンを削除
# 2. 新しいトークンを生成
# 3. 環境変数を更新
```

2. **レート制限に達した場合**
```bash
# レート制限情報の確認
curl -H "Authorization: token $GITHUB_TOKEN" \
     https://api.github.com/rate_limit

# 認証を改善
# 1. トークンを使用
# 2. OAuth認証を実装
```

3. **APIレスポンスが期待と異なる場合**
```bash
# レスポンスヘッダーの確認
curl -I -H "Authorization: token $GITHUB_TOKEN" \
     https://api.github.com/repos/owner/repo

# エラーメッセージの確認
curl -H "Authorization: token $GITHUB_TOKEN" \
     https://api.github.com/repos/owner/repo
```

### 予防するためのコツ

- 適切な認証方法の選択
- レート制限の監視
- エラーハンドリングの実装

## もっと知りたい人へ

### 次のステップ

- GraphQL APIの利用
- Webhookの実装
- カスタムアプリケーションの開発

### おすすめの学習リソース

- [GitHub REST API公式ドキュメント](https://docs.github.com/ja/rest)
- [GitHub API v3ガイド](https://docs.github.com/ja/rest/overview)

### コミュニティ情報

- [GitHub API Discussions](https://github.com/github/rest-api-description/discussions)
- [Stack Overflow - github-api](https://stackoverflow.com/questions/tagged/github-api)
