# GitHub Actions のワークフロー入力（inputs）

## 概要

再利用可能なワークフローで`inputs`を使用することで、呼び出し元から値を渡すことができます。

## 基本構造

```yaml
# 再利用可能なワークフロー
on:
  workflow_call:
    inputs:
      input_name:
        type: string/number/boolean
        required: true/false
        default: 'デフォルト値'

# 呼び出し元
jobs:
  call-workflow:
    uses: ./.github/workflows/reusable.yml
    with:
      input_name: "値"
```

## 使用例

### 1. 基本的な使用

```yaml
# 呼び出し元
jobs:
  deploy:
    uses: ./.github/workflows/deploy.yml
    with:
      environment: "production"
      version: "1.0.0"

# 再利用可能なワークフロー
on:
  workflow_call:
    inputs:
      environment:
        type: string
        required: true
      version:
        type: string
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        run: echo "Deploying ${{ inputs.version }} to ${{ inputs.environment }}"
```

### 2. 条件付き実行

```yaml
jobs:
  build:
    if: inputs.environment == 'production'
    runs-on: ubuntu-latest
    steps:
      - name: Production build
        run: echo "Building for production"
```

## 注意点

1. 入力パラメータは文字列として扱われる
2. 複雑なデータはJSON形式で渡す
3. 機密情報は`secrets`を使用する
4. 入力値の検証は明示的に行う

## ベストプラクティス

1. **入力パラメータの設計**
   - 必要な入力のみを定義する
   - デフォルト値を適切に設定する
   - 型チェックを活用する
   - 入力値の検証ロジックを実装する

2. **ドキュメント化**
   - 各入力パラメータの目的を明確に記述する
   - 使用例を含める
   - 制約条件を明記する

3. **エラーハンドリング**
   - 必須パラメータのチェック
   - 型の検証
   - 値の範囲チェック

## まとめ

`inputs`を使用することで、再利用可能なワークフローをより柔軟に、かつ安全に使用することができます。適切な型チェックと検証ロジックを実装し、明確なドキュメントとともに使用することで、効率的なワークフロー管理が可能になります。 
