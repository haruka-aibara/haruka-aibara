# 壁打ち AI × 実装 AI 開発フローの導入チェックリスト

[壁打ちAIと実装AIを分けてセキュリティ機能を開発する](./壁打ちAIと実装AIを分けてセキュリティ機能を開発する.md) を「で、明日何をすればいいのか」に落としたもの。上から順にやれば 1 本目の機能が回るところまで行ける。

前提：単一 AWS アカウント、IaC は Terraform、リポジトリは GitHub。AI は AWS に接続しない（plan の read だけ CI のロールが行う）。

---

## Step 0：始める前に決めること

- [ ] 対象リポジトリを 1 つ決める（Terraform 管理のセキュリティ系リポジトリ）
- [ ] 最初のお題を決める。**低〜中リスクの検知系 1 本**にする（例：特定 API コールを検知する EventBridge ルール＋通知）。IAM 書き込みや自動修復（enforce）を 1 本目にしない
- [ ] AI に触らせないパスを決める（例：`backend` 設定、CI 定義、既存の本番 IAM）

## Step 1：リポジトリの下ごしらえ

- [ ] `CLAUDE.md` を書く。最低限：ディレクトリ構成、`terraform fmt/validate` などの検証コマンド、触ってはいけないパス、PR の書き方
- [ ] `AGENTS.md` は実体を分けず symlink にする：`ln -s CLAUDE.md AGENTS.md`（Codex は AGENTS.md を読む）
- [ ] `docs/specs/` を作り、仕様書テンプレを置く：

```markdown
# 仕様書：<機能名>

## 目的とトリガー
- 対象の脅威：
- 発火すべき場面：

## 受け入れ基準（apply 後に人間が実行する確認手順）
1. <そのまま実行できるコマンド・操作で書く>
2. 期待する結果：

## IAM 権限の上限
- この実装が作ってよいアクションの一覧。plan にこれ以外が出たら差し戻し

## 触ってよい範囲
- ディレクトリ / リソース：

## ロールバック
- terraform destroy で戻るか。戻らない副作用があれば明記

## やらないこと
-
```

## Step 2：GitHub 側の設定（人間がマージ権を握る）

- [ ] main のブランチ保護：direct push 禁止、PR 必須、approve 1 名以上、ステータスチェック必須
- [ ] `CODEOWNERS` で `docs/specs/` と IAM 系パスのレビューを自分（チーム）に固定
- [ ] auto-merge を無効にしておく（Codex は自分の GitHub 権限で PR を作るため、「AI が PR を作って自動マージまで通る」経路を残さない）

## Step 3：CI ゲート（PR 上の決定論チェック）

- [ ] plan 用の read-only ロールを作る。ポイントは trust policy を **PR イベント限定**にすること：

```json
{
  "Effect": "Allow",
  "Principal": { "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com" },
  "Action": "sts:AssumeRoleWithWebIdentity",
  "Condition": {
    "StringEquals": { "token.actions.githubusercontent.com:aud": "sts.amazonaws.com" },
    "StringLike": { "token.actions.githubusercontent.com:sub": "repo:<org>/<repo>:pull_request" }
  }
}
```

権限は `ReadOnlyAccess` をベースに、扱わないサービスを Deny で削る。

- [ ] ワークフローを置く。最小構成：

```yaml
name: pr-gates
on: pull_request
permissions:
  id-token: write
  contents: read
jobs:
  gates:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: gitleaks/gitleaks-action@v2          # シークレット混入
      - uses: aquasecurity/trivy-action@master     # IaC ミスコンフィグ
        with:
          scan-type: config
          severity: HIGH,CRITICAL
          exit-code: "1"
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::<ACCOUNT_ID>:role/ci-plan-readonly
          aws-region: ap-northeast-1
      - uses: hashicorp/setup-terraform@v3
      - run: terraform fmt -check && terraform init && terraform validate
      - run: terraform plan -no-color              # 結果を PR で人間が読む
```

