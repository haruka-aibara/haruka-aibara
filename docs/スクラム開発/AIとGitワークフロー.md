<!-- Space: harukaaibarapublic -->
<!-- Parent: スクラム開発 -->
<!-- Title: AI と Git ワークフロー -->

# AI と Git ワークフロー

「AI ツールを導入してから PR が増えすぎてレビューが回らなくなった」「AI が書いた PR の説明が何を言っているかわからない」——AI がコードを書くようになったことで、チームの Git ワークフローには新しい問題が起きている。

---

## 何が変わったか：PR の量と質

DX の Q4 2024 レポート（266 社対象）によると：

- AI の日常ユーザーは週平均 **2.3 件の PR をマージ**（月 1 回ユーザーは 1.5 件）
- AI 高利用者の PR サイクルタイムは **16% 短縮**
- 2024 年時点でコードベースの **22% が AI 生成**

数字だけ見れば生産性が上がっている。問題は次のデータだ：

- AI を使う開発者は PR を **98% 多く作成する**
- PR のレビュー時間は **91% 増加する**
- フィーチャーブランチのスループット +15% だが、**メインブランチのスループット −7%**

コードを書く速さは上がったが、本番に届く速さが下がった。ボトルネックが「実装」から「レビュー・統合」に移っている。

---

## GitHub Copilot Coding Agent が変えること

GitHub Copilot Coding Agent が 2025 年に GA（一般提供）になった。動き方を理解しておく必要がある。

```
1. GitHub Issue を Copilot にアサインする
2. Copilot が即座に draft PR を作成して空コミットを打つ
3. 仮想マシンを起動・リポジトリをクローン
4. コードを書きながら定期的に draft PR にコミットをプッシュし、PR 説明を更新
5. 完成後、開発者のレビューと承認を要求
6. 本人（アサインした人）はそのPRを承認できない
7. 承認後 CI/CD ワークフローが実行される
```

最後の 2 点が重要だ。**PR の作成者と承認者が必ず別になる**——これが新しいガバナンスの最低ラインになる。AI が書いたコードが AI 自身によって承認されることは、GitHub の設計上できない。

---

## AI が書く PR 説明の問題

AI が自動生成する PR 説明は「何をしているか」は書かれていても「なぜその設計判断にしたか」が書かれていない。

OCaml のオープンソースメンテナーが実際に直面した問題：大規模な AI 生成 PR が投稿されたが「AI が生成したコードのレビューは人間が書いたコードよりも認知的にきつい」として却下された。コードの量に対してコンテキストが薄いため、レビュアーが意図を理解するためのコストが高くなる。

**PR 説明に含まれるべきこと（AI が書いた場合も人間が追記する）：**
- なぜこのアプローチを選んだか（他の選択肢との比較）
- 影響範囲（どのファイル・モジュールが変わるか）
- テスト方法（どのシナリオで動作確認したか）
- 注意点（レビュアーが特に見てほしい箇所）

---

## ブランチ戦略：AI 時代に合うのはどれか

AI がコードを生成する場合、長期ブランチを維持するコストが上がる。AI が大量のコードをまとめて書くと、長期間放置されたブランチとのマージコンフリクトが複雑になる。

**推奨：トランクベース開発 + 短命ブランチ**

```
main
├── feature/add-login (1〜2 日で作成・マージ)
├── feature/fix-auth  (同日中に作成・マージ)
└── feature/add-api   (長くても 3 日以内)
```

AI が生成する単位は「1 つの機能の実装」であることが多い。それに合わせてブランチも短命にする。短命なほど：
- マージコンフリクトが小さい
- レビューのスコープが限定される
- 問題が起きたときの影響範囲が小さい

ただし短命ブランチが安全に機能するには、**CI/CD のテスト自動化**が前提になる。テストなしに頻繁にマージすると、本番に問題が届く頻度が上がる。

---

## Slopsquatting：依存関係の検証を CI に組み込む

AI が生成したコードに存在しないパッケージ名が含まれている可能性がある（[Slopsquatting](コードレビューはまだ必要か.md)）。

PR をマージする前のチェックとして CI に追加する：

```yaml
# GitHub Actions の例
- name: 依存関係の脆弱性チェック
  run: npm audit --audit-level=high

- name: 依存関係の存在確認
  run: npm install --dry-run
```

Python の場合：
```yaml
- name: pip audit
  run: pip-audit --requirement requirements.txt
```

これを PR ブロッカーとして設定することで、AI が幻覚したパッケージが本番に紛れ込むリスクを CI の段階で止められる。

---

## コミットメッセージの品質をどう保つか

AI がコードを書くと、コミットメッセージも AI に任せることが増える。「fix bug」「update code」のような無意味なコミットメッセージが増える場合がある。

対策：コミットメッセージの規則を CI で検証する。

```bash
# commitlint を使う例
# feat: Add login endpoint
# fix: Resolve null pointer on logout
# chore: Update dependencies
```

Conventional Commits 規約 + commitlint で形式を強制できる。AI もこの規約に従って書くように指示できる（`SPEC.md` や `.github/copilot-instructions.md` に記載）。

---

## 参考

- [DX: "AI-assisted engineering: Q4 impact report"](https://getdx.com/blog/ai-assisted-engineering-q4-impact-report-2025/)
- [GitHub Blog: "GitHub Copilot: Meet the new coding agent"](https://github.blog/news-insights/product-news/github-copilot-meet-the-new-coding-agent/)
- [GitHub Docs: "About GitHub Copilot coding agent"](https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-coding-agent)
- [AWS Blog: "Your AI Coding Assistants Will Overwhelm Your Delivery Pipeline: Here's How to Prepare"](https://aws.amazon.com/blogs/enterprise-strategy/your-ai-coding-assistants-will-overwhelm-your-delivery-pipeline-heres-how-to-prepare/)
- [Dev Class: "OCaml maintainers reject massive AI-generated pull request"](https://devclass.com/2025/11/27/ocaml-maintainers-reject-massive-ai-generated-pull-request/)
- [Logilica: "The Shifting Bottleneck Conundrum: How AI Is Reshaping the Software Development Lifecycle"](https://www.logilica.com/blog/the-shifting-bottleneck-conundrum-how-ai-is-reshaping-the-software-development-lifecycle)
