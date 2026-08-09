# エディタ拡張（VS Code / JetBrains）

## こういうときに便利

ターミナルで `claude` を起動して使うのも悪くないが、「エディタを開きながら隣に Claude を置いて使いたい」「差分を見ながらレビューしたい」「今開いているファイルをわざわざ指定せずに使いたい」という場面では、IDE 拡張の方が快適。

---

## できること

エディタ拡張を使うと、Claude Code がエディタに統合される。

- **サイドバーで会話**：エディタを閉じずに Claude と対話できる
- **インライン差分**：提案された変更をコードと並べて確認・承認できる
- **ファイル認識**：今開いているファイル・選択中のコードを自動で文脈に含める（手動で `@` 指定しなくていい）
- **ターミナルエラーの認識**：エディタのターミナルに出たエラーを Claude が自動で拾える

---

## VS Code

### インストール

VS Code の拡張機能マーケットプレイスで「Claude Code」を検索してインストール。

または Claude Code の設定から：

```
/ide
```

### 使い方

- サイドバーの Claude アイコンをクリックしてパネルを開く
- コードを選択した状態で右クリック → 「Claude で説明」「Claude に質問」なども使える
- ターミナルでエラーが出ると自動的に Claude に通知される

---

## JetBrains（IntelliJ IDEA / PyCharm / WebStorm 等）

### インストール

JetBrains Marketplace で「Claude Code」を検索してインストール。

または：Preferences → Plugins → Marketplace で検索。

### 使い方

VS Code と同様にサイドバーパネルで操作。JetBrains の「Claude Agent」として統合されており、プロジェクト構造・現在のファイル・選択コードを認識した状態で動く。

---

## ターミナルとの違い

| 機能 | ターミナル | IDE 拡張 |
|------|-----------|---------|
| 会話 | ✅ | ✅ |
| ファイル変更の差分確認 | テキストのみ | 視覚的な diff ビューア |
| 開いているファイルの自動認識 | ❌（手動で `@` 指定） | ✅ |
| ターミナルエラーの自動取り込み | ❌ | ✅ |
| スクリプト・パイプラインへの組み込み | ✅ | ❌ |

どちらが優れているわけでなく、**確認しながら進める作業は IDE 拡張、自動化・CI は CLI** という使い分けが自然。

---

## 参考

- [Use Claude Code in VS Code - Claude Code Docs](https://code.claude.com/docs/en/vs-code)
- [JetBrains IDEs - Claude Code Docs](https://code.claude.com/docs/en/jetbrains)
