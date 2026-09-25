# エージェント作業ガイド

管理対象を全部集約するリポジトリ。Terraform コード・CI 配布・実装コード・学習メモが同居する。

**鉄則：しゃべりすぎない。** 聞かれたことに答える。前置き・言い換え・実況中継を足さない。短い答えは1〜2文で返す。

**必要なものだけ読む。以下は常時読まない。**

| 触るもの | 読む |
|---|---|
| ルートの `*.tf` / `modules/` / `workflow-dist/` | `README.md` |
| `docs/` 配下 | `docs/reference/README.md` |
| `devcontainer-templates/` | `devcontainer-templates/README.md` |
| 運用手順・過去の経緯を調べる | `docs/runbooks/README.md` |

**ルートの `*.tf` / `modules/` を変えたら、PR を出す前に `terraform init` → `terraform plan` を回して差分を確かめる。** plan は HCP 上の speculative plan として走る。apply や state を読む操作はしない（hook で止めてある）。トークンが無い・通信が通らないときは `docs/runbooks/claude-hcp-terraform-token.md` を案内する。

**README に運用メモを載せない。** 運用手順・ランブックの索引は `docs/runbooks/README.md` に置き、README からは参照しない。

**PRを作るときは `.github/PULL_REQUEST_TEMPLATE.md` に従う。** 概要・変更内容・関連Issue の見出しをそのまま使い、本文を埋める。
