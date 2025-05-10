# GitHub Actionsにおける依存関係のキャッシュ

GitHub Actionsのワークフロー実行時間を短縮するために、依存関係（dependencies）をキャッシュする機能について説明します。

## 概要と重要性

依存関係のキャッシュは、ワークフローの実行時間を大幅に短縮し、CI/CDパイプラインの効率を向上させる重要な機能です。

## 主要概念

依存関係のキャッシュは、`actions/cache`アクションを使用して、パッケージマネージャー（npm, pip, Maven等）の依存関係を保存・再利用する仕組みです。

## 特に重視するポイント

- キャッシュの有効期限（expiration）と最大サイズ（maximum size）の設定
- キャッシュキー（cache key）の適切な設計
- キャッシュの復元（restore）と保存（save）のタイミング
- キャッシュの無効化（invalidation）戦略

## 基本的な使用方法

```yaml
- name: Cache dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.npm
      node_modules
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

## 公式ドキュメント

- [actions/cache](https://github.com/actions/cache)
- [依存関係のキャッシュ](https://docs.github.com/ja/actions/using-workflows/caching-dependencies-to-speed-up-workflows)
