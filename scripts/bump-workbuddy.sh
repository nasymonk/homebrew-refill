#!/usr/bin/env bash
# Bump the workbuddy cask（腾讯 WorkBuddy）via 官方 /v2/update 接口。
# url 尾部带 8 位构建标记（随构建变化），故 version / build / 双架构 sha256 一并改写；
# sha256 一律以实际下载文件计算为准（接口的 sha256hash 字段实测与文件不符，不可信）。
#
# 接口与安装包经 scripts/upstream.sh 走 ACS 国内出口：境外 runner 从
# /v2/update 拿到的是旧渠道版本（2026-11 实测 CI 读到 5.9.3 而国内已是 5.11.3），
# 且双架构包合计近 1GB，故摘要在 ACS 端计算后只回传文本，不落 runner 磁盘。
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/upstream.sh"

CASK="${1:-Casks/workbuddy.rb}"
API_ARM="https://www.codebuddy.cn/v2/update?platform=workbuddy-darwin-arm64"
API_X64="https://www.codebuddy.cn/v2/update?platform=workbuddy-darwin-x64"

jget() { python3 -c 'import json,sys; print(json.load(sys.stdin)["'"$2"'"])' <<<"$1"; }

# --- 1. 查询两架构更新接口（国内视角，避免地域渠道差异）---
api_arm=$(upstream_cat "$API_ARM")
api_x64=$(upstream_cat "$API_X64")

new_ver=$(jget "$api_arm" version)
arm_url=$(jget "$api_arm" url)
x64_url=$(jget "$api_x64" url)

if [ -z "$new_ver" ] || [ -z "$arm_url" ] || [ -z "$x64_url" ]; then
  echo "failed to parse update API responses" >&2
  exit 1
fi

# 打印上游实际返回，便于日后从 CI 日志直接发现"接口给旧版"这类地域/灰度偏差。
echo "upstream API: version=$new_ver arm_url=$arm_url"

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

# --- 4. 双架构 zip 的 sha256 与包内 .app 名（在 ACS 端计算，只回传文本）---
arm_info=$(upstream_zip_info "$arm_url")
x64_info=$(upstream_zip_info "$x64_url")

arm_sha=${arm_info%% *}
x64_sha=${x64_info%% *}
app_name=$(awk '{print $2}' <<<"$arm_info")
if [ -z "$app_name" ] || [ "$app_name" = "-" ]; then
  echo "failed to locate .app inside arm zip" >&2
  exit 1
fi
echo "upstream sha256: arm=$arm_sha x64=$x64_sha app=$app_name"

# --- 5. 改写 cask（url 内联完整版本号+构建标记，正则重写 version / 双 url / sha256 / app）---
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
