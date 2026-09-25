# ADR-0008: tenv / uv は公式イメージから COPY する

## ステータス

採用 (2026-09-23)。ADR-0002 / ADR-0007 のうち、tenv / uv を「バージョン + アーキ別 SHA256」でピンする部分を置き換える。

## コンテキスト

tenv / uv / Claude Code はリリース成果物を curl で落とし、アーキ別の SHA256 を Dockerfile に書いて検証していた。Renovate はバージョンは上げられても SHA256 は計算できないため、自動更新するには SHA256 を計算し直す仕組みを別に持つ必要があった。

## 決定

- tenv (`ghcr.io/tofuutils/tenv`) と uv (`ghcr.io/astral-sh/uv`) は公式のマルチアーキイメージから `COPY --from=<image>:<tag>@<digest>` で取り込む。digest はマルチアーキの index を指すので amd64 / arm64 の両方に効き、Renovate の標準の dockerfile マネージャーがタグと digest を一緒に更新する。
- Claude Code は公式 Feature (`ghcr.io/anthropics/devcontainer-features/claude-code`) にバージョン指定がなく、ビルド時点の最新が入ってしまう。バージョンを固定するため Dockerfile に残し、SHA256 は `scripts/update-checksums.sh` が npm のプラットフォーム別パッケージから計算し直す。
- features の digest（`devcontainer-lock.json`）は Renovate が更新できないので Dependabot の `devcontainers` に任せる。

## トレードオフ

tenv / uv の SHA256 管理は無くなる代わりに、信頼の起点が「GitHub Releases の成果物」から「公式コンテナイメージの digest」に変わる。依存の更新が Renovate と Dependabot の 2 つに分かれる。
