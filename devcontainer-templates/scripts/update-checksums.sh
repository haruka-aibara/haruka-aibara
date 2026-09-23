#!/usr/bin/env bash
# Dockerfile の CLAUDE_VERSION に合わせて CLAUDE_SHA256_{AMD64,ARM64} を書き換える。
# downloads.claude.ai の配布物と中身が同じ npm のプラットフォーム別パッケージ
# （@anthropic-ai/claude-code-linux-*）を npm pack で取得し、同梱の claude バイナリのハッシュを取る。
# npm pack はレジストリの integrity で tarball を検証する。
# Renovate はバージョンしか上げられないので、.github/workflows/devcontainer-checksums.yaml が
# renovate/** ブランチでこれを実行する。手元で実行してもよい。
set -euo pipefail

dockerfile="${1:-$(dirname "$0")/../src/haruka-aibara-dev-env/.devcontainer/Dockerfile}"
version="$(sed -n 's/^ARG CLAUDE_VERSION=//p' "$dockerfile")"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

for pair in AMD64:linux-x64 ARM64:linux-arm64; do
  arch="${pair%%:*}"
  platform="${pair#*:}"
  tgz="$(npm pack --silent --pack-destination "$tmp" "@anthropic-ai/claude-code-${platform}@${version}")"
  tar -xzf "$tmp/$tgz" -C "$tmp" package/claude
  sha="$(sha256sum "$tmp/package/claude" | cut -d' ' -f1)"
  rm -rf "${tmp:?}/package" "${tmp:?}/${tgz:?}"
  sed -i "s|^ARG CLAUDE_SHA256_${arch}=.*|ARG CLAUDE_SHA256_${arch}=${sha}|" "$dockerfile"
done
