# Headless Mode と自動化

## こういうときに使いたい

「毎週月曜に依存ライブラリの更新 PR を自動で出したい」「CI でコードを変更したときに、自動でドキュメントも更新させたい」「定型的な作業を Claude に任せて、自分はレビューだけしたい」。

インタラクティブに会話しながら使うだけでなく、スクリプトや CI/CD のパイプラインに Claude Code を組み込みたい場面がある。

それを解決するのが `-p` フラグ（Headless Mode）。

---

## `-p` フラグとは

`--print` の略。プロンプトをコマンドライン引数として渡し、結果を標準出力に返す Unix ツールとして使える。

```bash
claude -p "このコードをレビューしてバグを教えて" < main.py
```

---

## 基本的な使い方

### シンプルな実行

```bash
claude -p "プロンプト"
```

### ファイルを渡す

```bash
# 標準入力経由
claude -p "このコードのテストを書いて" < src/utils.py

# ファイルパスを指定
claude -p "@src/utils.py のテストを書いて"
```

### 出力をファイルに保存

```bash
claude -p "CHANGELOG の下書きを作って" > CHANGELOG_draft.md
```

### JSON で出力する（他ツールとの連携）

```bash
# セッション ID やメタデータも含めた JSON
claude -p "概要を教えて" --output-format json | jq -r '.result'
```

---

## CI/CD で使うときの重要フラグ：`--bare`

CI では必ず `--bare` を付ける。

`--bare` を付けると、hooks・skills・plugins・MCP・auto memory・CLAUDE.md の自動読み込みをすべてスキップし、**毎回同じ結果が得られる**環境になる。

```bash
# 推奨：CI では --bare を必ず付ける
claude --bare -p "このファイルを要約して" --allowedTools "Read"
```

`--bare` なしだと、ローカルの設定ファイルや hooks に影響されて挙動が変わる可能性がある。

---

## CI/CD への組み込み例

### GitHub Actions でコードレビューを自動化

```yaml
name: AI Code Review
on:
  pull_request:

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Claude Code
        run: npm install -g @anthropic-ai/claude-code
      - name: Run AI Review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          gh pr diff "${{ github.event.pull_request.number }}" | \
            claude --bare -p \
              "セキュリティエンジニアとして脆弱性をレビューしてください。問題点を日本語で指摘してください" \
              --allowedTools "Read,Bash" \
              --output-format json | jq -r '.result' > review.md
      - name: Post Review as Comment
        # review.md の内容を PR コメントに投稿する処理
```

### 会話を継続する

```bash
# 前のセッションを継続（最新セッションを再開）
claude -p "次は DB クエリに集中して" --continue

# セッション ID を指定して再開
session_id=$(claude -p "レビュー開始" --output-format json | jq -r '.session_id')
claude -p "続きをお願い" --resume "$session_id"
```

---

## 主なオプション

| オプション | 説明 |
|------------|------|
| `-p "プロンプト"` | Headless Mode で実行するプロンプト |
| `--bare` | hooks・MCP・CLAUDE.md 等をスキップ（CI 推奨） |
| `--model` | 使用するモデルを指定（省略時は Sonnet） |
| `--allowedTools` | 使用を許可するツールを制限（例：`Read,Write`） |
| `--output-format json` | JSON 形式で出力（セッション ID 付き） |
| `--output-format stream-json` | リアルタイムのストリーミング出力 |
| `--continue` | 直前のセッションを継続 |
| `--resume <session_id>` | 指定したセッションを再開 |
| `--permission-mode plan` | 読み取り専用の Plan Mode で実行 |
| `--dangerously-skip-permissions` | すべての権限確認をスキップ（コンテナ内専用） |

---

## 注意点

**API キーが必要**
`-p` では OAuth ログインは使えない。`ANTHROPIC_API_KEY` 環境変数にキーをセットしておく必要がある。

**コスト管理**
自動化すると実行頻度が上がりやすい。`--model claude-haiku-4-5` など軽量モデルを使うか、実行頻度を制限する設計にする。

**権限のスコープを絞る**
`--allowedTools` でツールを制限しておくと、意図しないファイル操作を防げる。`--dangerously-skip-permissions` はコンテナや VM の中だけで使う。

---

## 参考

- [Run Claude Code programmatically - Claude Code Docs](https://code.claude.com/docs/en/headless)
- [CLI reference - Claude Code Docs](https://code.claude.com/docs/en/cli-reference)
