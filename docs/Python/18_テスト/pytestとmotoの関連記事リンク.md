# pytest と moto の関連記事リンク

[pytestとmotoをゼロから理解する](./pytestとmotoをゼロから理解する.html) は「なぜ実リソースを作らずに済むのか」の筋道を通すことを優先していて、実装パターンの網羅はしていない。実際に手を動かすときに読み返す用の外部記事をメモしておく。

## リンク

- **pytestとmotoで始めるLambda単体テスト入門**（DevelopersIO）
  https://dev.classmethod.jp/articles/introduction-python-lambda-testing/

  章立てで進む入門記事。テストしやすい構成の作り方、ファイル分割と依存性注入、moto を使ったデータ層のテスト、エラー・バリデーションのテスト、外部 API 呼び出しの扱いまで扱っている。ゼロから理解する記事で触れなかった「実際のプロジェクト構成にどう落とすか」を埋める。

- **MotoでLambdaコードからLambdaモックを呼び出す（Dockerなし）**（Zenn / NCDC）
  https://zenn.dev/ncdc/articles/eaa3d113c27f28

  Lambda が別の Lambda を呼ぶ構成のテスト。`mock_aws` に `{"lambda": {"use_docker": False}}` を渡して Docker なしで動かす方法と、テストファイル内で環境変数を Lambda コードの import より前にセットする必要がある点を扱っている。

## どちらを開くか

| 場面 | 開くもの |
|---|---|
| テストしやすい構成にしたい・書き始めの型が欲しい | DevelopersIO の入門記事 |
| Lambda から Lambda を呼ぶ構成をテストしたい | Zenn の記事 |
| なぜモックではなく moto なのか、moto で何が確かめられないのかを整理したい | [pytestとmotoをゼロから理解する](./pytestとmotoをゼロから理解する.html) |

## 参考

- pytestとmotoで始めるLambda単体テスト入門 - DevelopersIO
  https://dev.classmethod.jp/articles/introduction-python-lambda-testing/
- MotoでLambdaコードからLambdaモックを呼び出す（Dockerなし） - Zenn
  https://zenn.dev/ncdc/articles/eaa3d113c27f28
