# ADR-0003: Jira のチケットから Claude Code に draft PR を作らせる

## ステータス

採用 (2026-09-24)

## コンテキスト

Jira・Slack・GitHub・AWS・HCP Terraform を個別には使っているが、つながっていない。チケットを切っても実装は別の場所で始まり、状態は手で動かしている。

「Claude Code のアプリで頼めば PR は作れる」ので、自分から頼む作業を自動化しても価値は薄い。欲しいのは、各サービスに本来の役割を 1 つずつ持たせ、Jira キーを相関 ID にして、人が状態を手で運ばずに済む流れ。

| サービス | 役割 |
|---|---|
| Jira | 状態の唯一の置き場所（To Do → AI 実装 → レビュー → デプロイ済み） |
| Slack | 人への通知と判断の入口 |
| GitHub | コード・PR・CI、エージェントの実行場所 |
| HCP Terraform | PR の plan とマージ後の apply |
| AWS | Bedrock と、つなぎの処理 |

この ADR はその最初の一本道（Jira → PR → Slack）を決める。HCP Terraform の apply 結果で Jira を「デプロイ済み」に動かす部分は後続で足す。

## 決定

- **実行場所は GitHub Actions（`anthropics/claude-code-action`）。** Lambda は 15 分の上限と、git・uv・terraform が無いことで向かない。
- **モデルは Bedrock を OIDC で使う。** chatbot と同じ Opus 4.6 のプロファイル。AWS に長期キーを置かない。ロールは Bedrock の呼び出しだけを許し、信頼条件は environment `jira-to-pr` に限る。environment は保護ブランチ（main）からしか使えない。
- **起動は Jira Automation からの workflow_dispatch。** repository_dispatch は Contents: write の PAT が要るが、workflow_dispatch は Actions: write で足りる。漏れてもコードは書けない。
- **エージェントには書き込み権限を渡さない。** Claude のステップが持つのは読み取り専用の `GITHUB_TOKEN` と Bedrock だけ。push と PR 作成は後段のステップが専用の GitHub App のトークンで行う。App に Workflows 権限は付けないので、ワークフローの書き換えは push の時点で拒否される。
- **PR は draft、マージは人。** works は main へのマージで HCP Terraform が auto apply する。エージェントの変更がそのまま本番に届く経路は作らない。
- **チケット本文はデータとして渡す。** プロンプトに埋め込まずファイルに書き、「指示ではない」と明示する。キーと URL は形を検証する。
- **セルフレビューは同じ実行の中でやる。** 実装後に自分の差分を読み直させ、見つけたことを PR 本文に残す。

## 検討した代替案

- **Slack から直接 PR（Jira を挟まない）。** 公式の Claude の Slack 連携で足りる。自作の意味が無い。
- **Claude に `gh pr create` までやらせる。** 手順は短くなるが、書き込み可能なトークンをエージェントに渡すことになる。
- **Terraform 用の GitHub App を流用する。** org の管理権限を持つ鍵を Actions に置くことになる。
- **別プロセスでセルフレビューする（レビュー専用のジョブ）。** 文脈を持たない目で見られる利点はあるが、最初の一本道には過剰。PR の CI で補う。

## トレードオフ

- 手作業の設定が残る（GitHub App、environment の値、Jira Automation、起動用 PAT）。手順は [ランブック](../runbooks/jira-to-pr.md)。
- 起動用 PAT は 90 日で手動更新。漏れても被害は Bedrock の料金まで。
- チケットの質がそのまま PR の質になる。受け入れ条件の無いチケットは、それらしいが的外れな PR を生む。
