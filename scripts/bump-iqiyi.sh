#!/usr/bin/env bash
# Bump the iqiyi cask by scraping its download page and inspecting the DMG.
# 页面上的"最新版本"文案不可信（爱奇艺偶尔改文案但未上传新 dmg），
# 因此以 dmg 内 App Bundle 的 CFBundleShortVersionString 为权威版本。
# 注意：爱奇艺 dmg 下载地址固定为 iQIYIMedia_271.dmg（271 为品牌谐音），
# 上游更新为原地覆写，因此不可根据 URL 字符串是否变化来判断是否有更新。
set -euo pipefail

CASK="${1:-Casks/iqiyi.rb}"
PAGE="https://app.iqiyi.com/mac/player/index.html"

html=$(curl -fsSL "$PAGE")

# dmg 地址：static-d.iqiyi.com 域名的 iQIYIMedia_<build>.dmg
new_url=$(grep -oE 'https://static-d\.iqiyi\.com/ext/common/iQIYIMedia_[0-9]+\.dmg' <<<"$html" | head -1)

if [ -z "$new_url" ]; then
  echo "failed to parse dmg url from page" >&2
  echo "possible page structure change, check: $PAGE" >&2
  exit 1
fi

cur_ver=$(grep -m1 'version "' "$CASK" | sed -E 's/.*version "([^"]+)".*/\1/')
cur_url=$(grep -m1 'url "' "$CASK" | sed -E 's/.*url "([^"]+)".*/\1/')
page_ver=$(grep -oE '最新版本.{0,2}[0-9]+\.[0-9]+(\.[0-9]+)?' <<<"$html" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 || true)

ver_key() {
  awk -F. '{printf "%05d%05d%05d%05d", $1, $2, $3, $4}' <<<"$1"
}

# 若 URL 没变且页面文案版本号未增加，则直接视为无需更新（避免每小时无谓下载 dmg）
if [ "$cur_url" = "$new_url" ] && [ -n "$page_ver" ] && [ "$(ver_key "$page_ver")" -le "$(ver_key "$cur_ver")" ]; then
  echo "already up-to-date ($cur_ver, page_ver=$page_ver)"
  exit 0
fi

# 页面提示新版本或 URL 发生变化 → 下载 dmg、挂载提取真实版本并计算 sha256
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/app.dmg" "$new_url"

# 挂载 dmg，从 Info.plist 读取真实版本号（不信任页面文案）
vol_path=$(hdiutil attach "$tmp/app.dmg" -nobrowse -readonly -mountrandom "$tmp" | awk 'END{print $NF}')
app_path=$(echo "$vol_path"/*.app | head -1)
new_ver=$(plutil -p "$app_path/Contents/Info.plist" 2>/dev/null | grep CFBundleShortVersionString | sed -E 's/.*"([^"]+)".*/\1/')
hdiutil detach "$vol_path" -force >/dev/null 2>&1

if [ -z "$new_ver" ]; then
  echo "failed to extract version from app bundle" >&2
  exit 1
fi

# 区分渠道滞后情况：页面文案已更新，但离线 dmg 实际仍是旧版本
if [ "$(ver_key "$new_ver")" -le "$(ver_key "$cur_ver")" ] && [ "$cur_url" = "$new_url" ]; then
  if [ -n "$page_ver" ] && [ "$(ver_key "$page_ver")" -gt "$(ver_key "$cur_ver")" ]; then
    echo "::warning::上游已发布 v$page_ver(页面文案/App Store),离线 dmg 仍为 v$new_ver(渠道滞后),暂无可 bump 内容"
  else
    echo "already up-to-date ($cur_ver)"
  fi
  exit 0
fi

sha=$(shasum -a 256 "$tmp/app.dmg" | cut -d' ' -f1)

sed -i.bak -E \
  -e "s|version \"[^\"]+\"|version \"$new_ver\"|" \
  -e "s|sha256 \"[^\"]+\"|sha256 \"$sha\"|" \
  -e "s|url \"https://static-d\.iqiyi\.com[^\"]+\"|url \"$new_url\"|" \
  "$CASK" && rm -f "$CASK.bak"

echo "bumped $cur_ver -> $new_ver"
echo "url=$new_url"
echo "sha256=$sha"
