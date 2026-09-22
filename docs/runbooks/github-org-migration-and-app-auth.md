# GitHub Organization 移行 + GitHub App 認証 移行手順書

**目的:** HCP Terraform の workspace 変数に置いている長期 PAT (`GITHUB_TOKEN`) を廃止し、GitHub App 認証（1 時間で失効する installation access token の自動発行）に切り替える。あわせて個人アカウントを Organization 化し、Terraform からのリポジトリ新規作成を維持する。

**前提:** この手順は GitHub Web UI / HCP Terraform UI での手作業を含む。Terraform のコード変更だけでは完結しない。

---

## 1. 背景

### 1.1 なぜ PAT のローテーション自動化ができないか

GitHub は **PAT をプログラムから発行する API を提供していない**（classic / fine-grained とも）。REST にも GraphQL にもエンドポイントが存在せず、Web UI での手作業のみ。したがって「期限が来たら自動で発行し直す」仕組みは原理的に構築できない。自動化できるのは期限通知までとなる。

### 1.2 なぜ OIDC でトークンを無くせないか

GitHub の OIDC は **発行側（issuer）専用**である。GitHub Actions が OIDC トークンを発行して AWS / GCP / Azure に渡す方向にのみ対応しており、外部 IdP が発行した OIDC トークンを GitHub API が受理する**受け入れ側の機能は存在しない**。

HCP Terraform 側の dynamic provider credentials も対応先は AWS / GCP / Azure / Vault / Kubernetes / HCP のみで、GitHub provider は対象外。`TFC_WORKLOAD_IDENTITY_TOKEN` を取り出せても渡す先が無い。

Vault を経由する案（HCP Terraform → Vault → GitHub 短命トークン）も成立しない。Vault には GitHub の secrets engine が標準で存在せず（あるのは GitHub *auth method* で、これは GitHub の PAT で Vault にログインする逆方向の機能）、必要な `vault-plugin-secrets-github` は community 製の external plugin である。そして **HCP Vault Dedicated はユーザー提供の external plugin を登録できない**。self-hosted Vault なら可能だが、PEM 1 個を守るために Vault サーバを常時運用する交換レートになる。

### 1.3 採用する解

GitHub App 認証に切り替える。provider が毎 run、App 秘密鍵から JWT を生成して installation access token（**有効期限 1 時間**）を取得するため、API に使われる実トークンは毎回使い捨てになる。ワークスペースに残る長期シークレットは App の秘密鍵 (PEM) 1 個のみ。

| | PAT（現状） | GitHub App（移行後） |
|---|---|---|
| 実トークンの寿命 | 最長 1 年・手動更新 | **1 時間・自動発行** |
| 紐づく主体 | 個人アカウント | App（人に依存しない） |
| 権限粒度 | スコープ単位（粗い） | permission 単位 + インストール先を限定可 |
| 鍵の同時併存 | 不可 | **可（無停止ローテーション）** |

### 1.4 なぜ Organization 化が必要か

GitHub App の installation token では **個人アカウント配下に新規リポジトリを作成できない**。`POST /user/repos` は installation token を受け付けず `Resource not accessible by integration` で失敗する。一方 Organization の `POST /orgs/{org}/repos` は正常に動作する。

これは GitHub 公式の OpenAPI 仕様で確認できる。`POST /user/repos` は `"enabledForGitHubApps": false`、`POST /orgs/{org}/repos` は `"enabledForGitHubApps": true` である。なお「`/user/repos` は GitHub App に対応」と記述する資料があるが、それは **user access token**（ユーザー本人として動作し、ブラウザでの対話認可を要する）の話であり、Terraform の `app_auth` が使う **installation access token** とは別物である。

org 化しない場合、新規リポジトリのみ Web UI で作成してから `import` する運用になる。org 化すれば Terraform が全ライフサイクルを管理できる。

### 1.5 なぜ rename が必要か

GitHub は**ユーザー名と Organization 名で単一のグローバル名前空間を共有**している。`haruka-aibara` は個人アカウントが押さえているため、同名 org は作成できない。

ただし **rename なら名前は即時解放される**（delete の場合は 90 日ロックされる）。GitHub 公式も「org に現在のユーザー名を使いたい場合は、まず個人アカウントを rename してから org を作成する」手順を案内している。

なお **2026-01-12 に個人アカウント → org への変換機能は廃止された**ため、「新 org を作って work を移す」以外の選択肢は元々存在しない。

---

## 2. 到達点

