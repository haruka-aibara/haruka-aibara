#!/usr/bin/env bash
# Dockerfile の *_VERSION に合わせて *_SHA256_{AMD64,ARM64} を書き換える。
# Renovate はバージョンしか上げられないので、.github/workflows/devcontainer-checksums.yaml が
# renovate/** ブランチでこれを実行する。手元で実行してもよい。
set -euo pipefail

dockerfile="${1:-$(dirname "$0")/../src/haruka-aibara-dev-env/.devcontainer/Dockerfile}"

arg() { sed -n "s/^ARG $1=//p" "$dockerfile"; }
set_arg() { sed -i "s|^ARG $1=.*|ARG $1=$2|" "$dockerfile"; }
sha_of() { curl -fsSL "$1" | sha256sum | cut -d' ' -f1; }

v="$(arg TENV_VERSION)"
set_arg TENV_SHA256_AMD64 "$(sha_of "https://github.com/tofuutils/tenv/releases/download/${v}/tenv_${v}_amd64.deb")"
set_arg TENV_SHA256_ARM64 "$(sha_of "https://github.com/tofuutils/tenv/releases/download/${v}/tenv_${v}_arm64.deb")"

v="$(arg UV_VERSION)"
set_arg UV_SHA256_AMD64 "$(sha_of "https://github.com/astral-sh/uv/releases/download/${v}/uv-x86_64-unknown-linux-gnu.tar.gz")"
set_arg UV_SHA256_ARM64 "$(sha_of "https://github.com/astral-sh/uv/releases/download/${v}/uv-aarch64-unknown-linux-gnu.tar.gz")"

v="$(arg CLAUDE_VERSION)"
set_arg CLAUDE_SHA256_AMD64 "$(sha_of "https://downloads.claude.ai/claude-code-releases/${v}/linux-x64/claude")"
set_arg CLAUDE_SHA256_ARM64 "$(sha_of "https://downloads.claude.ai/claude-code-releases/${v}/linux-arm64/claude")"
