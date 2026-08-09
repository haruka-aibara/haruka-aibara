# Superpowers の使い方

## こういうときに使いたい

Claude Code に複雑なタスクを任せると、こういうことが起きがちだ。

- いきなりコードを書き始めて、設計の確認を飛ばす
- テストを書かずに「動きました」と言ってくる
- バグが出ると行き当たりばったりに修正を重ねて、根本原因にたどり着かない
- 長いタスクの途中で文脈を見失う

モデルの素の能力は高いのに、**「進め方（プロセス）」が場当たり的**なせいで成果物の質がブレる。これを埋めるのが Superpowers。

Superpowers は Jesse Vincent（GitHub: obra）が作った Claude Code 用プラグインで、**ソフトウェア開発の進め方そのものをスキルとして与える**もの。「ブレインストーミング → 設計 → 計画 → TDD で実装 → コードレビュー」という規律ある流れを、Claude が勝手にサボらず踏むようにする。コミュニティで最も使われているプラグインのひとつ。

---

## 何が「スキル」として入るのか

Superpowers の中身は、特別なバイナリやサーバーではなく **Markdown で書かれたスキルの集まり**。各スキルには「どういう手順で・何をチェックしながら進めるか」が書かれていて、Claude はタスクに着手する前にそれを読んでから動く。

主なスキルと、それが効く場面：

| スキル | やること | 効く場面 |
|--------|---------|---------|
| **Brainstorming** | 質問を重ねて要件と設計を詰める | いきなり実装に走らせたくない。仕様が曖昧なまま作られると困る |
| **Writing plans** | タスクを 2〜5 分単位に分解する | 大きな作業を丸投げすると迷子になる |
| **Test-driven development** | RED → GREEN → REFACTOR を強制 | 「テストなしで動いた」を防ぎたい |
| **Systematic debugging** | 4 フェーズで根本原因を特定 | 場当たり修正の繰り返しを止めたい |
| **Subagent-driven development** | サブエージェントに分担＋2段階レビュー | 並列で進めつつ品質ゲートを通したい |
| **Using git worktrees** | ブランチを worktree で隔離 | 並行作業で作業ツリーを汚したくない |
| **Requesting code review** | レビュー前チェックリスト | 出す前に自己点検させたい |
| **Writing skills** | 新しいスキルを作法に沿って作る | 自分の現場ルールをスキル化したい |

ポイントは、これらが**「提案」ではなく「手順」として効く**こと。Claude は関連スキルがあるか着手前に確認し、該当すれば手順に従う。

---

## インストール

セッション内の `/plugin` コマンドで入れる。公式マーケットプレイスから：

```bash
/plugin install superpowers@claude-plugins-official
```

公式に入っていない場合や本家の最新を使いたい場合は、作者のマーケットプレイスを登録してから入れる：

```bash
/plugin marketplace add obra/superpowers
/plugin install superpowers@superpowers
```

インストール後は再起動なしで反映される（必要なら `/reload-plugins`）。

> Claude Code 以外（Codex CLI / Cursor / Gemini CLI など）にも対応している。各ツールでのインストール方法は[本家 README](https://github.com/obra/superpowers) を参照。

---

## 使い方：特別なコマンドは要らない

Superpowers の特徴は、**スキルが文脈に応じて自動で発火する**こと。専用のスラッシュコマンドを覚える必要はなく、いつも通りに頼めばいい。

```text
> この機能を実装したい。まず要件を整理したい

→ Brainstorming スキルが発火し、Claude が質問で仕様を詰めてくる
```

```text
> このバグの原因を調べて直して

→ Systematic debugging スキルが発火し、
  根本原因を特定してから直すフローに入る
```

明示的に促したいときは「ブレインストーミングから始めて」「TDD で実装して」と言葉で指定すればよい。

---

## 入れる前に：自分のフローに合うか確認する

Superpowers は強力だが、**規律を「強制」する**プラグインなので、使い方によっては過剰に感じることもある。

- ちょっとした調べ物・1 行修正にまで設計フローを挟まれると冗長
- スキルを読み込むぶん、コンテキストとトークンを消費する

[プラグインの使い方](プラグインの使い方.md) でも触れたとおり、拡張は「実際に使うものだけ入れる」のが基本。Superpowers が効くのは、**ある程度まとまった機能開発やリファクタを Claude に任せる**ような場面だ。小さな単発タスク中心なら、無理に常用しなくていい。

合わなければ外せる：

```bash
/plugin uninstall superpowers
```

---

## セキュリティ／運用視点でのひとこと

Superpowers は外部マーケットプレイスのコードを実行環境に持ち込むものでもある。業務環境で入れるなら、

- **どのマーケットプレイス由来か**を確認する（公式 `claude-plugins-official` か、`obra/superpowers` 本家か）。素性不明のフォークを `marketplace add` しない
- スキルは Markdown とはいえ Claude の振る舞いを変える。**何が同梱されているか**は中身を一度見ておく（`Writing skills` の作法に沿って自分でもスキルを足せる）
- チームで使うなら、導入するプラグイン・マーケットプレイスを**許可リストとして決めておく**と、各自が勝手に野良プラグインを足す状態を防げる

「便利だから全員入れる」ではなく、**何に使うか（=まとまった開発タスクの品質を底上げする）が決まってから**入れる。

---

## 参考

- [obra/superpowers - GitHub](https://github.com/obra/superpowers)
- [Superpowers – Claude Plugin | Anthropic](https://claude.com/plugins/superpowers)
- [Superpowers: How I'm using coding agents in October 2025 - Simon Willison](https://simonwillison.net/2025/Oct/10/superpowers/)
- [Discover and install plugins - Claude Code Docs](https://code.claude.com/docs/en/discover-plugins)
