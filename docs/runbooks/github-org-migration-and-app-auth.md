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

org 化しない場合、新規リポジトリのみ Web UI で作成してから `import` する運用になる。org 化すれば Terraform が全ライフサイクルを管理できる。

### 1.5 なぜ rename が必要か

GitHub は**ユーザー名と Organization 名で単一のグローバル名前空間を共有**している。`haruka-aibara` は個人アカウントが押さえているため、同名 org は作成できない。

ただし **rename なら名前は即時解放される**（delete の場合は 90 日ロックされる）。GitHub 公式も「org に現在のユーザー名を使いたい場合は、まず個人アカウントを rename してから org を作成する」手順を案内している。

なお **2026-01-12 に個人アカウント → org への変換機能は廃止された**ため、「新 org を作って work を移す」以外の選択肢は元々存在しない。

---

## 2. 到達点

| 対象 | Before | After |
|---|---|---|
| 個人アカウント | `haruka-aibara` | `haruka-aibara-dev`（例） |
| Organization | なし | `haruka-aibara`（GitHub Free, $0） |
| メタ repo（この repo） | `haruka-aibara/haruka-aibara`（個人） | `haruka-aibara/haruka-aibara`（**org・URL 不変**） |
| プロフィール README | メタ repo と同居 | `haruka-aibara-dev/haruka-aibara-dev`（新設・Terraform 管理外） |
| Pages URL | `haruka-aibara.github.io/haruka-aibara-public/` | **同一** |
| provider 認証 | `GITHUB_TOKEN`（PAT） | `GITHUB_APP_*`（installation token） |

### 2.1 同名 org を取る実利

見た目の問題ではなく、以下が保たれる。

- **Pages URL が一文字も変わらない**（`main.tf` の `homepage_url` を書き換えずに済む）
- **メタ repo の URL が不変**なため、`hcp_terraform.tf` の `vcs_repo.identifier = "${local.tfe_organization}/haruka-aibara"` がそのまま動く
- `providers.tf` の `owner = "haruka-aibara"` も変更不要
- repo 転送後、外部リンクが最終的に元の URL に収束する

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

---

## 4. Phase 0: 事前準備（無停止・いつでも実施可）

この Phase は移行日より前に単独でマージしてよい。現状を壊さない。

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

- [ ] **0-2. 現状のバックアップを取る**

```bash
# state のバックアップ（HCP Terraform UI からも取得可）
terraform state pull > /tmp/tfstate-backup-$(date +%Y%m%d).json
```

- [ ] **0-3. 現行 PAT の値を安全な場所に退避する**

ロールバック時に必要。App 認証の検証が完了するまで削除しない。

- [ ] **0-4. 新しい個人ユーザー名を決める**

本手順書では `haruka-aibara-dev` を例として使う。

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

- [ ] **7-2. Terraform provider 用の GitHub App を自前で作成する**

org の Settings → Developer settings → GitHub Apps → New GitHub App

**Permissions（Repository permissions）:**

| Permission | Level | 用途 |
|---|---|---|
| Administration | **Read and write** | `github_repository`, `topics`, `security_and_analysis`, `github_branch_protection`, `github_repository_vulnerability_alerts`、および **`POST /orgs/{org}/repos` による新規リポジトリ作成** |
| Contents | **Read and write** | `github_repository_file` |
| Workflows | **Read and write** | `.github/workflows/*.yml` の書き込み（`terraform_ci.tf` / `python_ci.tf`）。**これが無いと Contents だけでは 403 になる** |
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

- [ ] **8-1. メタ repo 以外を org へ転送する**

各 repo の Settings → Danger Zone → Transfer ownership → `haruka-aibara`

転送により旧 URL から自動リダイレクトが設定される。さらに org 名が旧ユーザー名と同一のため、転送完了時点で **URL は移行前と同じ文字列に戻る**。

- [ ] **8-2. メタ repo（この repo）を最後に転送する**

他の repo の転送が完了してから実施する。メタ repo を先に移すと HCP Terraform の VCS 連携が切れた状態で作業することになる。

- [ ] **8-3. 転送結果を確認する**

```bash
curl -s "https://api.github.com/orgs/haruka-aibara/repos?per_page=100" \
  | grep '"name"' | wc -l
```

---

## 9. Phase 5: HCP Terraform / Terraform の切り替え

### 9.1 VCS 連携の復旧（chicken-and-egg に注意）

メタ repo の workspace は **自分自身の VCS 連携を Terraform で管理している**（`tfe_workspace.haruka-aibara`）。転送により VCS 連携が切れるため、UI で先に復旧してから state を整合させる。

- [ ] **9-1. HCP Terraform UI で workspace の VCS 連携を貼り直す**

workspace `haruka-aibara` → Settings → Version Control → 新しい org のインストールを選択し、`haruka-aibara/haruka-aibara` に再接続する。

- [ ] **9-2. workspace 変数 `github_app_installation_id` を更新する**

7-1 で控えた新しい installation ID に差し替える（Terraform variable、sensitive）。

- [ ] **9-3. 他の workspace の VCS 連携も同様に確認する**

`hcp_terraform.tf` が管理する 9 つの workspace すべてが新しい installation を参照する必要がある。9-2 の変数更新が反映されれば apply で収束するが、apply 前に VCS が切れている workspace は UI で先に復旧する。

### 9.2 provider 認証の切り替え

- [ ] **9-4. App 認証用の環境変数を workspace に追加する**

