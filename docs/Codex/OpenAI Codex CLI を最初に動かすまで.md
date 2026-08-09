# OpenAI Codex CLI を最初に動かすまで

## どんな場面で必要か

Claude Code や Cursor を普段使っていても、「Codex（OpenAI のターミナル型エージェント）も触っておかないと比較できない」「同じタスクで挙動を見比べたい」という場面は出てくる。本格的に乗り換える前に、まず動かせる状態にしておきたい。

ここでは深い比較は脇に置いて、**インストールからプロンプトを投げるまで** を最短経路でなぞる。

---

## インストール

Node.js 18 以上があれば npm で入る。

```bash
npm install -g @openai/codex
```

macOS なら Homebrew でも入る。

```bash
brew install --cask codex
```

確認。

```bash
codex --version
```

---

## ログイン（2 通り）

### A. ChatGPT アカウントでログイン（個人利用ならこれ）

```bash
codex
```

初回起動時に「Sign in with ChatGPT」を選ぶとブラウザが開く。Plus / Pro / Business 以上の契約があればそのまま使える。

### B. API キーでログイン（CI や共有マシン）

OpenAI ダッシュボードで API キーを発行し、環境変数で渡す。

```bash
export OPENAI_API_KEY="sk-..."
codex
```

CI で回す・サブスクが無い・チームで共有したい、というケースは API キー一択。料金は従量課金。

---

## 最初の対話

プロジェクトのルートに `cd` してから `codex` を実行するだけで TUI（対話セッション）が立ち上がる。

```bash
cd ~/projects/my-app
codex
```

あとは普通に日本語で頼める。

```
> このリポジトリの構成を教えて
> tests/ のテストが落ちてる原因を調べて直して
> README に使い方セクションを追加して
```

Claude Code と同じ感覚で使える。違いは下の「approval mode」あたりから出てくる。

---

## approval mode（どこまで自動で動かすか）

Codex の挙動は「**ファイル編集やコマンド実行のたびに人間に確認を取るか**」で 3 段階ある。

| モード | 挙動 | 使いどころ |
|---|---|---|
| suggest | 提案のみ。編集も実行も毎回確認 | 知らないコードベース・本番リポジトリ |
| auto-edit | ファイル編集は自動、シェル実行は確認 | いつもの自分のプロジェクト |
| full-auto | 編集もコマンド実行も全自動 | サンドボックス・実験用ディレクトリ |

セッション中に `/approvals` で切り替えられる。最初は **suggest で挙動を見てから auto-edit に上げる** のが安全。

ローカル PC 上で full-auto を雑に使うとファイル消去や `rm -rf` に近い操作を勝手にやられるリスクがある。Codex は OS レベルのサンドボックス（macOS は Seatbelt、Linux は Landlock+seccomp）で実行範囲を制限しているが、過信しない。

---

## AGENTS.md（Claude Code でいう CLAUDE.md）

リポジトリのルートに `AGENTS.md` を置いておくと、Codex は毎回そのファイルを読んでから作業を始める。

```markdown
# このプロジェクトのルール

- Python 3.12 + uv 管理。`pip install` は使わない
- テストは `uv run pytest`
- コミットメッセージは Conventional Commits
- DB マイグレーションは絶対に勝手に流さない
```

Claude Code を既に使っているなら、`CLAUDE.md` の内容をそのまま `AGENTS.md` にコピーして始めれば良い（AGENTS.md は OpenAI / Google / Cursor などが共同で推進している共通フォーマット）。

`~/.codex/AGENTS.md` に置けばグローバル設定として全プロジェクトに効く。

---

## 非対話モード（スクリプト連携）

`codex exec` で対話 UI を起動せず、プロンプトを 1 回だけ投げて結果を受け取れる。GitHub Actions やシェルスクリプトに組み込むときに使う。

```bash
codex exec "CHANGELOG.md に直近 10 コミットの要約を追記して"
```

非対話なので approval は走らない。`--sandbox` フラグで実行範囲を絞る。

```bash
codex exec --sandbox read-only "このコードのバグを指摘して（編集はしないで）"
```

---

## ハマりどころ

- **API キーで使うとサブスク料金とは別課金**。Plus / Pro 契約があるのにキー認証で動かしていて、後から「請求が二重に来た」と気づくパターンがある。普段使いはサインイン認証、CI だけキー、と分けるのが無難。
- **モデルを指定し忘れる**。デフォルトは Codex 用に最適化されたモデルだが、`/model` で切り替えられる。難しいタスクは推論レベルを上げると当たりが良くなる。
- **AGENTS.md は階層的に読まれる**。サブディレクトリにも置けて、深い階層のものが優先される。プロジェクト全体のルールはルートに、サブシステム固有のルールはその配下に、と分けると管理しやすい。
- **Web 検索はデフォルト無効** のことがある。最新情報を踏まえてほしいタスクは `/search` でオンにする。

---

## まず試すなら

1. 適当な使い捨てディレクトリで `codex` を立ち上げる
2. suggest モードのまま「この README に typo がないか見て」など読み取り系で試す
3. 慣れたら auto-edit に上げて、簡単な修正タスクを投げる
4. 良さそうなら普段のリポジトリに `AGENTS.md` を置いて本採用

これだけ押さえれば「とりあえず使える」状態にはなる。Claude Code との細かな違い（並列タスク、hooks、MCP 統合の濃さなど）は触りながら追っていけば十分。

---

## 参考

- [CLI – Codex | OpenAI Developers](https://developers.openai.com/codex/cli)
- [Quickstart – Codex | OpenAI Developers](https://developers.openai.com/codex/quickstart)
- [Custom instructions with AGENTS.md – Codex | OpenAI Developers](https://developers.openai.com/codex/guides/agents-md)
- [openai/codex - GitHub](https://github.com/openai/codex)
- [@openai/codex - npm](https://www.npmjs.com/package/@openai/codex)
- [Claude Code vs Codex CLI 2026: Architecture, Pricing, and China Access](https://blakecrosley.com/blog/codex-vs-claude-code-2026)
