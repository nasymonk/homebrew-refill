#!/usr/bin/env bash
# 统一上游取数通道，供 bump-*.sh 通过 source 调用。
#
# 背景（2026-11-15 排查）：
#  - GitHub Actions 境外 runner 请求 download.arczip.app/appcast.xml 被
#    Cloudflare 以 403 拒绝，arczip 自 2026-10-25 起停止跟踪上游；
#  - www.codebuddy.cn/v2/update 对境外 runner 返回旧渠道版本（5.9.3），
#    国内已是 5.11.3，CI 因此持续判定 already up-to-date。
# 因此版本信息统一优先经 ACS（中国大陆出口）获取；ACS 不可用时退回本机直连，
# 保证 fork / 本地开发仍可运行（只是可能取不到国内视角的版本）。
#
# 大文件（WorkBuddy 双架构各约 450MB）一律在 ACS 端下载并计算 sha256、
# 读取包内 .app 名，只回传一行文本，避免近 1GB 跨国传输拖垮巡检超时。
#
# 函数：
#   upstream_cat <url>         输出响应体（appcast / JSON）
#   upstream_sha256 <url>      输出下载内容的 sha256
#   upstream_zip_info <url>    输出 "<sha256> <顶层 .app 名或 ->"
#
# 环境变量：
#   ACS_HOST       SSH 别名，默认 acs；CI 由 workflow 设为 acs-host
#   UPSTREAM_MODE  auto（默认，探测 ACS）| acs（强制）| direct（强制直连）

UPSTREAM_HOST="${ACS_HOST:-acs}"
UPSTREAM_MODE="${UPSTREAM_MODE:-auto}"
UPSTREAM_UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# 远端 / 本地共用的下载与摘要脚本，U 与 UA 由调用方以环境变量传入。
read -r -d '' _UPSTREAM_INFO_CMD <<'EOS' || true
set -e
f=$(mktemp)
trap 'rm -f "$f"' EXIT
curl -fsSL --retry 3 --retry-delay 5 --retry-all-errors --max-time 900 -A "$UA" -o "$f" "$U"
sha=$(shasum -a 256 "$f" | cut -d' ' -f1)
app=$(unzip -Z1 "$f" 2>/dev/null | grep -oE '^[^/]+\.app' | head -1 || true)
[ -n "$app" ] || app="-"
printf '%s %s\n' "$sha" "$app"
EOS

_upstream_check_url() {
  local url="$1"
  case "$url" in
    https://download.arczip.app/*|https://www.codebuddy.cn/*|https://download.codebuddy.cn/*) ;;
    *) echo "upstream: URL 不在白名单，拒绝访问: $url" >&2; return 1 ;;
  esac
  # URL 会被拼进远端 shell 命令，只允许常规字符集（排除引号、$、反引号、空格等）
  local re='^https://[A-Za-z0-9._~:/?&=%+-]+$'
  if [[ ! "$url" =~ $re ]]; then
    echo "upstream: URL 含非法字符，拒绝访问: $url" >&2
    return 1
  fi
}

_upstream_use_acs() {
  if [ -n "${_UPSTREAM_DECIDED:-}" ]; then
    [ "$_UPSTREAM_DECIDED" = 1 ]
    return
  fi
  case "$UPSTREAM_MODE" in
    acs)    _UPSTREAM_DECIDED=1 ;;
    direct) _UPSTREAM_DECIDED=0 ;;
    *)
      if ssh -o BatchMode=yes -o ConnectTimeout=5 "$UPSTREAM_HOST" true >/dev/null 2>&1; then
        _UPSTREAM_DECIDED=1
      else
        _UPSTREAM_DECIDED=0
      fi
      ;;
  esac
  if [ "$_UPSTREAM_DECIDED" = 1 ]; then
    echo "upstream: 经 ACS($UPSTREAM_HOST) 取上游数据" >&2
  else
    echo "upstream: ACS 不可用，退回本机直连" >&2
  fi
  [ "$_UPSTREAM_DECIDED" = 1 ]
}

upstream_cat() {
  local url="$1" out
  _upstream_check_url "$url" || return 1
  if _upstream_use_acs; then
    out=$(ssh -o BatchMode=yes -o ConnectTimeout=10 "$UPSTREAM_HOST" \
      "curl -fsSL --retry 3 --retry-delay 5 --retry-all-errors --max-time 90 -A '$UPSTREAM_UA' '$url'") || return 1
  else
    out=$(curl -fsSL --retry 3 --retry-delay 5 --retry-all-errors --max-time 90 -A "$UPSTREAM_UA" "$url") || return 1
  fi
  if [ -z "$out" ]; then
    echo "upstream: 响应为空: $url" >&2
    return 1
  fi
  printf '%s\n' "$out"
}

upstream_zip_info() {
  local url="$1" out sha
  _upstream_check_url "$url" || return 1
  if _upstream_use_acs; then
    out=$(ssh -o BatchMode=yes -o ConnectTimeout=10 "$UPSTREAM_HOST" \
      "U='$url' UA='$UPSTREAM_UA' bash -s" <<<"$_UPSTREAM_INFO_CMD") || return 1
  else
    out=$(U="$url" UA="$UPSTREAM_UA" bash -s <<<"$_UPSTREAM_INFO_CMD") || return 1
  fi
  sha=${out%% *}
  if [[ ! "$sha" =~ ^[0-9a-f]{64}$ ]]; then
    echo "upstream: 摘要结果异常 ($url): $out" >&2
    return 1
  fi
  printf '%s\n' "$out"
}

upstream_sha256() {
  local out
  out=$(upstream_zip_info "$1") || return 1
  printf '%s\n' "${out%% *}"
}