| 対象 | Before | After |
|---|---|---|
| 個人アカウント | `haruka-aibara` | `haruka-aibara-dev` |
| Organization | なし | `haruka-aibara`（GitHub Free, $0） |
| メタ repo（この repo） | `haruka-aibara/haruka-aibara`（個人） | **`haruka-aibara/works`**（旧名が retire、§3.2） |
| 学習ノート repo | `haruka-aibara/haruka-aibara-public` | **`haruka-aibara/docs`**（同上） |
| HCP Terraform workspace | `haruka-aibara` | **`works`**（UI でリネーム、§9.3） |
| プロフィール README | メタ repo と同居 | `haruka-aibara-dev/haruka-aibara-dev`（新設・Terraform 管理外） |
| Pages URL | `haruka-aibara.github.io/haruka-aibara-public/` | **`haruka-aibara.github.io/docs/`**（変更された） |
| provider 認証 | `GITHUB_TOKEN`（PAT） | `GITHUB_APP_*`（installation token） |

### 2.1 同名 org を取る実利と、その限界

同名 org を取ると、転送後もリポジトリの URL が変わらない。外部リンク・Pages URL・`vcs_repo.identifier` がそのまま使える。

**ただしメタ repo はこの恩恵を受けられなかった。** §3.2 の名前 retire に該当したためである。実績は以下のとおり。

| 対象 | 想定 | 実際 |
|---|---|---|
| メタ repo | `haruka-aibara/haruka-aibara` のまま | **`haruka-aibara/works` に改名**（旧名が retire） |
| その他のリポジトリ | URL 不変 | 名前が retire されていなければ不変 |

`providers.tf` の `owner` は org 名が同じなので変更不要のまま。

### 2.2 メタ repo とプロフィール repo の分離

現在 `haruka-aibara/haruka-aibara` は**プロフィール README repo**（リポジトリ名 == ユーザー名が条件）と**Terraform メタ repo** を兼ねている。

org 化にあたり、この 2 つを分離する。

- **メタ repo** → org へ転送。org 名と同名の repo は問題なく作成・保持できるため、URL は `github.com/haruka-aibara/haruka-aibara` のまま変わらない
- **プロフィール repo** → 個人アカウント側に `haruka-aibara-dev/haruka-aibara-dev` として新規作成。README のみの 2 ファイル程度の repo なので Terraform 管理外とする

この分離により、**provider alias（個人アカウント用の第 2 provider）が不要になる**。provider の `owner` は org 一本で済む。

---

## 3. 不可逆・要注意の操作

作業前に必ず把握しておくこと。

| 操作 | リスク | 緩和策 |
|---|---|---|
| 個人アカウントの rename | 旧名 `haruka-aibara` が**即座に誰でも取得可能**になる。奪われたら取り返せない | org 作成画面を事前に開いて待機し、rename 直後に確保する（§5） |
| Organization 作成 | org から user への逆変換は不可 | — |
| 旧ユーザー名の `@mention` | リダイレクトされない | 手動で参照を更新 |
| 旧ユーザー名を含む gist URL | リダイレクトされない | 手動で参照を更新 |

コミットの contribution 紐付けはメールアドレス基準のため、rename しても維持される。

### 3.2 リポジトリ名の retire（最大の落とし穴）

アカウントをリネームすると、条件に該当したリポジトリの `OLD-OWNER/REPOSITORY-NAME` の組み合わせが**永久に使用不可**になる。GitHub の仕様である。

> If the account namespace includes any public repositories that contain an action listed on GitHub Marketplace, **or that had more than 100 clones or more than 100 uses of GitHub Actions in the week prior to you renaming your account**, GitHub permanently retires the old owner name and repository name combination.

**解除手段は存在しない。** self-service の解除は無く、GitHub Support も security 上の理由でまず応じない。

CI が動いているリポジトリは週 100 Actions 実行を容易に超えるため、**能動的に開発しているリポジトリほど該当しやすい**。本移行では、push ごとに 3 ジョブ走るメタ repo が該当し、`haruka-aibara/haruka-aibara` が使用不可になった。

対象は `OWNER/NAME` の組み合わせ単位であり、名前空間全体ではない。該当しなかったリポジトリは元の名前のまま転送できる。

#### 転送フォームの挙動

retire された名前を持つリポジトリは、**転送先の名前欄に別名を入れても弾かれる**。フォームが「現在のリポジトリ名 + 転送先 owner」の組み合わせを検証するため、`haruka-aibara/haruka-aibara` が評価されてしまう。

回避するには、**転送の前にリポジトリ自体をリネームする**。

1. Settings → Repository name で `haruka-aibara` → `works` にリネーム
2. その後 `haruka-aibara-dev/works` を org へ転送（名前は `works` のまま）

この順序なら retire 済みの組み合わせが一度も評価されない。

### 3.1 失うと復旧できないもの

この 3 つだけは確実に保全する。他は失敗しても取り返しがつく。

