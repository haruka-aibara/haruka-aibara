<!-- Space: harukaaibarapublic -->
<!-- Parent: スクラム開発 -->
<!-- Title: AI エージェント時代のチケット管理 -->

# AI エージェント時代のチケット管理

「GitHub Copilot Coding Agent や Claude Code にチケットをアサインしたら、何も実装してくれなかった」「AI エージェントが動いてはいるが、全然期待通りのことをしない」——その原因は、チケットの書き方が「人間が読む前提」のままだから。

AI エージェントが実際にコードを書けるチケットと、書けないチケットの違いを整理する。

---

## 人間向けと AI エージェント向けの違い

人間の開発者は「ユーザー登録機能を追加して」という一文でも、コードベースを読み、既存の認証フローを確認し、適切な実装を判断できる。

AI エージェントは同じことを文脈なしにやろうとすると、**どこに何を書けばいいか、テストはどう実行するか、何をやってはいけないかを全部推測する**羽目になる。推測した結果が間違っていれば、やり直しが発生する。

---

## AI エージェントが実行できるチケットの構成

Addy Osmani（Google Chrome チーム）の提言をベースにした構成：

### 1. 実行コマンドを明示する（最重要）

```
テスト実行: npm test
ビルド: npm run build
型チェック: npm run typecheck
```

「テストを実行して確認してください」ではなく、**フルコマンドで書く**。AI エージェントはこのコマンドを実際に叩いて動作確認するため、オプション・フラグが揃っていないと正しく動かない。

### 2. プロジェクト構造を示す

```
src/        - アプリケーションコード
tests/      - ユニットテスト（src に対応した構造）
docs/       - ドキュメント
```

「既存の実装に合わせて」という指示は、AI が自分で読んで推測する。明示してあれば推測不要。

### 3. やることとやらないことを分ける

**このチケットでやること：**
- ユーザー登録エンドポイントの追加
- バリデーションロジックの実装
- 単体テストの追加

**このチケットでやらないこと（スコープ外）：**
- 認証（別チケット #456 で対応）
- メール送信（外部サービス連携は別作業）
- フロントエンドの変更

スコープ外を明示しないと、AI エージェントが関連しそうな実装まで手を伸ばし始める。

### 4. 受け入れ条件を具体的に書く

```
✓ POST /api/users に正常リクエストを送ると 201 を返す
✓ メールアドレスが重複している場合 409 を返す
✓ 必須フィールドが欠けている場合 400 を返す
✓ npm test が全て pass する
```

「ちゃんと動くこと」ではなく、**検証可能な条件**で書く。AI は「ちゃんと」の定義を知らない。

---

## Plan–Approve–Execute パターン

AI エージェントに直接実装させるより、段階を踏む方が結果が良い。

```
1. AI エージェントに計画案を出させる
   「このチケットを実装する場合の変更ファイルと変更内容の概要を提案してください」

2. 人間がその計画案を承認する（ここが必須のゲート）
   「step 2 のアプローチは既存の認証フローと合わない。step 3 に移る前に確認したい」

3. AI が承認されたプランに沿って実装し、PR を作成する
```

**このゲートを飛ばすと何が起きるか：** AI がスコープ外まで実装し、レビューで差し戻されるコストが発生する。または、既存の設計を壊すアプローチで実装が進む。

---

## SPEC.md に保存して使い回す

一度書いた仕様は `SPEC.md` として保存し、AI とのセッション間で参照できる状態にする。

```markdown
# SPEC.md

## コマンド
- テスト: npm test
- ビルド: npm run build

## プロジェクト構造
- src/api/ - APIエンドポイント
- src/services/ - ビジネスロジック
- tests/ - テストファイル

## 禁止事項
- 外部APIの追加（事前承認が必要）
- データベーススキーマの変更（マイグレーション手順が必要）
```

AI エージェントが「このプロジェクトで何をどうやればいいか」を毎回ゼロから探索しなくて済む。

---

## ストーリーポイントはどうするか

AI エージェントが実装するチケットのポイント見積もりは難しくなっている。「人間が 3 時間かかる作業」を AI が 10 分でやれば、ポイントの意味が変わる。

実際に Scrum.org のフォーラムでもこの問いが議論されており、明確な答えはまだ出ていない。

現実的な対応：
- **AI が実装するチケットと人間が実装するチケットを別扱いにする**
- ポイントより**サイクルタイム**（チケットがオープンしてからクローズするまでの時間）を追う
- AI が実装した場合は「AI 実装」タグを付け、完了後に実際の時間を記録して精度を評価する

---

## Jira での実装

Atlassian Intelligence はバックログアイテムから自動でスプリント計画案を生成できる。AI が提案したチケットの優先順位を起点にして、人間が最終判断する形が現実的。

ただし AI が自動生成したチケットの記述は「どう動くか」の説明になりがち。上述の「やらないこと」「受け入れ条件」は人間が追記する必要がある。

---

## 参考

- [Addy Osmani: "How to write a good spec for AI agents"](https://addyosmani.com/blog/good-spec/)
- [O'Reilly Radar: "How to Write a Good Spec for AI Agents"](https://www.oreilly.com/radar/how-to-write-a-good-spec-for-ai-agents/)
- [Medium: "Tickets Are All You Need (to make AI agents actually ship)"](https://medium.com/@putrajonathan/the-plan-approve-execute-pattern-for-asynchronous-ai-development-2c1db9fa08b1)
- [Aize: "How to Write agents.md for Best AI Agent Results"](https://aize.dev/1110/how-to-write-an-agents-md-to-get-the-best-ai-agent-results/)
- [Scrum.org Forum: "How to approach story point estimation with advent of AI Dev acceleration tools?"](https://www.scrum.org/forum/scrum-forum/94752/how-approach-story-point-estimation-advent-ai-dev-acceleration-tools)
