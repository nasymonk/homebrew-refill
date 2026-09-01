#!/usr/bin/env bash
# Bump the workbuddy cask（腾讯 WorkBuddy）via 官方 /v2/update 接口。
# url 尾部带 8 位构建标记（随构建变化），故 version / build / 双架构 sha256 一并改写；
# sha256 一律以下载文件本地计算为准（接口的 sha256hash 字段实测与文件不符，不可信）。
set -euo pipefail

CASK="${1:-Casks/workbuddy.rb}"
API_ARM="https://www.codebuddy.cn/v2/update?platform=workbuddy-darwin-arm64"
API_X64="https://www.codebuddy.cn/v2/update?platform=workbuddy-darwin-x64"

jget() { python3 -c 'import json,sys; print(json.load(sys.stdin)["'"$2"'"])' <<<"$1"; }

# --- 1. 查询两架构更新接口 ---
api_arm=$(curl -fsSL --retry 3 --retry-delay 15 --retry-all-errors --max-time 30 "$API_ARM")
api_x64=$(curl -fsSL --retry 3 --retry-delay 15 --retry-all-errors --max-time 30 "$API_X64")

new_ver=$(jget "$api_arm" version)
arm_url=$(jget "$api_arm" url)
x64_url=$(jget "$api_x64" url)

if [ -z "$new_ver" ] || [ -z "$arm_url" ] || [ -z "$x64_url" ]; then
  echo "failed to parse update API responses" >&2
  exit 1
fi

cur_ver=$(grep -m1 'version "' "$CASK" | sed -E 's/.*version "([^"]+)".*/\1/')

# --- 2. 版本未变 → 跳过 ---
if [ "$new_ver" = "$cur_ver" ]; then
  echo "already up-to-date ($cur_ver)"
  exit 0
fi

# --- 3. 从 url 提取构建标记，并校验与 cask 的 url 模板一致 ---
new_build=$(sed -E 's/.*-([0-9a-f]{8})\.zip$/\1/' <<<"$arm_url")
if [ "$new_build" = "$arm_url" ] || [ ${#new_build} -ne 8 ]; then
  echo "failed to extract build tag from $arm_url" >&2
  exit 1
fi

expect_arm="https://download.codebuddy.cn/workbuddy/saas/darwin-arm64/WorkBuddy-darwin-arm64-${new_ver}-${new_build}.zip"
expect_x64="https://download.codebuddy.cn/workbuddy/saas/darwin-x64/WorkBuddy-darwin-x64-${new_ver}-${new_build}.zip"
if [ "$arm_url" != "$expect_arm" ] || [ "$x64_url" != "$expect_x64" ]; then
  echo "::warning::upstream url pattern changed, cask url template needs manual review" >&2
  echo "  arm: got=$arm_url expect=$expect_arm" >&2
  echo "  x64: got=$x64_url expect=$expect_x64" >&2
  exit 1
fi

# --- 4. 下载双架构 zip 并本地计算 sha256 ---
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL --retry 2 --max-time 900 -o "$tmp/arm.zip" "$arm_url"
curl -fsSL --retry 2 --max-time 900 -o "$tmp/x64.zip" "$x64_url"

arm_sha=$(shasum -a 256 "$tmp/arm.zip" | cut -d' ' -f1)
x64_sha=$(shasum -a 256 "$tmp/x64.zip" | cut -d' ' -f1)

# --- 5. 从 zip 提取顶层 .app 名（以包内为准）---
app_name=$(unzip -Z1 "$tmp/arm.zip" | grep -oE '^[^/]+\.app' | head -1 || true)
if [ -z "$app_name" ]; then
  echo "failed to locate .app inside arm zip" >&2
  exit 1
fi

# --- 6. 改写 cask（url 内联完整版本号+构建标记，正则重写 version / 双 url / sha256 / app）---
sed -i.bak -E "s/version \"[^\"]+\"/version \"$new_ver\"/" "$CASK" && rm -f "$CASK.bak"
sed -i.bak -E "s|WorkBuddy-darwin-arm64-[0-9.]+-[0-9a-f]+\.zip|WorkBuddy-darwin-arm64-${new_ver}-${new_build}.zip|" "$CASK" && rm -f "$CASK.bak"
sed -i.bak -E "s|WorkBuddy-darwin-x64-[0-9.]+-[0-9a-f]+\.zip|WorkBuddy-darwin-x64-${new_ver}-${new_build}.zip|" "$CASK" && rm -f "$CASK.bak"
sed -i.bak -E "s|app \"[^\"]+\"|app \"$app_name\"|" "$CASK" && rm -f "$CASK.bak"

awk -v arm="$arm_sha" -v intel="$x64_sha" '
  /on_arm do/   { blk="arm" }
  /on_intel do/ { blk="intel" }
  /sha256 "/ {
    if (blk=="arm")   { sub(/sha256 "[^"]+"/, "sha256 \"" arm "\""); blk="" }
    else if (blk=="intel") { sub(/sha256 "[^"]+"/, "sha256 \"" intel "\""); blk="" }
  }
  { print }
' "$CASK" > "$CASK.tmp" && mv "$CASK.tmp" "$CASK"

echo "bumped $cur_ver -> $new_ver (build: $new_build, app: $app_name)"
echo "arm_sha=$arm_sha"
echo "x64_sha=$x64_sha"