| 対象 | 理由 |
|---|---|
| **現行 PAT の値**（§4 0-3） | App 認証が動かなかった場合の唯一の戻り道。PAT は API で再発行できないため、削除すると復旧できない |
| **org 作成画面の事前待機**（§5 5-1） | 旧ユーザー名の奪取を防ぐ唯一の緩和策 |
| **App 秘密鍵 (PEM)**（§7 7-4） | 再ダウンロード不可。紛失した場合は鍵の生成からやり直し |

---

## 4. Phase 0: 事前準備（無停止・いつでも実施可）

この Phase は移行日より前に単独でマージしてよい。現状を壊さない。

> **注意:** `tfe_workspace.works`（当時の名前は `haruka-aibara`）は `auto_apply = true` である。main へマージした時点で apply が即座に走る。移行完了後に適用すべき変更を、移行前の PR に混ぜてはならない。

- [ ] **0-1. `github_owner` を `tfe_organization` から分離する**

`locals.tf` の `tfe_organization` が **HCP Terraform の org 名**と **GitHub の owner 名**の両方に使われている。今回は同名 org を取るため値は変わらないが、意味の異なる 2 つの概念が 1 変数に同居しているのは誤りなので分離しておく。

```hcl
locals {
  tfe_organization           = "haruka-aibara" # HCP Terraform の組織名
  github_owner               = "haruka-aibara" # GitHub の owner（移行後は Organization）
  github_app_installation_id = var.github_app_installation_id
}
```

`hcp_terraform.tf` の `vcs_repo.identifier` は GitHub 側を指すため `local.github_owner` に差し替える。`organization` 引数は HCP Terraform 側なので `local.tfe_organization` のまま。

```hcl
resource "tfe_workspace" "aws-cost-allocation-tags" {
  organization = local.tfe_organization                        # HCP Terraform
  vcs_repo {
    identifier = "${local.github_owner}/aws-cost-allocation-tags" # GitHub
  }
}
```

`providers.tf` の `owner` も local を参照するようにしてよい。

- [ ] **0-2. state のバックアップは不要**

HCP Terraform は state の履歴バージョンを自動で保持している。workspace の States タブから任意のバージョンを選び、Advanced トグルから rollback できる（workspace のロックと state 作成権限が必要）。手動でのバックアップ取得は行わない。

- [ ] **0-3. 現行 PAT の値を安全な場所に退避する**

ロールバック時に必要。App 認証の検証が完了するまで削除しない。

- [ ] **0-4. 新しい個人ユーザー名**

`haruka-aibara-dev` に決定済み。本手順書はこの名前を前提に記述する。

- [ ] **0-5. 対象リポジトリを棚卸しする**

`main.tf` の module は 32 件。すべて org へ転送する（プロフィール repo は §6 で新規作成するため転送対象に含まれない）。

```bash
grep '^module "' main.tf | sed 's/module "//; s/" {//'
```

---

## 5. Phase 1: 名前の入れ替え（短時間勝負）

**この Phase だけは中断できない。** 手順 5-2 と 5-3 の間に名前が解放される。

- [ ] **5-1. org 作成画面を開いて待機する**

https://github.com/account/organizations/new を別タブで開き、プラン「Free」を選択した状態にしておく。org 名の入力欄だけ空にして待つ。

- [ ] **5-2. 個人アカウントを rename する**

Settings → Account → Change username → `haruka-aibara-dev`

- [ ] **5-3. 即座に org `haruka-aibara` を作成する**

待機していたタブで org 名に `haruka-aibara` を入力して作成する。Free プランを選択（$0・プライベートリポジトリ無制限・メンバー無制限）。

- [ ] **5-4. 確保できたことを確認する**

```bash
curl -s https://api.github.com/orgs/haruka-aibara | grep '"type"'
# "type": "Organization" が返ればよい
```

ここを過ぎればリスクの高い区間は終了。以降は時間をかけてよい。

---

## 6. Phase 2: プロフィール repo の再構築

- [ ] **6-1. 個人アカウントに新しいプロフィール repo を作成する**

`haruka-aibara-dev` アカウントで、`haruka-aibara-dev` という名前の public repo を作成する（リポジトリ名 == ユーザー名がプロフィール README の条件）。

- [ ] **6-2. プロフィール README を移す**

現在のメタ repo の `README.md` の内容を新 repo に移し、**stats バッジの username を新ユーザー名に更新する**。

```markdown
![GitHubの統計](https://github-readme-stats.vercel.app/api?username=haruka-aibara-dev&show_icons=true&theme=radical)
```

更新しない場合、org（コミット履歴を持たない）の stats を引きに行って空になる。

- [ ] **6-3. メタ repo の `README.md` を書き換える**

