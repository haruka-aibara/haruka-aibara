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
- **モデルは Bedrock を OIDC で使う。** Opus 5.5 の global 推論プロファイル（`global.anthropic.claude-opus-5-5`）。AWS に長期キーを置かない。ロールは Bedrock の呼び出しだけを許し、信頼条件は environment `jira-to-pr` に限る。environment は保護ブランチ（main）からしか使えない。
- **起動は Jira Automation からの workflow_dispatch。** repository_dispatch は Contents: write の PAT が要るが、workflow_dispatch は Actions: write で足りる。漏れてもコードは書けない。
- **入口は未開始の「AI 実装」スプリント。** 課題をそのスプリントに入れたら起動する。ステータスはワークフローの変更で、大きな組織では管理者への申請が要る。スプリントはプロジェクトの中で作れて、利用者の権限で完結する。開始しないので、バーンダウンやベロシティにも混ざらない。
- **エージェントには書き込み権限を渡さず、ジョブごと隔離する。** 実装ジョブが持つのは読み取り専用の `GITHUB_TOKEN` と Bedrock だけで、成果物はパッチ 1 枚。push と PR 作成は別ジョブが、まっさらなチェックアウトにパッチを当てて専用の GitHub App のトークンで行う。同じ作業ディレクトリで push すると、エージェントが仕込んだ `.git/hooks` や `.git/config` がトークンを持った状態で実行されうるため。App に Workflows 権限は付けず、`.github/` を触る差分はその前に止める。
- **PR は draft、マージは人。** works は main へのマージで HCP Terraform が auto apply する。エージェントの変更がそのまま本番に届く経路は作らない。
- **チケット本文はデータとして渡す。** プロンプトに埋め込まずファイルに書き、「指示ではない」と明示する。キーと URL は形を検証する。
- **レビューは別の Claude にやらせる。** 実装と同じ文脈で読み直すと同じ思い込みで見落とす。まっさらな環境で、読み取り専用のツールだけを持つ Claude が差分とチケットを読み、判定と指摘を PR 本文に残す。
- **Slack には CI が終わってから知らせる。** PR を作った時点ではまだ完成していない。CI の結果とレビューの判定を 1 通にまとめる。

## 検討した代替案

- **Slack から直接 PR（Jira を挟まない）。** 公式の Claude の Slack 連携で足りる。自作の意味が無い。
- **Claude に `gh pr create` までやらせる。** 手順は短くなるが、書き込み可能なトークンをエージェントに渡すことになる。
- **入口をステータス（「AI 実装」への遷移）やラベルにする。** ステータスはワークフローの変更で、組織によっては管理者の申請が要る。ラベルは自由入力のことが多いが、絞っている組織もある。
- **Terraform 用の GitHub App を流用する。** org の管理権限を持つ鍵を Actions に置くことになる。
- **実装と同じ実行の中でセルフレビューする。** 安いが、実装時の思い込みをそのまま引き継ぐ。
- **レビューで指摘が出たら自動で直させる。** ループの上限や収束の判断が要る。まずは指摘を人に見せ、直すかどうかは人が決める。

## トレードオフ

- 手作業の設定が残る（GitHub App、environment の値、Jira Automation、起動用 PAT）。手順は [ランブック](../runbooks/jira-to-pr.md)。
- 起動用 PAT は 90 日で手動更新。漏れても被害は Bedrock の料金まで。
- チケットの質がそのまま PR の質になる。受け入れ条件の無いチケットは、それらしいが的外れな PR を生む。