workspace `haruka-aibara` の **Environment variables** に以下を追加する。

| 変数名 | 値 | sensitive |
|---|---|---|
| `GITHUB_APP_ID` | App ID | — |
| `GITHUB_APP_INSTALLATION_ID` | Installation ID | — |
| `GITHUB_APP_PEM_FILE` | PEM の中身 | **Yes** |

PEM は改行を `\n` に置換した 1 行でも受け付けられる。

```bash
# PEM を 1 行化する
awk 'BEGIN{ORS="\\n"} {print}' your-app.private-key.pem
```

**provider のコード変更は不要。** `integrations/github` provider は `app_auth` ブロックが無くても `GITHUB_APP_` prefix の環境変数を参照する。`providers.tf` はコメントの更新のみでよい。

```hcl
provider "github" {
  owner = local.github_owner
  # GitHub App authentication (GITHUB_APP_ID / GITHUB_APP_INSTALLATION_ID /
  # GITHUB_APP_PEM_FILE) is configured as environment variables on HCP Terraform.
  # The provider mints a 1-hour installation access token per run.
}
```

- [ ] **9-5. `GITHUB_TOKEN` を削除する**

`GITHUB_TOKEN` が残っていると App 認証より優先される可能性があるため、切り替えの検証時には削除する。値は 0-3 で退避済みであること。

- [ ] **9-6. 投機的 plan で検証する**

PR を作成して speculative plan を走らせ、**差分が出ないこと**を確認する。ここで 403 が出る場合は 7-2 の permission（特に Workflows）を見直す。

---

## 10. Phase 6: 後片付けと検証

- [ ] **10-1. Renovate を org に再インストールする**

`renovate.json` が機能するために必要。個人アカウントへのインストールは org repo をカバーしない。

- [ ] **10-2. ローカルの remote URL を更新する**

リダイレクトは旧ユーザー名が未取得である限りしか保証されない。

```bash
git remote set-url origin git@github.com:haruka-aibara/haruka-aibara.git
```

- [ ] **10-3. Pages の動作を確認する**

```bash
curl -sI https://haruka-aibara.github.io/haruka-aibara-public/ | head -1
```

- [ ] **10-4. プロフィールを確認する**

https://github.com/haruka-aibara-dev に README と stats バッジが表示されること。

- [ ] **10-5. 新規リポジトリ作成を検証する**

`main.tf` にテスト用 module を 1 件追加して apply し、**installation token でリポジトリが作成できること**を確認する（org 化の主目的）。確認後は削除してよいが、`prevent_destroy = true` のため削除には lifecycle の一時解除が必要。

- [ ] **10-6. 退避した PAT を破棄する**

すべての検証完了後、GitHub 上で PAT を revoke し、退避していた値も削除する。

---

## 11. ロールバック

| 発生箇所 | 復旧方法 |
|---|---|
| Phase 1 で org 名を奪われた | 別名 org で続行するか、移行自体を中止。中止する場合は個人アカウントを元の名前に rename で戻す（未取得なら可能） |
| Phase 5 で App 認証が動かない | `GITHUB_TOKEN` を復元し、`GITHUB_APP_*` を削除。PAT は org repo に対しても有効（org 側で PAT 制限を設けていない場合） |
| state 不整合 | 0-2 のバックアップから復元 |

**注意:** Phase 1（rename と org 作成）は実質的に巻き戻せない。Phase 4 以降の失敗は PAT へのフォールバックで復旧可能なため、リスクは Phase 1 に集中している。

---

## 12. 移行後に残る長期シークレット

| シークレット | 保管先 | API 経由の発行 | ローテーション方法 |
|---|---|---|---|
| GitHub App 秘密鍵 (PEM) | HCP Terraform workspace 変数 | 不可 | **複数鍵を同時有効化できるため無停止で可能**（新鍵生成 → 変数差し替え → 旧鍵削除） |
| `TFE_TOKEN` | HCP Terraform workspace 変数 | 可（team token） | 有効期限付き team token + 期限通知で運用。自己更新は chicken-and-egg になるため自動化の費用対効果は低い |

PAT と異なり、GitHub App の秘密鍵は複数を同時に有効化できるため、ダウンタイム無しでローテーションできる。

---

## 付録 A: 参照

- [Username changes — GitHub Docs](https://docs.github.com/en/account-and-profile/concepts/username-changes)
- [Deprecation of user to organization account transformation — GitHub Changelog (2026-01-12)](https://github.blog/changelog/2026-01-12-deprecation-of-user-to-organization-account-transformation/)
- [GitHub's plans — GitHub Docs](https://docs.github.com/get-started/learning-about-github/githubs-products)
- [Create a repository using a GitHub App Installation Token · community · Discussion #137174](https://github.com/orgs/community/discussions/137174)
- [Unable to create a Personal Access Token via API · community · Discussion #148626](https://github.com/orgs/community/discussions/148626)
- [GitHub Provider — integrations/github (Terraform Registry)](https://registry.terraform.io/providers/integrations/github/latest/docs)
- [Permissions required for fine-grained personal access tokens — GitHub Docs](https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens)
- [Dynamic provider credentials in HCP Terraform](https://developer.hashicorp.com/terraform/cloud-docs/dynamic-provider-credentials)
- [Constraints and limitations — HCP Vault Dedicated](https://developer.hashicorp.com/hcp/docs/vault/get-started/deployment-considerations/constraints-and-limitations)