プロフィール用の内容から、Terraform 構成の説明に差し替える。この repo が何を管理しているかを記載する。

---

## 7. Phase 3: GitHub App の準備

**repo 転送より前に完了させる。** 転送後に App が無いと Terraform が一切動かせない。

- [ ] **7-1. HCP Terraform の GitHub App を org にインストールする**

HCP Terraform → Settings → Providers → GitHub App から、org `haruka-aibara` に対してインストールする。VCS 連携用（HashiCorp 提供のアプリ）であり、次の 7-2 とは別物。

インストール後、URL に含まれる **installation ID** を控える。

```
https://github.com/organizations/haruka-aibara/settings/installations/<INSTALLATION_ID>
```

> **App 自体は Terraform 管理できない。** GitHub 公式の OpenAPI 仕様において、App に対する書き込み系エンドポイントは webhook 設定・インストールの削除/停止・トークン発行のみで、**App の作成・permissions の変更・秘密鍵の生成・org へのインストールに対応する API が存在しない**。`POST /app-manifests/{code}/conversions` は新規作成専用かつブラウザでのハンドシェイクを要する。provider にあるのは `github_app_installation_repository` 系（インストール済み App とリポジトリの紐付け）だけで、All repositories でインストールするなら出番はない。本節が UI 操作ばかりなのはこのためである。

- [ ] **7-2. Terraform provider 用の GitHub App を自前で作成する**

org の Settings → Developer settings → GitHub Apps → New GitHub App

**Permissions（Repository permissions）:**

| Permission | Level | 用途 |
|---|---|---|
| Administration | **Read and write** | `github_repository`, `topics`, `security_and_analysis`, `github_branch_protection`, `github_repository_vulnerability_alerts`、および **`POST /orgs/{org}/repos` による新規リポジトリ作成** |
| Contents | **Read and write** | `github_repository_file` |
| Workflows | **Read and write** | `.github/workflows/*.yml` の書き込み（`terraform_ci.tf` / `python_ci.tf`）。**これが無いと Contents だけでは 403 になる** |
| Pages | **Read and write** | `github_repository_pages`。Administration では代替できず、無いと `POST /repos/{owner}/{repo}/pages` が 403 になる |
| Metadata | Read（自動付与） | — |

Organization repository の作成に必要なのは Organization permissions ではなく、上記の **Repository permissions → Administration (write)** である。インストール先を All repositories にしておくことで、まだ存在しない repo の作成もこの権限で通る。

- [ ] **7-3. App を org にインストールする**

インストール先は **All repositories** を推奨（Terraform が新規作成する repo を自動的に含めるため）。

- [ ] **7-4. App ID / Installation ID / 秘密鍵を控える**

- **App ID**: App の設定画面トップに表示
- **Installation ID**: インストール後の URL 末尾
- **秘密鍵**: 「Generate a private key」で `.pem` をダウンロード。**再ダウンロード不可**なので確実に保管する

---

## 8. Phase 4: リポジトリ転送

GitHub の **Move work to an organization** フローを使う。リポジトリと Projects を**まとめて選択して一括で移せる**ため、リポジトリごとに Danger Zone を開く必要はない。

- [ ] **8-1. Move work フローを実行する**

Settings → Organizations → "Move to an organization" セクション → **Move work to an organization**

プロンプトに従い、移動対象を選択して **Move to an organization** をクリックする。

**選択するもの**: `main.tf` が管理する全リポジトリ（メタ repo `haruka-aibara` を含む）

**選択しないもの**: §6 で作成した新しいプロフィール repo（`haruka-aibara-dev/haruka-aibara-dev`）。これは個人アカウントに残す必要がある

- [ ] **8-1a. retire された名前のリポジトリを先にリネームする**

転送時に "The repository `NAME` has been retired and cannot be reused" が出たリポジトリは、§3.2 の手順で**先にリネームしてから**転送する。転送フォームの名前欄を変えるだけでは通らない。

リネーム後の名前で Terraform 側の参照も更新が必要になる（`main.tf` の `repository_name`、`terraform_ci.tf` / `python_ci.tf` の `for_each` キー、`hcp_terraform.tf` の `vcs_repo.identifier`）。

- [ ] **8-2. 転送結果を確認する**

```bash
curl -s "https://api.github.com/orgs/haruka-aibara/repos?per_page=100" \
  | grep '"name"' | wc -l
```

転送により旧 URL から自動リダイレクトが設定される。さらに org 名が旧ユーザー名と同一のため、転送完了時点で **URL は移行前と同じ文字列に戻る**。

## 9. Phase 5: HCP Terraform / Terraform の切り替え

