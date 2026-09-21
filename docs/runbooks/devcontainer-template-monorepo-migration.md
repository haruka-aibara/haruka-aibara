# devcontainer テンプレートのモノレポ統合

`haruka-aibara/devcontainer-templates` を廃止し、テンプレートの定義とリリースをこのリポジトリに寄せるための手順。

## 何が変わるか

- テンプレートの置き場所: `devcontainer-templates/src/haruka-aibara-dev-env/`
- publish するワークフロー: `.github/workflows/devcontainer-release.yaml`
- publish 先: `ghcr.io/haruka-aibara/devcontainer-templates/haruka-aibara-dev-env` → **`ghcr.io/haruka-aibara/works/haruka-aibara-dev-env`**

`devcontainers/action@v1` の publish 先は `ghcr.io/<owner>/<repo>/<template id>` 固定で、リポジトリ名がそのまま入る。ghcr の package はリポジトリを消しても別リポジトリに引き継がれないので、**新しい名前空間へ publish し直すまで旧 package を消さない**。

## 手順

### 1. 統合 PR をマージする

`devcontainer-templates/` 一式とリリースワークフローが main に入る。マージした時点で `devcontainer-templates/src/**` が変わっているので、リリースワークフローが自動で走る。

`.gitignore` の `.devcontainer` を `/.devcontainer`（ルート直下のみ）に直してある。無指定に戻すとテンプレート配下の `.devcontainer/` が丸ごと追跡対象から外れるので注意。

### 2. 初回 publish の結果を確認する

Actions の **Release Dev Container Templates** が成功すると、ジョブサマリに publish されたタグが出る。

CI が push した package は **private** で作られるため、そのままでは `Dev Containers: Clone Repository in Container Volume...` から参照できない。初回だけ以下をやる（以降は引き継がれる）。

1. Organization settings → Packages → Package creation で Public を許可しておく
2. org の Packages → `works/haruka-aibara-dev-env` → Package settings
   - Danger Zone → Change visibility → **Public**
   - Manage Actions access に `works` が入っているか確認（無ければ追加）
3. 匿名 pull できるか確認する:

```bash
curl -s "https://ghcr.io/token?scope=repository:haruka-aibara/works/haruka-aibara-dev-env:pull&service=ghcr.io"
```

`token` が返れば public。

### 3. 実際にテンプレートから開いてみる

VS Code の **Dev Containers: Clone Repository in Container Volume...** で
`ghcr.io/haruka-aibara/works/haruka-aibara-dev-env:latest` を指定し、コンテナが立ち上がるところまで確認する。コンテナ内で smoke test を流すと必須ツールの有無を一括で見られる。

```bash
bash .devcontainer/smoke-test.sh
```

**ここまで通ってから次に進む。** 旧リポジトリはロールバック先なので、それまでは触らない。

### 4. 旧リポジトリを畳む

1. 旧 package（`devcontainer-templates/haruka-aibara-dev-env`）を deprecated 扱いにするか削除する
2. Terraform から管理を外す
   - `main.tf` の `module "devcontainer-templates"` を削除
   - `imports_2025.tf` の対応する `import` ブロックを削除
   - `modules/repository` の `github_repository` には `prevent_destroy = true` が付いている。**リポジトリごと消す**なら `modules/repository/main.tf` の lifecycle を一時的に外して apply する（`bedrock-slack-ai-chatbot` を消したときと同じやり方）。**リポジトリは残して管理だけ外す**なら `removed_2026.tf` に `removed { from = module.devcontainer-templates, lifecycle { destroy = false } }` を足す
   - `works` ワークスペースは `auto_apply = true`。main にマージした時点で apply が走るので、plan は PR の speculative run で確認する
3. GitHub 上でリポジトリを archive または delete する

## ロールバック

新しい名前空間で問題が出たら、旧リポジトリの Actions から `workflow_dispatch`（`skip_version_bump: true`）で旧名前空間に publish し直せる。旧リポジトリと旧 package を残しているあいだは、テンプレート ID を戻すだけで済む。

## 補足: bump コミットと HCP Terraform

リリースワークフローは version を bump したコミットを main に直接 push する。コミットメッセージの `[skip ci]` を GitHub Actions と HCP Terraform の両方が見るので、bump のたびに `works` の apply が走ることはない。ワークフローを触るときにこのマーカーを落とさないこと。

bump コミットが他の PR のマージと競合しないよう、ワークフローは `concurrency` で直列化し、push 前に `git pull --rebase` している。
