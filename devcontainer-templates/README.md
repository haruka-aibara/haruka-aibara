# devcontainer-templates

VS Code の devcontainer テンプレート。旧 `haruka-aibara/devcontainer-templates` リポジトリをこのモノレポに統合したもの。

## 使い方

1. VS Code でコマンドパレット（`Ctrl+Shift+P`）を開く
2. **Dev Containers: Clone Repository in Container Volume...** を選ぶ
3. テンプレート ID を入力する

```
ghcr.io/haruka-aibara/works/haruka-aibara-dev-env:latest
```

## 構成

```
devcontainer-templates/
  README.md                          # このファイル
  docs/adr/                          # 設計判断の記録
  docs/superpowers/                  # 初期設計時の plan / spec
  src/haruka-aibara-dev-env/
    devcontainer-template.json       # テンプレートのメタ情報（version は CI が管理）
    .devcontainer/
      Dockerfile                     # マルチステージビルド
      devcontainer.json              # 拡張機能・設定・features
      devcontainer-lock.json         # features の digest ピン
      post-create.sh                 # コンテナ作成後のセットアップ
      smoke-test.sh                  # 必須ツールの存在確認
```

`.gitignore` はルート直下の `/.devcontainer` だけを無視する。テンプレート配下の `.devcontainer/` は追跡対象なので、無指定の `.devcontainer` に戻さないこと。

## 含まれるツール

| 入れ方 | ツール |
|---|---|
| devcontainer Features | aws-cli, github-cli, kubectl / helm / minikube, node, python, docker-in-docker |
| Dockerfile | gcloud（Google 公式 apt リポジトリ）, tenv, uv, Claude Code, jq / curl / wget / htop / tree / zip / tar |
| post-create.sh | flake8, pylint, pyre-check, pytest, ansible-core, ansible-lint（uv tool）, Terraform 最新安定版（tenv）, Mermaid の AWS アイコン設定 |

公式 Feature があるものは Feature に寄せ、無いものだけ Dockerfile にバージョンピン + SHA256 検証で残す方針。理由は [`docs/adr/0002-prefer-devcontainer-features.md`](docs/adr/0002-prefer-devcontainer-features.md)。

ホストの認証情報はマウントしない。コンテナ内で `aws login` / `gcloud auth login` / `gh auth login` する（[`docs/adr/0004-auth-no-long-lived-secrets.md`](docs/adr/0004-auth-no-long-lived-secrets.md)）。

## リリースフロー

`.github/workflows/devcontainer-release.yaml` が担当する。`workflow-dist/` から配布される CI とは別で、Terraform 管理外なので直接編集してよい。

- `devcontainer-templates/src/**` または当該ワークフローへの push（main）で自動実行
- CI が直前のコミットメッセージを見て `devcontainer-template.json` の version を bump し、main に push
- そのあと `devcontainers/action@v1` が ghcr に publish
- Actions タブから `workflow_dispatch` で手動実行もできる（`skip_version_bump: true` なら bump せず同じバージョンで再 publish）

### バージョン bump ルール

| コミットメッセージ | 変化 |
|---|---|
| `feat: ...` | minor bump（1.4.x → 1.5.0）|
| `fix: ...` / その他 | patch bump（1.4.12 → 1.4.13）|
| `BREAKING ...` | major bump（1.4.x → 2.0.0）|

- `version` は CI が書くので手で変えない。ファイルに入っている番号は「前回 CI が書いた番号」で、publish されるのは +1 した番号
- bump コミットには `[skip ci]` が付く。GitHub Actions だけでなく HCP Terraform の VCS 連携もこれを見るので、`auto_apply = true` の `works` ワークスペースで無駄な apply が走らない。消さないこと
- CI が bump を push したあとは、手元で `git pull` してから作業する

### publish 先

`devcontainers/action@v1` は `ghcr.io/<owner>/<repo>/<template id>` に publish する。リポジトリが変われば publish 先も変わる。

| いつ | publish 先 |
|---|---|
| 現在（`haruka-aibara/works`） | `ghcr.io/haruka-aibara/works/haruka-aibara-dev-env` |
| 統合前（`haruka-aibara/devcontainer-templates`） | `ghcr.io/haruka-aibara/devcontainer-templates/haruka-aibara-dev-env`（〜1.3.1、更新停止）|
| org 移動前（個人アカウント） | `ghcr.io/haruka-aibara-dev/devcontainer-templates/haruka-aibara-dev-env`（〜1.3.0、更新停止）|

package はリポジトリを移しても付いてこないので、publish し直しが要る。統合後の初回 publish でやる手作業は [`docs/runbooks/devcontainer-template-monorepo-migration.md`](../docs/runbooks/devcontainer-template-monorepo-migration.md) を見ること。
