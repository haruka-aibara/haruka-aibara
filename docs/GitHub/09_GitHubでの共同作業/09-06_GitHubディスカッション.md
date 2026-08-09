# GitHub ディスカッション

「質問なのか、バグ報告なのか分からない issue」が溜まっていく——「使い方を教えて」「この設計についてどう思う？」を issue で受けると、タスク管理（クローズすべき作業一覧）としての issue が薄まっていく。この「**作業ではない会話**」の受け皿が GitHub Discussions。

## issue との使い分け

| | Issues | Discussions |
|---|---|---|
| 性質 | 完了させるべき**作業** | 結論が出るとは限らない**会話** |
| 終わり方 | close（やった／やらない） | ベストアンサー選定 or 自然終了 |
| 向くもの | バグ、機能実装、タスク | 質問、アイデア出し、雑談、告知 |

Discussions はカテゴリ（Q&A、Ideas、Announcements、Show and tell 等）を持ち、**Q&A カテゴリでは回答をベストアンサーとしてマークできる**（Stack Overflow 的に機能する）。スレッド内の返信もネストするので、issue のフラットなコメント列より議論に向く。

運用のコツは接続の仕方：ディスカッションで議論 → 方針が固まったら issue 化（ディスカッションから「Create issue from discussion」で変換できる）→ PR で実装、という**会話→作業の一方通行**を作ること。逆に「質問っぽい issue」はメンテナがディスカッションへ変換できるので、入口を間違えても移送できる。

## 有効化と設定

リポジトリの Settings → Features → Discussions にチェックで有効化（Organization 全体のディスカッションも作れる）。デフォルトでは無効なので、存在に気づかれていないことも多い。

- **Announcements カテゴリ**はメンテナのみ投稿可・他は返信のみ、という告知向けの権限設定ができる
- issue と同様にラベル（[09-04](09-04_issueとPRのラベリング.md)）も付けられる

## どういうリポジトリで効くか

- **利用者のいる OSS・社内共通ツール**：「質問は Discussions へ、バグは issue テンプレートへ」と入口を分けるだけで、issue 一覧が「本当に対応すべきもの」に戻る
- **設計議論の記録**：Slack でやると流れて消える設計談義を Discussions でやれば、検索可能な意思決定ログとして残る（ADR の手前の議事録として使える）
- 逆に、少人数チームの内部リポジトリで会話も全部 issue で回っているなら、無理に分ける必要はない。入口が増えること自体もコストなので、「issue が会話で溢れてきたら導入」で十分

## 参考

- [GitHub Discussions documentation — GitHub Docs](https://docs.github.com/en/discussions)
- [Best practices for community conversations on GitHub — GitHub Docs](https://docs.github.com/en/discussions/guides/best-practices-for-community-conversations-on-github)
