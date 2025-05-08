# GitHub Actions: multiple jobs (in parallel / sequential)

## 概要
GitHub Actionsの複数ジョブ機能を使うと、CIパイプラインの効率化と並列処理による時間短縮が可能になります。

## 理論的説明
GitHub Actionsのワークフローでは、複数のジョブを定義し、それらを並列または順次実行するよう設定できます。

## 並列ジョブ (Parallel Jobs)

### 基本的な並列ジョブの設定
複数のジョブは、デフォルトでは並列に実行されます：

```yaml
jobs:
  job1:
    runs-on: ubuntu-latest
    steps:
      - name: Job 1 ステップ1
        run: echo "Job 1 実行中..."
      
  job2:
    runs-on: ubuntu-latest
    steps:
      - name: Job 2 ステップ1
        run: echo "Job 2 実行中..."
```

このような設定では、`job1`と`job2`は同時に実行されます。

### 並列ジョブの利点
- 実行時間の短縮
- 独立したテストの同時実行
- 複数環境での同時ビルド検証

## 順次ジョブ (Sequential Jobs)

### 依存関係の設定方法
ジョブを順番に実行するには、`needs`キーワードを使用します：

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: ビルドステップ
        run: echo "ビルド中..."
  
  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: テストステップ
        run: echo "テスト中..."
  
  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: デプロイステップ
        run: echo "デプロイ中..."
```

この例では、`build` → `test` → `deploy`の順に実行されます。

### 複数依存関係の設定
一つのジョブが複数のジョブの完了を待つ場合：

```yaml
jobs:
  job1:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Job 1 実行中..."
  
  job2:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Job 2 実行中..."
  
  job3:
    needs: [job1, job2]
    runs-on: ubuntu-latest
    steps:
      - run: echo "Job 1とJob 2が完了したため、Job 3を実行します"
```

この例では、`job3`は`job1`と`job2`の両方が完了してから実行されます。

## 条件付きジョブ（Conditional Jobs）

特定の条件下でのみジョブを実行するには`if`条件を使用します：

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: ビルドステップ
        run: echo "ビルド中..."
  
  deploy-production:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: 本番環境へのデプロイ
        run: echo "mainブランチのため、本番環境にデプロイします"
  
  deploy-staging:
    needs: build
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    steps:
      - name: ステージング環境へのデプロイ
        run: echo "developブランチのため、ステージング環境にデプロイします"
```

この例では、ブランチによって実行されるデプロイジョブが異なります。

## マトリックス戦略を使った並列ジョブ

複数の設定や環境で同じジョブを並列実行するには：

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [14.x, 16.x, 18.x]
    
    steps:
      - uses: actions/checkout@v3
      - name: Node.js ${{ matrix.node-version }} セットアップ
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
      - name: テスト実行
        run: npm test
```

この例では、Node.jsの3つのバージョンでテストが並列に実行されます。

## 実際の使用例：CI/CDパイプライン

```yaml
name: CI/CD パイプライン

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Node.js セットアップ
        uses: actions/setup-node@v3
        with:
          node-version: 16.x
      - name: 依存関係インストール
        run: npm ci
      - name: Lint実行
        run: npm run lint

  test:
    runs-on: ubuntu-latest
    needs: lint
    strategy:
      matrix:
        node-version: [14.x, 16.x]
    steps:
      - uses: actions/checkout@v3
      - name: Node.js ${{ matrix.node-version }} セットアップ
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
      - name: 依存関係インストール
        run: npm ci
      - name: テスト実行
        run: npm test

  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v3
      - name: Node.js セットアップ
        uses: actions/setup-node@v3
        with:
          node-version: 16.x
      - name: 依存関係インストール
        run: npm ci
      - name: ビルド実行
        run: npm run build
      - name: ビルド成果物アップロード
        uses: actions/upload-artifact@v3
        with:
          name: build-files
          path: dist/

  deploy:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    steps:
      - name: ビルド成果物ダウンロード
        uses: actions/download-artifact@v3
        with:
          name: build-files
          path: dist/
      - name: デプロイ実行
        run: echo "本番環境にデプロイします"
```

この例では：
1. lintジョブが最初に実行
2. lintが成功したら、複数のNode.jsバージョンで並列にテスト
3. テストが成功したら、ビルドを実行
4. mainブランチへのpushイベントの場合のみ、デプロイを実行

## まとめ

GitHub Actionsの複数ジョブ機能を活用することで：
- 並列実行による時間短縮
- 順次実行による依存関係の制御
- 条件付き実行による柔軟なワークフロー設計
- マトリックス戦略による多環境テスト

が可能になります。これらを適切に組み合わせることで、効率的なCI/CDパイプラインを構築できます。
