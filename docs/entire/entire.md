# entire — 元 GitHub CEO の新ツール、本当に必要か？

## 何をするツールか

2026年2月、元 GitHub CEO の Thomas Dohmke が立ち上げたスタートアップのCLIツール。

git commit のたびに AI セッションのスナップショット（プロンプト・会話・変更ファイル）をシャドウブランチに自動保存する。`entire rewind` で任意のチェックポイントに巻き戻せる。

```bash
entire enable   # リポジトリに有効化
entire rewind   # チェックポイントに巻き戻し
entire explain  # そのセッションで何が起きたかを確認
entire resume   # 前のセッションの続きから再開
```

## 売り文句と、それへの素直な疑問

entire のマーケティングは「AI が書いたコードはなぜそうなったかの経緯が残らない。プロベナンス・ギャップだ」という問題設定から始まる。

**ただ、これは人間のコードも同じだった。**

git は昔から「何を変えたか」しか記録しない。「なぜ変えたか」はコードコメントや PR の説明欄に人間が書いてきた。AI だって同じことができる。Claude Code はセッション終了時にサマリーを出すし、PR の説明を自動生成するツールも多い。

「なぜそう書いたか」問題は、AI にちゃんとコメントと PR を書かせれば大半は解決する。

## では entire に固有の価値はあるか

正直に絞ると、2点だけ残る。

**1. 失敗した試みの記録**

コメントや PR に残るのは「うまくいったもの」だけ。AI は人間より大量に試行錯誤する（5つのアプローチを試して6つ目を採用、など）。「なぜこのアプローチを捨てたか」という情報は、現状どこにも残らない。

ただ、これが実際の開発で「あとで必要になった」経験がどれだけあるか、は人による。

**2. セッションの巻き戻しと再開**

AI エージェントが30分かけて間違った方向に進んだとき、git で元のファイル状態に戻すことはできる。でも「AI との会話の文脈ごと巻き戻して、別のアプローチを試す」は git 単体ではできない。entire の rewind はファイル状態と AI コンテキストを一緒に戻せる。

これは確かに git にない機能だが——「AI に『この方向は失敗だった、やり直そう』と伝えれば済む」という反論も成立する。

## 結局どう見るか

現時点の entire は「あると便利かもしれないが、なくても困らない」レベルのツールだと思う。既存の git + コメント + PR の習慣を少し改善すれば代替できる問題を、新しいツールで解こうとしている。

$6,000万ドル（約90億円）のシードで調達されているが、これは現在の製品への評価というより、**元 GitHub CEO が AI コーディングのプロベナンス問題に本気で取り組むという賭けへの投資**と見るのが実態に近い。Dohmke は GitHub で Copilot の普及を最前線で見てきた人物で、「AI が書くコード量が爆発的に増えたとき、今の git/PR 習慣では追いつかなくなる」というビジョンを持っている。

**長期的な本命はCLIではない。**

Dohmke が語るロードマップは「AI ネイティブの開発プラットフォーム全体」だ。今の entire CLI は入り口で、最終的には「1日に数百の AI 生成変更をレビュー・承認するための UI」「複数エージェントが連携する推論レイヤー」まで構築しようとしている。つまり、**GitHub を再発明しようとしている**。

それが必要になる未来が来るかどうか、そこにかかっている。

## 気にしておくべきリスク

- **GitHub 自身が取り込む**：Copilot に同様の機能を組み込めば entire の市場は消える。Dohmke が古巣を相手に戦うことになる
- **AI エージェント側が進化する**：エージェント自体がセッション管理・引き継ぎ機能を持てば、外部ツールは不要になる
- **問題が思ったより小さい**：「AI セッションの巻き戻しが必要になった」という経験が広まらなければ、ニッチなままで終わる

## 参考

- [Entire 公式サイト](https://entire.io/)
- [GitHub - entireio/cli](https://github.com/entireio/cli)
- [Former GitHub CEO raises record $60M dev tool seed round at $300M valuation | TechCrunch](https://techcrunch.com/2026/02/10/former-github-ceo-raises-record-60m-dev-tool-seed-round-at-300m-valuation/)
- [GitHub's former CEO launches a developer platform for the age of agentic coding | The New Stack](https://thenewstack.io/thomas-dohmke-interview-entire/)
- [Entire CLI: Version Control for Your Agent Sessions | mager.co](https://www.mager.co/blog/2026-02-10-entire-cli/)
- [Former GitHub CEO launches AI coding startup | Axios](https://www.axios.com/2026/02/10/former-github-ceo-ai-coding-startup)