### 9.1 VCS 連携の復旧（chicken-and-egg に注意）

Move work によって全リポジトリが org に移るため、`hcp_terraform.tf` が管理する **9 つの workspace すべての VCS 連携が同時に切れる**。これらは個人アカウント側の GitHub App インストールを参照していたためである。

ただし手作業で復旧する必要があるのは**メタ repo の workspace 1 つだけ**でよい。残りの 8 つは、そのメタ repo から apply すれば Terraform が `github_app_installation_id` の新しい値で貼り直す。

メタ repo の workspace だけは自分自身の VCS 連携を管理しているため（`tfe_workspace.works`）、Terraform で直せない。ここだけ UI で先に復旧する。

- [ ] **9-0. Claude GitHub App を org にインストールする**

個人アカウントへのインストールは org に引き継がれない。https://github.com/apps/claude/installations/select_target で org を選んでインストールする。これを行うまで Claude Code からの push が 403 で拒否される。

- [ ] **9-1. メタ repo の workspace の VCS 連携を UI で貼り直す**

メタ repo の workspace → Settings → Version Control → 新しい org のインストールを選択し、転送後のリポジトリに再接続する。

- [ ] **9-2. installation id はデータソースから引く**

`vcs_repo.github_app_installation_id` が要求するのは **HCP Terraform 内部の識別子（`ghain-...`）**であり、GitHub の設定画面 URL に出る数値 ID ではない。両者は別物で、数値を入れると apply が次のエラーで落ちる。

```
Error: Error updating workspace ws-...: unprocessable content
GitHub App installation does not exist
```

手入力せず、データソースで解決する。

```hcl
data "tfe_github_app_installation" "this" {
  name = local.github_owner
}
```

```hcl
locals {
  github_app_installation_id = data.tfe_github_app_installation.this.id
}
```

こうしておくと、App を入れ直して識別子が変わっても設定の変更が要らない。手入力用の変数は不要なので、workspace 変数からも削除してよい。

- [ ] **9-2a. apply の前に必ず plan を読む**

UI で VCS 連携を貼り直すと、その workspace の `vcs_repo.github_app_installation_id` だけが state 上で新しくなる。`var.github_app_installation_id` が古いままだと、plan は**貼り直した接続を元に戻そうとする**。

```
# tfe_workspace.works will be updated in-place
  ~ vcs_repo {
      ~ github_app_installation_id = (sensitive value)
    }
```

9 つの workspace のうち UI で触った 1 つだけが差分を出していたら、この状態である。**変数を更新せずに apply すると、直したばかりの接続が切れる。**

- [ ] **9-2b. 転送漏れを plan で検出する**

plan 冒頭の "Objects have changed outside of Terraform" に、`full_name` が `haruka-aibara-dev/...` へ変わったリポジトリが並ぶ。**これらは org へ移っていない。**

```
~ full_name = "haruka-aibara/NAME" -> "haruka-aibara-dev/NAME"
```

provider は 301 リダイレクトを追うため、転送漏れがあっても plan は通ってしまう。ただし org 側に同名リポジトリが作られた時点でリダイレクトが壊れるため、放置してはならない。ここに挙がったものを転送してから次に進む。

Pages を持つリポジトリが残っていると、`homepage_url` が実際の URL と一致しなくなる点にも注意する。

- [ ] **9-2c. secret_scanning の再有効化を確認する**

転送するとセキュリティ設定がリセットされ、plan が全リポジトリに対して以下を出す。

```
~ secret_scanning { status = "disabled" -> "enabled" }
```

これは設定どおりの状態に戻す正しい動作なので、件数が多くても問題ない。

- [ ] **9-3. apply して残り 8 つの workspace を収束させる**

メタ repo の VCS が復旧していれば、apply により他の workspace の `vcs_repo.github_app_installation_id` が新しい値に更新される。UI で 1 つずつ貼り直す必要はない。

apply 後、各 workspace の Version Control 設定が新しい org のインストールを指していることを確認する。

### 9.2 provider 認証の切り替え

- [ ] **9-4. App 認証用の環境変数を宣言する**

3 変数は `workspace_variables.tf` で `tfe_variable` として宣言済みである。値は書かれておらず、作成時にプレースホルダ `set-in-ui` が入るだけになっている。

```hcl
resource "tfe_variable" "github_app_pem_file" {
  workspace_id = tfe_workspace.works.id
  key          = "GITHUB_APP_PEM_FILE"
  value        = "set-in-ui"
  category     = "env"
  sensitive    = true
}
```

HCP Terraform は sensitive 変数の値を API で返さないため、provider は読み取りのたびに **state 上の最後の値をそのまま持ち越す**。設定側の `value` を変えない限り新しい値を書き込むことはないので、`ignore_changes` は不要である。

