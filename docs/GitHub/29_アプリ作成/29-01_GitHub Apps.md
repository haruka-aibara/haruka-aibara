# GitHub Apps

## はじめに

「GitHubの機能を拡張したい」「カスタムの自動化ツールを作りたい」「組織のワークフローを改善したい」そんな要望はありませんか？GitHub Appsは、GitHubの機能を拡張するための強力なプラットフォームです。この記事では、GitHub Appsの基本的な使い方から実践的な開発方法まで解説します。

## ざっくり理解しよう

GitHub Appsの重要なポイントは以下の3つです：

1. **細かい権限管理**
   - リポジトリ単位での権限設定
   - 必要な権限のみを要求
   - セキュアな認証

2. **柔軟な機能拡張**
   - Webhookによるイベント処理
   - APIとの連携
   - カスタムUIの提供

3. **スケーラブルな設計**
   - 複数リポジトリへの対応
   - 組織全体での利用
   - マーケットプレイスでの公開

## 実際の使い方

### 基本的な使い方

1. GitHub Appの作成
```bash
# 1. GitHubの設定画面に移動
# 2. Developer settings > GitHub Apps
# 3. New GitHub App
# 4. 必要な情報を入力
```

2. アプリの設定
```yaml
# 基本的な設定
name: "My GitHub App"
description: "A custom GitHub App"
url: "https://my-app.example.com"
webhook_url: "https://my-app.example.com/webhook"
```

3. 権限の設定
```yaml
# 必要な権限を設定
permissions:
  issues: write
  pull_requests: write
  contents: read
```

## 手を動かしてみよう

### 基本的な手順

1. プロジェクトの作成
```bash
# プロジェクトディレクトリの作成
mkdir my-github-app
cd my-github-app

# 必要なパッケージのインストール
npm init -y
npm install @octokit/app @octokit/rest
```

2. アプリの実装
```javascript
// app.js
const { App } = require('@octokit/app');
const { Octokit } = require('@octokit/rest');

// アプリの初期化
const app = new App({
  id: process.env.APP_ID,
  privateKey: process.env.PRIVATE_KEY,
});

// インスタンスの作成
const octokit = new Octokit({
  auth: app.getSignedJsonWebToken(),
});

// Webhookの処理
app.webhooks.on('issues.opened', async ({ octokit, payload }) => {
  const { owner, repo, number } = payload.issue;
  
  // イシューにコメントを追加
  await octokit.issues.createComment({
    owner,
    repo,
    issue_number: number,
    body: 'Thank you for opening this issue!',
  });
});
```

3. Webhookの設定
```javascript
// webhook.js
const express = require('express');
const app = express();

app.post('/webhook', express.json(), (req, res) => {
  const event = req.headers['x-github-event'];
  const payload = req.body;
  
  // イベントの処理
  if (event === 'issues') {
    // イシューイベントの処理
  }
  
  res.status(200).send('OK');
});

app.listen(3000, () => {
  console.log('Webhook server is running on port 3000');
});
```

## 実践的なサンプル

### イシュー管理アプリの例

```javascript
// issue-manager.js
const { App } = require('@octokit/app');
const { Octokit } = require('@octokit/rest');

class IssueManager {
  constructor(appId, privateKey) {
    this.app = new App({
      id: appId,
      privateKey: privateKey,
    });
  }

  async handleIssueOpened(payload) {
    const { owner, repo, number } = payload.issue;
    const octokit = new Octokit({
      auth: this.app.getSignedJsonWebToken(),
    });

    // イシューの分析
    const issue = await octokit.issues.get({
      owner,
      repo,
      issue_number: number,
    });

    // ラベルの追加
    await octokit.issues.addLabels({
      owner,
      repo,
      issue_number: number,
      labels: ['needs-review'],
    });

    // コメントの追加
    await octokit.issues.createComment({
      owner,
      repo,
      issue_number: number,
      body: 'This issue has been automatically labeled for review.',
    });
  }
}

module.exports = IssueManager;
```

### プルリクエストレビューアプリの例

```javascript
// pr-reviewer.js
const { App } = require('@octokit/app');
const { Octokit } = require('@octokit/rest');

class PRReviewer {
  constructor(appId, privateKey) {
    this.app = new App({
      id: appId,
      privateKey: privateKey,
    });
  }

  async handlePROpened(payload) {
    const { owner, repo, number } = payload.pull_request;
    const octokit = new Octokit({
      auth: this.app.getSignedJsonWebToken(),
    });

    // 変更内容の取得
    const files = await octokit.pulls.listFiles({
      owner,
      repo,
      pull_number: number,
    });

    // レビューコメントの作成
    const review = {
      owner,
      repo,
      pull_number: number,
      body: 'Automated review',
      event: 'COMMENT',
      comments: files.data.map(file => ({
        path: file.filename,
        position: 1,
        body: 'Please review this change.',
      })),
    };

    await octokit.pulls.createReview(review);
  }
}

module.exports = PRReviewer;
```

## 困ったときは

### よくあるトラブルと解決方法

1. **認証エラーが発生する場合**
```bash
# 秘密鍵の確認
cat private-key.pem

# 環境変数の確認
echo $APP_ID
echo $PRIVATE_KEY
```

2. **Webhookが動作しない場合**
```bash
# Webhookの設定を確認
# GitHubの設定画面で確認

# ログの確認
tail -f webhook.log
```

3. **権限エラーが発生する場合**
```yaml
# 権限の確認
permissions:
  issues: write
  pull_requests: write
  contents: read
```

### 予防するためのコツ

- 適切な権限設定
- エラーハンドリングの実装
- ログの記録

## もっと知りたい人へ

### 次のステップ

- マーケットプレイスへの公開
- 高度な機能の実装
- パフォーマンスの最適化

### おすすめの学習リソース

- [GitHub Apps公式ドキュメント](https://docs.github.com/ja/apps)
- [GitHub Apps開発ガイド](https://docs.github.com/ja/apps/creating-github-apps)

### コミュニティ情報

- [GitHub Apps Discussions](https://github.com/github/github-apps/discussions)
- [Stack Overflow - github-apps](https://stackoverflow.com/questions/tagged/github-apps)
