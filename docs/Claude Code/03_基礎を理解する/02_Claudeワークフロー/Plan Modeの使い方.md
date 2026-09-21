# Plan Mode の使い方

## こういうときに困る

「Claude にコードを直してもらったら、直してほしくない場所まで変えられた」「指示が曖昧だったせいで、大量の変更を全部 revert するはめになった」という経験がある人は多い。

大きな変更を依頼するとき、Claude がいきなりファイルを書き換えに行くのが怖い。特に把握しきれていない箇所が多いコードベースでは、何を変えるか確認してから実行させたい。

それを解決するのが **Plan Mode**。

---

## Plan Mode とは

Claude Code が **ファイルの読み取りと分析しかできない** 状態にモードを切り替える機能。この状態では、ファイルを書き換えたりコマンドを実行したりできない。

「まず調べて計画だけ立ててもらい、内容を確認してから実行させる」という二段構えができる。

---

## 使い方

### Plan Mode に入る

インタラクティブセッション内でモードをサイクルする：

```
Shift + Tab   → default → acceptEdits → plan の順で切り替わる
```

または起動時にフラグを渡す：

```bash
claude --permission-mode plan
```

プロンプト欄に `[plan]` と表示されていれば Plan Mode。

### Plan Mode から出る

`Shift + Tab` でサイクルして通常モード（`default`）に戻る。

### 典型的な流れ

```
# 1. Plan Mode で調査・計画
[plan] > 認証周りのコードをリファクタリングしたい。どういう変更が必要か調べて計画を立てて

# Claude が読み取り専用でコードを調査し、変更計画を提示する
# 計画は ~/.claude/plans/ に Markdown ファイルとして自動保存される

# 2. 内容を確認して通常モードに切り替えて実行を依頼する
# Ctrl+G でエディタを開いて計画を直接編集することもできる
```

---

## 実際に使える場面

**大規模リファクタリングの前**
変更対象のファイルと内容を事前に確認できる。予想外の場所を触ろうとしていたら、実行前に止められる。

**知らないコードベースを調査するとき**
「このリポジトリのアーキテクチャを教えて」という使い方でも Plan Mode が役立つ。読み取り専用なので、操作ミスのリスクなしに自由に調査できる。

**複数ファイルにまたがる変更**
何を変えるか一覧を出してもらってから承認する、という確認フローにできる。

---

## Plan Mode でできること・できないこと

| 操作 | Plan Mode | 通常モード |
|------|-----------|-----------|
| ファイルの読み取り | ✅ | ✅ |
| コードの分析・説明 | ✅ | ✅ |
| ファイルの書き換え | ❌ | ✅ |
| コマンドの実行 | ❌ | ✅ |

---

## デフォルトを Plan Mode にする

チームで「まず計画、承認してから実行」を徹底したい場合、`.claude/settings.json` で設定できる：

```json
{
  "permissions": {
    "defaultMode": "plan"
  }
}
```

---

## 参考

- [Use Plan Mode for safe code analysis - Claude Code Docs](https://code.claude.com/docs/en/common-workflows#use-plan-mode-for-safe-code-analysis)
- [Best practices: Explore first, then plan, then code - Claude Code Docs](https://code.claude.com/docs/en/best-practices#explore-first-then-plan-then-code)
- [Permission modes - Claude Code Docs](https://code.claude.com/docs/en/permissions#permission-modes)