その裏返しとして、**Terraform はこれらの値を一切認識できない**。UI で鍵が消されても破損しても検知せず、plan はクリーンなままになる。

- [ ] **9-5. apply 直後に UI で実際の値を設定する**

apply の時点では 3 変数とも `set-in-ui` である。**次の run が走る前に**差し替える。

| 変数 | 取得元 |
|---|---|
| `GITHUB_APP_ID` | App の General ページ |
| `GITHUB_APP_INSTALLATION_ID` | org の installations URL 末尾の数値 |
| `GITHUB_APP_PEM_FILE` | PEM 全文 |

ここでの `GITHUB_APP_INSTALLATION_ID` は **GitHub 側の数値 ID** である。§9-2 の `vcs_repo.github_app_installation_id`（HCP Terraform 内部の `ghain-...`）とは別物なので混同しない。provider が GitHub API を直接叩くため、こちらは GitHub の ID を使う。

#### PEM は 1 行化が必須

HCP Terraform の環境変数は**改行を含められない**。そのまま貼ると次のエラーになる。

```
Error saving variable
Value cannot contain newlines in environment variables
```

改行を `\n` の 2 文字に置換して 1 行にする。provider 側が実際の改行に戻す。

```bash
awk '{printf "%s\\n", $0}' your-app.private-key.pem
```

`-----BEGIN` から `-----END ...-----` まで全体を含めること。

**provider のコード変更は不要。** `integrations/github` provider は `app_auth` ブロックが無くても `GITHUB_APP_` prefix の環境変数を参照する。`providers.tf` はコメントの更新のみでよい。

- [ ] **9-6. `GITHUB_TOKEN` を削除する**

値は §4 0-3 で退避済みであること。

**削除は PEM を設定した後に行う。** 先に削除すると workspace に GitHub の資格情報が一切無い状態になり、provider が匿名でリクエストして 60 req/hour の制限に当たる。30 前後のリポジトリを refresh する途中でリトライに入るため、**plan が失敗もせず延々返ってこない**という分かりにくい詰まり方をする。

- [ ] **9-7. 投機的 plan で検証する**

PR を作成して speculative plan を走らせる。

| 結果 | 意味 |
|---|---|
| 成功 | App 認証で GitHub API を叩けている |
| 401 | PEM の 1 行化ミス、または ID の不整合 |
| 403 | permission 不足（特に Workflows） |
| 返ってこない | 資格情報が無効で匿名アクセスになっている |

### 9.3 workspace のリネーム（任意）

workspace 名をリポジトリ名に揃える場合。**Terraform では実行できない。**

HCP Terraform はワークスペースのリネームを、そのワークスペースの全 run が終了状態のときしか受け付けない。リネームする apply 自体が実行中の run なので、自己リネームは必ず次のエラーで失敗する。

```
Name cannot be changed while a run has not completed
```

- [ ] **9-8. 進行中の run が無いことを確認する**
- [ ] **9-9. UI でリネームする** — workspace Settings → General → Name
- [ ] **9-10. 直後にコードを合わせて push する**

順序を逆にすると、まだ旧名のワークスペースに対して新名を要求する run になり、リネームも失敗して詰まる。

コード側で名前を持っている箇所は以下。**`terraform.tf` の `cloud` ブロックを忘れやすい。**

| ファイル | 箇所 |
|---|---|
| `terraform.tf` | `cloud` ブロックの `workspaces.name` |
| `hcp_terraform.tf` | リソースラベル、`name`、`description` |
| `workspace_variables.tf` | `tfe_workspace.<label>.id` の参照 |
| `imports.tf` | import の address と id |
| 一時的な `moved` ブロック | ラベル変更を吸収する。apply 後は消す |
| `README.md` / `docs/` | 文中の参照 |
| `ci/templates/*.tftpl` | 配布先に書き込まれる `Managed by Terraform (...)` の出典表記 |

workspace は ID で識別されるためリネームしても state は壊れず、再 import も不要である。

UI で設定を保存すると `terraform_version` の制約文字列が正規化され（`~> 1.16.0` → `~>1.16.0`）、一度だけ差分として現れることがある。apply すれば元に戻る。

---

---

## 10. Phase 6: 後片付けと検証

- [ ] **10-1. Renovate を org に再インストールする**

`renovate.json` が機能するために必要。個人アカウントへのインストールは org repo をカバーしない。

- [ ] **10-2. ローカルの remote URL を更新する**

リダイレクトは旧ユーザー名が未取得である限りしか保証されない。

```bash
git remote set-url origin git@github.com:haruka-aibara/works.git
```

- [ ] **10-3. Pages の動作を確認する**

