# GitHub Actions に AI レビューを組み込む

## 問題

PR を開くたびに手動で AI にレビューを頼むのが面倒。PR 作成と同時に自動でレビューコメントがついてほしい。

---

## 基本構成

PR が開かれたら GitHub Actions が起動し、diff を取得して Claude API に投げ、結果を PR コメントとして書き込む。

```yaml
# .github/workflows/ai-review.yml
name: AI Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
      contents: read

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Get PR diff
        id: diff
        run: |
          git diff origin/${{ github.base_ref }}...HEAD > pr_diff.txt
          echo "diff_size=$(wc -c < pr_diff.txt)" >> $GITHUB_OUTPUT

      - name: AI Review
        if: steps.diff.outputs.diff_size != '0'
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          DIFF=$(cat pr_diff.txt)
          RESPONSE=$(curl -s https://api.anthropic.com/v1/messages \
            -H "x-api-key: $ANTHROPIC_API_KEY" \
            -H "anthropic-version: 2023-06-01" \
            -H "content-type: application/json" \
            -d "$(jq -n \
              --arg diff "$DIFF" \
              '{
                model: "claude-sonnet-4-6",
                max_tokens: 2048,
                messages: [{
                  role: "user",
                  content: ("以下のPR diffをコードレビューしてください。問題点・改善点を日本語で簡潔に指摘してください。\n\n" + $diff)
                }]
              }'
            )")
          COMMENT=$(echo "$RESPONSE" | jq -r '.content[0].text')
          gh pr comment ${{ github.event.pull_request.number }} \
            --body "## AI レビュー\n\n${COMMENT}"
```

---

## Secrets の設定

- `ANTHROPIC_API_KEY`: リポジトリの Settings → Secrets and variables → Actions に登録
- `GITHUB_TOKEN`: Actions が自動で提供するので設定不要

---

## diff が大きすぎる問題への対処

大きな PR は diff がトークン制限を超える。行数でフィルタリングして上限を設ける。

```yaml
      - name: Check diff size
        id: check
        run: |
          LINES=$(git diff origin/${{ github.base_ref }}...HEAD | wc -l)
          echo "lines=$LINES" >> $GITHUB_OUTPUT

      - name: AI Review
        if: steps.check.outputs.lines < 500
        # ... 以下同様
```

500行を超える PR はスキップしてその旨をコメントするか、ファイル単位で分割して投げる。

---

## レビュー観点をプロンプトで絞る

全方位のレビューより、観点を絞るほうが使えるコメントが返ってくる。

```
セキュリティの観点のみでレビューしてください。
SQL インジェクション・XSS・認証漏れ・シークレットのハードコードに絞って指摘してください。
問題がなければ「問題なし」とだけ答えてください。
```

```
以下の観点でレビューしてください：
- エラーハンドリングの抜け
- 命名の一貫性
- 重複コード
設計・アーキテクチャの話は不要です。
```

---

## 既存ツールを使う選択肢

自前で実装せずに既存の GitHub Actions を使う方法もある。

- **`github/copilot-extensions`**: GitHub 公式
- **`anc95/ChatGPT-CodeReview`**: OpenAI ベース
- **`MerlinKodo/clash-rev`**: Claude ベース

カスタマイズ性は自前実装のほうが高い。とりあえず動かすなら既存ツールが早い。

---

## 運用上の注意

- AI のコメントは参考意見。マージブロックの条件にはしない
- bot のコメントが多すぎると PR が見づらくなる。1コメントにまとめる
- API コストが積み上がるので、draft PR はスキップするなど制限を入れる

```yaml
on:
  pull_request:
    types: [opened, synchronize, ready_for_review]

jobs:
  review:
    if: github.event.pull_request.draft == false
```
