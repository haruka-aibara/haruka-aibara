# Claude に HCP Terraform のトークンを持たせる

**この文書を読むとき:** Claude Code（クラウドセッション）用のトークンを発行・更新するとき。漏れた疑いがあるとき。Claude が `terraform plan` できないと言ってきたとき。

**3行:**

- Claude はクラウドセッションから `terraform plan` を叩き、HCP 上の speculative plan を見て PR 前に自分で確認する。VCS 連携で走った plan も API で読む
- トークンは **owners team の期限付きトークンを手で発行して、Claude 環境の環境変数に手で入れる**。Free では team を作れないので、権限は owners のまま（[TFE_TOKEN 自動ローテーション](tfe-token-rotation.md) §7 と同じ事情）
- apply 以降を止めているのは `.claude/hooks/guard-terraform.sh` の柵だけ。**操作ミス避けであって、セキュリティ境界ではない**。被害を区切っているのは有効期限

---

## 1. 発行と登録

1. HCP Terraform → Organization Settings → Teams → **owners** → Team API tokens → Create
   - Description: `claude-code`（ローテーションの `works blue` / `works green` と区別できれば何でもよい）
   - Expiration: **30日**
   - ローテーション中の blue / green は使い回さない。revoke したとき `works` の run まで止まる
2. claude.ai のクラウド環境の設定（セッションのタイトルバーの環境メニュー → Edit）
   - 環境変数: `TF_TOKEN_app_terraform_io=<トークン>`。Terraform CLI がこの名前を自動で読む
   - Network access の許可ドメインに `app.terraform.io` と `registry.terraform.io` を足す（CLI 本体の `releases.hashicorp.com` と provider の GitHub はすでに通る）
3. 新しいセッションから効く。トークンをチャットに貼らない

Terraform CLI は SessionStart hook（`.claude/hooks/install-terraform.sh`）が入れる。バージョンはワークスペース `works` の `terraform_version` に合わせてある。上げるときは両方を揃える。

## 2. 更新

期限の数日前に §1 をやり直し、古いトークンを revoke する。期限切れを放置しても `works` の run には影響しない。Claude の plan が 401 で落ちるだけ。

## 3. 漏れた疑いがあるとき

owners team → Team API tokens で `claude-code` を **すぐ revoke** する。owners 権限なので、期限を待たない。

そのあと、組織の Audit trail は Free だと見られないので、ワークスペースの run 履歴と変数の更新日時を見て、身に覚えのない run や変更がないかを確かめる。

## 4. 柵の中身

`.claude/hooks/guard-terraform.sh`（PreToolUse / Bash）が止めるもの:

| 止めるもの | 理由 |
|---|---|
| `terraform` の `init` `plan` `validate` `fmt` `version` `providers` 以外 | apply / destroy に加え、`state` `output` `show` `console` は state を読む。state にはローテーション中のトークンが平文で入っている |
| `app.terraform.io` への GET 以外（`-X POST` や `-d` など） | API で run を apply したり変数を書き換えたりしない |
| `TF_TOKEN_app_terraform_io` を `app.terraform.io` 以外の URL と同じコマンドで使うこと | トークンの持ち出し |

コマンド文字列を正規表現で見ているだけなので、スクリプトを書いて実行する、変数を経由するなど、回り道はいくらでもある。
