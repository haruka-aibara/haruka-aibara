<!-- Space: harukaaibarapublic -->
<!-- Parent: GitHub Actions -->
<!-- Title: 実践的な CI パイプライン -->

# 実践的な CI パイプライン

「PR をマージしたら本番で動かないコードが入った」「テストをローカルで回し忘れた」——CI パイプラインを整備すれば、コードレビュー前に機械が問題を見つけてくれる。

---

## 基本構造

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          cache: 'pip'

      - name: Install dependencies
        run: pip install -r requirements.txt

      - name: Lint
        run: ruff check .

      - name: Type check
        run: mypy .

      - name: Test
        run: pytest --cov=src --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
```

---

## 並列ジョブでパイプラインを高速化

lint・test・security scan を並列実行する。直列だと全部合わせて 5 分かかるものが 2 分に縮む。

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: {python-version: '3.12', cache: 'pip'}
      - run: pip install ruff && ruff check .

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: {python-version: '3.12', cache: 'pip'}
      - run: pip install -r requirements.txt && pytest

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'

  # 全ジョブが通ったら次のステージへ
  ci-success:
    needs: [lint, test, security]
    runs-on: ubuntu-latest
    steps:
      - run: echo "All checks passed"
```

---

## マトリクスで複数環境をテスト

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.10', '3.11', '3.12']
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
      - run: pip install -r requirements.txt && pytest
```

3バージョン × Ubuntu = 3ジョブが同時実行される。

---

## Docker イメージビルド＋ ECR プッシュ

```yaml
jobs:
  build-and-push:
    runs-on: ubuntu-latest
    needs: [lint, test]
    permissions:
      id-token: write   # OIDC 認証に必要
      contents: read
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/github-actions-role
          aws-region: ap-northeast-1

      - name: Login to ECR
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          push: true
          tags: |
            123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/myapp:${{ github.sha }}
            123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/myapp:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

`cache-from/cache-to: type=gha` で GitHub Actions のキャッシュを使い、2回目以降のビルドを高速化する。

---

## PR にコメントでテスト結果を通知

```yaml
      - name: Comment PR with coverage
        uses: MishaKav/pytest-coverage-comment@main
        with:
          pytest-coverage-path: ./coverage.xml
          title: 'Test Coverage'
```

PR にカバレッジ率と差分が自動コメントされる。

---

## よくある失敗パターン

| 問題 | 原因 | 対策 |
|---|---|---|
| 毎回 `pip install` が遅い | キャッシュ未設定 | `setup-python` の `cache: 'pip'` を使う |
| secrets が `***` になって動かない | fork PR から secrets にアクセス不可 | `pull_request_target` イベントを使う（注意して使う） |
| main ブランチへの直接 push で CI が走らない | `on: push` の branches 設定漏れ | `branches: [main]` を明示する |
| 1つのジョブ失敗で他も不要に止まる | デフォルトの `fail-fast: true` | `strategy.fail-fast: false` を設定 |
