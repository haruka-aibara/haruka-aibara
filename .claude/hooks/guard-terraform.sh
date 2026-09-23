#!/usr/bin/env bash
# PreToolUse(Bash): HCP Terraform のトークン（TF_TOKEN_app_terraform_io）を
# 持たせたセッションで、plan より先に進む操作を止める。
#
# owners team のトークンなので権限そのものは絞れていない。これは操作ミスを
# 防ぐための柵で、セキュリティ境界ではない。背景は
# docs/runbooks/claude-hcp-terraform-token.md。
set -euo pipefail

# jq が無い環境（ローカルの VS Code など）では sed で command の値だけを抜く。
# JSON のエスケープ（\" など）は残るが、下の判定には効かない。
input="$(cat)"
if command -v jq >/dev/null 2>&1; then
  cmd="$(jq -r '.tool_input.command // empty' <<<"$input")"
else
  cmd="$(sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p' <<<"$input")"
fi
[ -n "$cmd" ] || exit 0

block() {
  echo "blocked by .claude/hooks/guard-terraform.sh: $1" >&2
  exit 2
}

# terraform は plan までに使うサブコマンドだけ許す。apply / destroy に加え、
# state・output・show・console も state（ローテーション中のトークンが入って
# いる）を読むので止める。
allowed="init plan validate fmt version providers"
while read -r sub; do
  [ -n "$sub" ] || continue
  case " $allowed " in
    *" $sub "*) ;;
    *) block "terraform $sub は禁止（許可: $allowed）" ;;
  esac
done < <(grep -oE '(^|[;&|(`])[[:space:]]*terraform([[:space:]]+-[^[:space:]]+)*[[:space:]]+[a-z-]+' <<<"$cmd" \
  | awk '{print $NF}' || true)

# HCP Terraform の API は GET だけ。-d や -F は git など他のコマンドにもあるので、
# HTTP クライアントを呼んでいるときだけ見る。
if grep -qE 'app\.terraform\.io' <<<"$cmd" && grep -qE '(^|[^[:alnum:]_-])(curl|wget|http|xh)([[:space:]]|$)' <<<"$cmd"; then
  if grep -qE '(-X|--request)[[:space:]=]*["'\'']?(POST|PUT|PATCH|DELETE)' <<<"$cmd" \
    || grep -qE '(^|[[:space:]])(-d|-F|-T|--data[a-z-]*|--form[a-z-]*|--upload-file|--json|--post-data|--post-file|--body-data|--body-file|--method)([[:space:]=]|$)' <<<"$cmd"; then
    block "app.terraform.io への書き込み系リクエストは禁止（GET のみ）"
  fi
fi

# トークンを app.terraform.io 以外へ送らない。
if grep -qE 'TF_TOKEN_app_terraform_io' <<<"$cmd"; then
  if grep -oE 'https?://[^/[:space:]"'\'']+' <<<"$cmd" | grep -vqE '^https?://app\.terraform\.io$'; then
    block "TF_TOKEN_app_terraform_io を app.terraform.io 以外の URL と一緒に使うのは禁止"
  fi
fi

exit 0
