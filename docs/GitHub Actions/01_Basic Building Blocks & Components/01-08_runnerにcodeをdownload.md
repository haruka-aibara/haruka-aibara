# GitHub Actionsでのランナーへのコード・ダウンロード

GitHub Actionsのワークフローにおいて、ランナー上にコードをダウンロードすることは自動化プロセスの基盤となる重要なステップです。

ランナーとは、GitHub Actionsのワークフローを実行するための仮想環境であり、そこにリポジトリのコードをダウンロードすることでCI/CDプロセスが開始されます。

## ランナーへのコードダウンロード方法

GitHub Actionsでは、ワークフローの最初のステップとして、通常`actions/checkout`アクションを使用してコードをダウンロードします。

```yaml
steps:
  - name: コードのチェックアウト
    uses: actions/checkout@v4
```

この単純なステップにより、ワークフローを実行しているリポジトリのコードがランナーにダウンロードされます。

## 高度なチェックアウト設定

基本的なチェックアウト以外にも、様々な設定オプションがあります：

```yaml
steps:
  - name: 特定のブランチをチェックアウト
    uses: actions/checkout@v4
    with:
      ref: develop        # 特定のブランチやタグ、コミットID
      fetch-depth: 0      # 全履歴をダウンロード（デフォルトは1）
      submodules: true    # サブモジュールもダウンロード
```

## プライベートリポジトリのチェックアウト

別のプライベートリポジトリからコードをダウンロードする場合は、トークンを使用する必要があります：

```yaml
steps:
  - name: プライベートリポジトリのチェックアウト
    uses: actions/checkout@v4
    with:
      repository: owner/another-repo
      token: ${{ secrets.ACCESS_TOKEN }}
      path: another-repo  # ダウンロード先のディレクトリ
```

## チェックアウト後の確認

コードが正しくダウンロードされたことを確認するには：

```yaml
steps:
  - name: コードのチェックアウト
    uses: actions/checkout@v4
  
  - name: ダウンロードされたファイルの確認
    run: ls -la
```

これにより、ランナー上のファイルが表示され、チェックアウトが正常に完了したことを確認できます。

## まとめ

GitHub Actionsでのランナーへのコードダウンロードは、`actions/checkout`アクションを使うことで簡単に実装できます。このステップは通常ワークフローの最初に配置され、その後の全ての操作の基礎となります。