```bash
curl -sI https://haruka-aibara.github.io/haruka-aibara-public/ | head -1
```

- [ ] **10-4. プロフィールを確認する**

https://github.com/haruka-aibara-dev に README と stats バッジが表示されること。

- [ ] **10-5. 新規リポジトリ作成を検証する**

`main.tf` にテスト用 module を 1 件追加して apply し、**installation token でリポジトリが作成できること**を確認する（org 化の主目的）。確認後は削除してよいが、`prevent_destroy = true` のため削除には lifecycle の一時解除が必要。

- [ ] **10-6. メタ repo の description と topics を更新する（別 PR）**

`main.tf` の `module "haruka-aibara"` は、プロフィール repo だった頃の記述のまま残っている。

```hcl
description = "Personal profile repository"
topics      = ["profile"]
```

§6 で README を移した時点でこの repo は Terraform メタ repo になっているため、実態に合わせて更新する。

`auto_apply = true` のため、**移行がすべて完了して apply が安定してから別 PR で実施する**こと。移行前の PR に混ぜると、まだ切り替わっていない状態で適用されてしまう。

- [ ] **10-7. 退避した PAT を破棄する**

すべての検証完了後、GitHub 上で PAT を revoke し、退避していた値も削除する。

---

## 11. ロールバック

| 発生箇所 | 復旧方法 |
|---|---|
| Phase 1 で org 名を奪われた | 別名 org で続行するか、移行自体を中止。中止する場合は個人アカウントを元の名前に rename で戻す（未取得なら可能） |
| Phase 5 で App 認証が動かない | `GITHUB_TOKEN` を復元し、`GITHUB_APP_*` を削除。PAT は org repo に対しても有効（org 側で PAT 制限を設けていない場合） |
| state 不整合 | HCP Terraform の States タブから直前のバージョンに rollback |

**注意:** Phase 1（rename と org 作成）は実質的に巻き戻せない。Phase 4 以降の失敗は PAT へのフォールバックで復旧可能なため、リスクは Phase 1 に集中している。

---

## 12. 移行後に残る長期シークレット

### 12.1 結論

PEM は **HCP Terraform の workspace 変数に保管する**。これを前提とする。

| シークレット | 保管先 | 有効期限 | 発行 API | 削除 API | 自動ローテ |
|---|---|---|---|---|---|
| GitHub App 秘密鍵 (PEM) | workspace 変数 | **なし（無期限）** | **なし** | **なし** | **不可** |
| `TFE_TOKEN` | workspace 変数 | 設定可 | あり（team token） | あり | 可 |

### 12.2 PEM のローテーションは自動化できない

GitHub は App 秘密鍵の**生成・削除ともに API を提供していない**。どちらも Web UI での操作のみで、GitHub Support も「そのような API は存在しない」と回答している。BYO Key / 公開鍵登録の feature request は提出済みだが未実装。

したがって以下が確定する。

- 新しい PEM を機械的に作れないため、**ローテーションの起点が必ず手作業になる**
- 起点以降（変数への投入）はスクリプト化できるが、**半自動が上限**
- 鍵の生成・削除は **Audit Log にも記録されない**

補足として、`POST /app-manifests/{code}/conversions` は PEM を返すが、これは **App を新規作成するときだけ**の API であり、事前にブラウザでのハンドシェイク（有効1時間の `code` 取得）を要する。ヘッドレスで実行できず、かつ App ID と installation ID が変わるため、ローテーション手段にはならない。

### 12.3 運用方針

PEM は無期限のため、**放置しても認証は壊れない**。期限切れによる停止は発生しない。

ローテーションが必要になった場合（鍵の漏洩、定期的な衛生管理）は、以下の手順で**無停止**で実施できる。GitHub App は最大 25 本の鍵を同時に有効化でき、鍵が 1 本しかない場合は新鍵を生成するまで旧鍵を削除できない仕様になっている。

1. Web UI で新しい秘密鍵を生成する（**手作業**）
2. workspace 変数 `GITHUB_APP_PEM_FILE` を新しい値に差し替える
3. speculative plan で新鍵が機能することを確認する
4. Web UI で旧鍵を削除する（**手作業**）

手順 2 以降はスクリプト化できるが、1 と 4 は UI 操作が必要である。

### 12.4 検討して採用しなかった案

いずれも「PEM の定期自動ローテーション」という当初の要件を**満たさない**。要件を満たせないのは GitHub 側の制約であり、設計の問題ではない。

**A. ブラウザ自動化（Playwright で GitHub UI を操作）**

要件は満たせるが採用しない。GitHub アカウントの ID / パスワード / TOTP シードを自動化基盤に常駐させる必要があり、これは PEM より遥かに強い権限（全リポジトリ、全 App、組織設定、課金）を持つ。**保護対象より強い認証情報を新たに置くことになり、正味で悪化する。**

