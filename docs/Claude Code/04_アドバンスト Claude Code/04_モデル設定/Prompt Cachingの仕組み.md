# Prompt Caching の仕組み

## こういうときに気になる

「同じプロジェクトで毎回 Claude を使っているのに、毎回コストが同じくらいかかる気がする」「CLAUDE.md や大量のファイルを読み込むたびに遅いし高い」。

Claude Code は大きなコンテキスト（CLAUDE.md・コードベース・長い会話履歴）を毎回モデルに送信する。これがコストと遅延の主な原因になる。

---

## Prompt Caching とは

一度送ったプロンプトの「変わらない部分」をサーバー側にキャッシュする仕組み。次のリクエストでその部分を再送しなくて済むので、**最大 90% のコスト削減・最大 85% の高速化**が期待できる。

**Claude Code はこれをデフォルトで自動的に行っている。** 設定不要で恩恵を受けられる。

---

## キャッシュが効きやすい場面

- CLAUDE.md が長い
- 同じセッションで同じファイルを繰り返し参照している
- 長い会話を続けている

逆に、毎回内容が変わる部分（ユーザーの入力・ファイルの変更後の内容）はキャッシュされない。

---

## キャッシュを無効にしたいとき

通常は無効にする理由はないが、デバッグ目的や特殊な環境（一部クラウドプロバイダーなど）では無効化できる。

```bash
# 全モデルのキャッシュを無効化
export DISABLE_PROMPT_CACHING=1

# モデルごとに無効化
export DISABLE_PROMPT_CACHING_HAIKU=1
export DISABLE_PROMPT_CACHING_SONNET=1
export DISABLE_PROMPT_CACHING_OPUS=1
```

`DISABLE_PROMPT_CACHING=1` は個別設定より優先される。

---

## コスト削減と合わせて意識すること

Prompt Caching は自動で効くが、**キャッシュが活きるのはプロンプトの先頭から変わらない部分**が連続しているとき。

つまり：
- CLAUDE.md は短く・安定させておく方がキャッシュ効率が上がる
- 不要なファイルを大量に `@` 指定しない
- 頻繁に `/clear` すると毎回キャッシュが使えない状態から始まる（コンテキスト管理と要トレードオフ）

---

## 参考

- [Prompt caching configuration - Claude Code Docs](https://code.claude.com/docs/en/model-config#prompt-caching-configuration)
- [Prompt caching - Anthropic Docs](https://docs.anthropic.com/en/build-with-claude/prompt-caching)
