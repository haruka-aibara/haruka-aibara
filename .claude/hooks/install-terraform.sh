#!/usr/bin/env bash
# SessionStart: クラウドセッションに Terraform CLI を入れる。
# リモート speculative plan（terraform plan）を回すためのもの。手順は
# docs/runbooks/claude-hcp-terraform-token.md。
set -euo pipefail

[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0

# ワークスペース works の terraform_version（~> 1.16.0）に合わせる。
version="1.16.3"

if command -v terraform >/dev/null 2>&1 && terraform version | head -1 | grep -q "v${version}$"; then
  exit 0
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

base="https://releases.hashicorp.com/terraform/${version}"
zip="terraform_${version}_linux_amd64.zip"
curl -fsSL -o "$tmp/$zip" "$base/$zip"
curl -fsSL -o "$tmp/SHA256SUMS" "$base/terraform_${version}_SHA256SUMS"
(cd "$tmp" && grep " ${zip}\$" SHA256SUMS | sha256sum -c - >/dev/null)

python3 -c 'import sys, zipfile; zipfile.ZipFile(sys.argv[1]).extract("terraform", sys.argv[2])' "$tmp/$zip" "$tmp"
install -m 0755 "$tmp/terraform" /usr/local/bin/terraform