**B. KMS sign-only 化**

AWS KMS に `Origin=EXTERNAL` で PEM をインポートすると、鍵は取り出せなくなり `Sign` API での署名のみ可能になる（GitHub App の JWT が要求する `RSASSA_PKCS1_V1_5_SHA_256` に対応）。侵害されても鍵を持ち出せず、IAM 権限の剥奪で即座に停止でき、CloudTrail に署名履歴が残る。

ただし **PEM のローテーション自体は依然として不可能**であり、得られるのは漏洩耐性のみ。Lambda / KMS / IAM / OIDC の構築と運用、AWS への依存（AWS 障害時に GitHub 管理も停止）、KMS 鍵の月額費用に対して、個人のリポジトリ管理という用途では利得が見合わない。

なお、この構成を採る場合は `ephemeral "aws_lambda_invocation"` で run 開始時にトークンを取得する形になり、cron による定期実行は不要になる。将来必要になった場合の参考として記録しておく。

**C. トークンをローテーションして変数に書き込むブローカー**

スケジューラが installation token を発行して workspace 変数を更新する方式。`app_auth` を使えば provider が run ごとに自前でトークンを発行するため、**消費者がこの workspace 1 つだけなら利点がない**。加えて installation token は 1 時間で失効するため、スケジューラの遅延によって残り時間の少ないトークンを掴む危険がある。

ブローカー方式が正当化されるのは、App 認証に非対応のツールなど**複数の消費者にトークンを配布する必要がある場合**に限られる。

### 12.5 `TFE_TOKEN` について

team token は API で発行・失効できるため、PEM と異なり自動ローテーションが可能である（`POST /teams/:team_id/authentication-token`、`expired-at` 指定可）。ローテーション手順は「削除 → 再作成」であり、発行済みトークンの有効期限は変更できない。

ただし自己更新は chicken-and-egg になるため、実行するには別の認証情報を持つ外部の実行環境が必要になる。

---

## 付録 A: 参照

- [Username changes — GitHub Docs](https://docs.github.com/en/account-and-profile/concepts/username-changes)
- [Moving your work to an organization — GitHub Docs](https://docs.github.com/en/account-and-profile/how-tos/account-management/moving-your-work-to-an-organization)
- [Deprecation of user to organization account transformation — GitHub Changelog (2026-01-12)](https://github.blog/changelog/2026-01-12-deprecation-of-user-to-organization-account-transformation/)
- [GitHub's plans — GitHub Docs](https://docs.github.com/get-started/learning-about-github/githubs-products)
- [github/rest-api-description — GitHub 公式 OpenAPI 仕様](https://github.com/github/rest-api-description)（`POST /user/repos` は `enabledForGitHubApps: false`、`POST /orgs/{org}/repos` は `true`）
- [Create a repository using a GitHub App Installation Token · community · Discussion #137174](https://github.com/orgs/community/discussions/137174)
- [Unable to create a Personal Access Token via API · community · Discussion #148626](https://github.com/orgs/community/discussions/148626)
- [GitHub Provider — integrations/github (Terraform Registry)](https://registry.terraform.io/providers/integrations/github/latest/docs)
- [Permissions required for fine-grained personal access tokens — GitHub Docs](https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens)
- [Managing private keys for GitHub Apps — GitHub Docs](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/managing-private-keys-for-github-apps)
- [API to Automate Rotation of Private Keys for Github App · community · Discussion #39274](https://github.com/community/community/discussions/39274)
- [Feature Request: BYO Key / Programmatic Key Generation for Apps · community · Discussion #18603](https://github.com/orgs/community/discussions/18603)
- [private key operations do not generate an audit-log entry · community · Discussion #172472](https://github.com/orgs/community/discussions/172472)
- [Registering a GitHub App from a manifest — GitHub Docs](https://docs.github.com/en/apps/sharing-github-apps/registering-a-github-app-from-a-manifest)
- [/teams/:team_id/authentication-tokens API reference for HCP Terraform](https://developer.hashicorp.com/terraform/cloud-docs/api-docs/team-tokens)
- [Manage workspace state in HCP Terraform](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/state)
- [aws_lambda_invocation | Ephemeral Resources | hashicorp/aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/ephemeral-resources/lambda_invocation)
- [Dynamic provider credentials in HCP Terraform](https://developer.hashicorp.com/terraform/cloud-docs/dynamic-provider-credentials)
- [Constraints and limitations — HCP Vault Dedicated](https://developer.hashicorp.com/hcp/docs/vault/get-started/deployment-considerations/constraints-and-limitations)
