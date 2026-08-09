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
- name: Cache npm dependencies
  uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-npm-
```

## キャッシュの動作について

GitHub Actionsのキャッシュは、ワークフローの実行間で自動的に共有されます。例えば：

1. 最初のワークフロー実行時に`npm install`を実行すると、`~/.npm`ディレクトリにパッケージのキャッシュが保存されます
2. 次のワークフロー実行時には、同じキャッシュキーが存在する場合、キャッシュから`~/.npm`が復元されます
3. これにより、毎回npmパッケージをダウンロードする必要がなくなり、ワークフローの実行時間が大幅に短縮されます

この仕組みにより、同じリポジトリの異なるワークフロー実行間で、依存関係のダウンロード時間を節約することができます。

## 公式ドキュメント

- [actions/cache](https://github.com/actions/cache)
- [依存関係のキャッシュ](https://docs.github.com/ja/actions/using-workflows/caching-dependencies-to-speed-up-workflows)