- [ ] OPA / cfn-guard による「権限上限のコード化」は**最初はやらない**。1〜2 本回して仕様書の「IAM 権限の上限」の書き方が安定してからコード化する

## Step 4：壁打ち（Phase 1）

- [ ] Claude に最初のお題を投げる。プロンプトの型：

> `docs/specs/` のテンプレに沿って <お題> の仕様書を作りたい。まず前提・脅威モデル・設計の選択肢について壁打ちに付き合って。**ゴールはチャットの結論ではなく仕様書の PR を出すこと。** 受け入れ基準は「apply 後に人間が実行できる確認手順」の形で書くこと。

- [ ] 出てきた仕様書 PR を人間がレビュー。見るのは 3 点だけ：
  - 受け入れ基準が「実行できる確認手順」になっているか（「〜であること」で終わっていないか）
  - IAM 権限の上限が具体的なアクション名で列挙されているか
  - 「やらないこと」が空欄でないか
- [ ] 仕様書 PR をマージ（＝仕様承認。**ここが人間の一番大事な仕事**。流し読みしない）

## Step 5：実装（Phase 2）

- [ ] Codex（cloud）の環境設定を確認：**AWS 認証情報・シークレットを一切置かない**。setup script は依存インストール程度に留める
- [ ] タスクとして渡すのは仕様書のパスだけ。壁打ちのチャットログは渡さない：

> `docs/specs/<仕様書>.md` を実装して PR を出して。仕様書の「IAM 権限の上限」「触ってよい範囲」「やらないこと」を厳守。PR 本文に、受け入れ基準の確認手順をそのまま転記すること。

- [ ] 出てきた PR で CI ゲートが全部緑になるまでは人間は見ない（lint レベルの指摘を人間がやり始めたら負け）

## Step 6：クロスレビュー（Phase 3）

- [ ] Claude に実装 PR をレビューさせる。プロンプトの型：

> PR #<番号> を `docs/specs/<仕様書>.md` と突合してレビューして。観点は 3 つ：(1) 仕様にない IAM 権限・リソースが増えていないか (2) 受け入れ基準と PR の確認手順が対応しているか (3) テストが「仕様を検証している」か「実装をなぞっているだけ」か。

- [ ] 指摘は Codex に修正させる。**往復は 2 回まで**。それで割れたら人間が裁定し、裁定結果は仕様書に反映してからやり直す

## Step 7：人間の仕上げ（Phase 4）

- [ ] plan 差分を読んで approve → マージ
- [ ] 人間（または CD）が apply
- [ ] **apply 直後に仕様書の確認手順を実行**し、発火した証拠（検出結果・通知のスクリーンショット等）を PR にコメントで残す
- [ ] 検知系は learn mode（通知のみ）で投入。enforce への昇格は別 PR として同じフローに乗せる

---

## 1〜2 本回してから足すもの

最初から全部作ると回り始める前に力尽きる。以下は後回しでよい。

- [ ] OPA / cfn-guard で仕様書の権限上限をポリシー・アズ・コード化（Step 3 の宿題）
- [ ] `CLAUDE.md` と `AGENTS.md` の食い違い検知（symlink 運用なら不要）
- [ ] リスク分類（低リスク変更は単一エージェント直行）の運用ルール化
- [ ] 仕様書テンプレの改訂（確認手順の書き方で詰まった箇所を反映）

## 参考

- [GitHub Docs: OpenID Connect を使用した AWS での認証構成](https://docs.github.com/ja/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials)
- [gitleaks/gitleaks-action](https://github.com/gitleaks/gitleaks-action)
- [aquasecurity/trivy-action](https://github.com/aquasecurity/trivy-action)
- [GitHub Docs: 保護されたブランチについて](https://docs.github.com/ja/repositories/configuring-branches-and-merges-in-your-repository/about-protected-branches)
- [GitHub Docs: CODEOWNERS ファイルについて](https://docs.github.com/ja/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
- [OpenAI Codex: Cloud environments](https://developers.openai.com/codex/cloud/environments)
- [AGENTS.md](https://agents.md/)
