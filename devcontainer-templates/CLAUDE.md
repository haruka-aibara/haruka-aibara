# devcontainer-templates リポジトリ

haruka-aibara の個人用 devcontainer テンプレートを管理するリポジトリ。

## リポジトリ構成

```
src/haruka-aibara-dev-env/
  devcontainer-template.json          # テンプレートメタ情報（version管理）
  .devcontainer/
    Dockerfile                        # マルチステージビルド
    devcontainer.json                 # VS Code拡張・設定・features定義
    post-create.sh                    # コンテナ作成後セットアップ

.github/workflows/release.yaml        # mainへのpushで自動リリース
```

## 含まれるツール

**Dockerfile でインストール（最新版を動的取得）:**
- AWS CLI v2
- Google Cloud CLI (gcloud)
- kubectl, minikube
- tenv (Terraform バージョンマネージャ)
- uv (Python パッケージマネージャ)
- ansible, ansible-lint
- npm, jq, curl, wget, htop, tree, zip/tar 等
- Google Chrome, LibreOffice Impress, fonts-noto-cjk

**post-create.sh でインストール:**
- Python ツール: flake8, pylint, pyre-check, pytest (via uv tool)
- Terraform 最新安定版 (via tenv)
- Mermaid AWS アイコン設定

## リリースフロー

- `src/**` または `release.yaml` への push → GitHub Actions が自動実行
- CI がコミットメッセージを見てバージョンを自動 bump してコミット・push
- その後 `devcontainers/action@v1` がテンプレートを ghcr.io に publish
- Actions タブから `workflow_dispatch` で手動実行も可能
  （`skip_version_bump: true` にすると bump せず現在のバージョンのまま再 publish）

### publish 先

`devcontainers/action@v1` は `ghcr.io/<owner>/<repo>/<template id>` に publish する。
owner は `github.repository` 由来なので、リポジトリの所有者が変わると publish 先も変わる。

| いつ | publish 先 |
|---|---|
| 現在（org `haruka-aibara`） | `ghcr.io/haruka-aibara/devcontainer-templates/haruka-aibara-dev-env` |
| org 移動前（個人 `haruka-aibara-dev`） | `ghcr.io/haruka-aibara-dev/devcontainer-templates/haruka-aibara-dev-env`（〜1.3.0、更新停止） |

ghcr の package はリポジトリ transfer では移動しないため、org 側へは publish し直しが必要。

### org での初回 publish 時の手動作業

CI が push した package は **private** で作られるため、そのままでは
`Dev Containers: Clone Repository in Container Volume...` から参照できない。
初回 publish 後に一度だけ以下を実施する（以降は自動で引き継がれる）。

1. Organization settings → Packages → Package creation で Public を許可しておく
2. publish 後、org の Packages → 該当 package → Package settings
   - Danger Zone → Change visibility → **Public**
   - Manage Actions access にリポジトリが入っているか確認（無ければ追加）
3. 匿名 pull できるか確認:
   `curl -s "https://ghcr.io/token?scope=repository:haruka-aibara/devcontainer-templates/haruka-aibara-dev-env:pull&service=ghcr.io"`
   → `token` が返れば public

### バージョン bump ルール

| コミットメッセージ | 変化 |
|---|---|
| `feat: ...` | minor bump（例: 0.4.x → 0.5.0）|
| `fix: ...` / その他 | patch bump（例: 0.4.12 → 0.4.13）|
| `BREAKING ...` | major bump（例: 0.4.x → 1.0.0）|

### バージョンについての注意

- `devcontainer-template.json` の `version` フィールドは CI が自動管理するため手動で変えない
- push 時点でファイルに入っている番号は「前回 CI が書いた番号」であり、CI が push 後に +1 して publish する
- publish されるバージョンは CI が bump した後の番号（手元のファイルの番号ではない）
- CI の bump コミット後に `git pull` すれば手元も揃う

## push 手順

CI が自動 bump コミットを push するため、ローカルが遅れていることが多い。
**必ず pull してから push すること。**

```bash
git stash          # 未ステージ変更があれば
git pull --rebase origin main
git stash pop      # stash した場合
git push origin main
```

## バージョン管理の方針

- Dockerfile 内のツールはほぼ全て "latest" を動的取得（固定バージョンなし）
- GitHub Actions: `actions/checkout@v4`, `devcontainers/action@v1`
- devcontainer feature: `ghcr.io/devcontainers/features/docker-in-docker:2`
