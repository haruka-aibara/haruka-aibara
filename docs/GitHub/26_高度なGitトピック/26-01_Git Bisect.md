# Git Bisect

## はじめに

「このバグはいつ入ったんだろう？」「どのコミットで問題が発生したのか特定したい」そんな経験はありませんか？Git Bisectは、そんな問題を効率的に解決するための強力なツールです。この記事では、Git Bisectの基本的な使い方から実践的な活用方法まで解説します。

## ざっくり理解しよう

Git Bisectの重要なポイントは以下の3つです：

1. **二分探索による効率的なバグ特定**
   - コミット履歴を効率的に二分探索し、問題の原因となったコミットを特定
   - 手動で全てのコミットを確認する必要がなく、大幅な時間短縮が可能

2. **自動化と手動操作の両対応**
   - テストスクリプトを使った自動化が可能
   - 手動での確認も柔軟に行える

3. **安全な調査環境**
   - 各コミットの状態を安全に確認可能
   - 調査後は簡単に元の状態に戻せる

## 実際の使い方

### 基本的な使い方

1. 問題が発生している最新のコミット（bad）と、問題が発生していないことが確実な過去のコミット（good）を特定
2. `git bisect start` で調査を開始
3. `git bisect good <commit>` と `git bisect bad <commit>` で範囲を指定
4. Gitが自動的に中間のコミットをチェックアウト
5. そのコミットで問題が発生しているかどうかを確認
6. 結果に応じて `git bisect good` または `git bisect bad` を実行
7. 問題の原因となったコミットが特定されるまで4-6を繰り返す

### 自動化する場合

```bash
# テストスクリプトを実行して自動的に判定
git bisect run ./test.sh

# 特定のテストケースのみを実行
git bisect run npm test -- -t "特定のテストケース"
```

## 手を動かしてみよう

### 基本的な手順

1. リポジトリのクローン
```bash
git clone <repository-url>
cd <repository-name>
```

2. 調査の開始
```bash
git bisect start
```

3. 範囲の指定
```bash
git bisect bad HEAD  # 最新のコミットが問題あり
git bisect good v1.0.0  # このバージョンは問題なし
```

4. 調査の実行
- Gitが自動的に中間のコミットをチェックアウト
- 問題の有無を確認
- 結果に応じて `git bisect good` または `git bisect bad` を実行

5. 調査の終了
```bash
git bisect reset  # 元の状態に戻る
```

## 実践的なサンプル

### テストスクリプトの例

```bash
#!/bin/bash
# test.sh

# テストを実行
npm test

# テストの結果に基づいて終了コードを返す
# 0: 成功（good）
# 1: 失敗（bad）
exit $?
```

### 特定のテストケースのみを実行する例

```bash
# package.jsonのテストスクリプト
{
  "scripts": {
    "test": "jest",
    "test:bisect": "jest --testNamePattern='特定のテストケース'"
  }
}

# 実行コマンド
git bisect run npm run test:bisect
```

## 困ったときは

### よくあるトラブルと解決方法

1. **調査をやり直したい場合**
```bash
git bisect reset
git bisect start
```

2. **間違えてgood/badを指定した場合**
```bash
git bisect reset
git bisect start
# 最初からやり直し
```

3. **特定のコミットをスキップしたい場合**
```bash
git bisect skip
```

### 予防するためのコツ

- 調査前に必ず作業内容をコミットまたはスタッシュ
- テストスクリプトは事前に動作確認
- 調査範囲は適切に設定（広すぎると時間がかかる）

## もっと知りたい人へ

### 次のステップ

- Git Bisectの自動化をさらに発展させる
- 複数の問題を同時に調査する方法
- 大規模なリポジトリでの効率的な使用方法

### おすすめの学習リソース

- [Git公式ドキュメント - Bisect](https://git-scm.com/docs/git-bisect)
- [Pro Git Book - Bisect](https://git-scm.com/book/ja/v2/Git-%E3%81%AE%E3%83%84%E3%83%BC%E3%83%AB-%E3%83%87%E3%83%90%E3%83%83%E3%82%AE%E3%83%B3%E3%82%B0%E3%81%A8%E3%83%93%E3%82%B8%E3%82%A7%E3%82%AF%E3%83%88)

### コミュニティ情報

- [GitHub Discussions](https://github.com/git/git/discussions)
- [Stack Overflow - git-bisect](https://stackoverflow.com/questions/tagged/git-bisect)
