#!/usr/bin/env bash
# Bump the qoder cask by querying the official in-app update API.
# 上游自 1.25.0 起改名 "Qoder IDE" 并更换发布通道：
# 旧桶 download.qoder.com/release/latest/*.dmg 已永久停更（停在 1.24.2）；
# 新版本以带版本号 zip 发布于 qoder-ide.oss-accelerate.aliyuncs.com/release/<ver>/。
# 权威版本源为应用内更新接口（同时返回 arm64 zip 的 sha256，可做防篡改校验）。
set -euo pipefail

CASK="${1:-Casks/qoder.rb}"
UPDATE_API="https://center.qoder.sh/algo/api/update/darwin-arm64/stable/latest"

# --- 1. 查询更新接口，取最新版本号 / arm64 zip 地址 / 官方 sha256 ---
# 更新接口偶尔连接抖动（SSL_ERROR_SYSCALL），用较长重试间隔兜底；
# 失败时本小时跳过，下一小时调度自动重试，不影响其它 cask（工作流已 continue-on-error）。
api_json=$(curl -fsSL --retry 3 --retry-delay 15 --retry-all-errors --max-time 30 "$UPDATE_API?version=0.0.0")

new_ver=$(python3 -c 'import json,sys; print(json.load(sys.stdin)["name"])' <<<"$api_json")
arm_url=$(python3 -c 'import json,sys; print(json.load(sys.stdin)["url"])' <<<"$api_json")
arm_sha_api=$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("sha256hash") or "")' <<<"$api_json")

if [ -z "$new_ver" ] || [ -z "$arm_url" ]; then
  echo "failed to parse update API response: $api_json" >&2
  exit 1
fi

cur_ver=$(grep -m1 'version "' "$CASK" | sed -E 's/.*version "([^"]+)".*/\1/')

# --- 2. 版本未变 → 跳过 ---
if [ "$new_ver" = "$cur_ver" ]; then
  echo "already up-to-date ($cur_ver)"
  exit 0
fi

# --- 3. 推导 x64 zip 地址（同 release 路径，仅架构后缀不同）并探活 ---
intel_url="${arm_url/Qoder-darwin-arm64.zip/Qoder-darwin-x64.zip}"
if ! curl -fsSI --retry 2 --max-time 30 "$intel_url" >/dev/null; then
  echo "intel zip not reachable: $intel_url" >&2
  exit 1
fi

# --- 4. 下载双架构 zip 并计算 sha256 ---
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL --retry 2 --max-time 600 -o "$tmp/arm.zip" "$arm_url"
curl -fsSL --retry 2 --max-time 600 -o "$tmp/intel.zip" "$intel_url"

arm_sha=$(shasum -a 256 "$tmp/arm.zip" | cut -d' ' -f1)
intel_sha=$(shasum -a 256 "$tmp/intel.zip" | cut -d' ' -f1)

# 防御：本地计算的 arm sha 须与更新接口返回值一致（防 CDN 不一致/篡改）
if [ -n "$arm_sha_api" ] && [ "$arm_sha" != "$arm_sha_api" ]; then
  echo "arm zip sha256 mismatch: local=$arm_sha api=$arm_sha_api" >&2
  exit 1
fi

# --- 5. 从 zip 提取顶层 .app 名（上游有改名前科，如 Qoder.app → Qoder IDE.app）---
app_name=$(unzip -Z1 "$tmp/arm.zip" | grep -oE '^[^/]+\.app' | head -1 || true)
if [ -z "$app_name" ]; then
  echo "failed to locate .app inside arm zip" >&2
  exit 1
fi

# --- 6. 改写 cask（url 使用 #{version} 插值，只需改 version / sha256 / app）---

# version
sed -i.bak -E "s/version \"[^\"]+\"/version \"$new_ver\"/" "$CASK" && rm -f "$CASK.bak"

# app stanza
sed -i.bak -E "s|app \"[^\"]+\"|app \"$app_name\"|" "$CASK" && rm -f "$CASK.bak"

# sha256: 分 on_arm / on_intel 块替换
awk -v arm="$arm_sha" -v intel="$intel_sha" '
  /on_arm do/   { blk="arm" }
  /on_intel do/ { blk="intel" }
  /sha256 "/ {
    if (blk=="arm")   { sub(/sha256 "[^"]+"/, "sha256 \"" arm "\""); blk="" }
    else if (blk=="intel") { sub(/sha256 "[^"]+"/, "sha256 \"" intel "\""); blk="" }
  }
  { print }
' "$CASK" > "$CASK.tmp" && mv "$CASK.tmp" "$CASK"

echo "bumped $cur_ver -> $new_ver (app: $app_name)"
echo "arm_url=$arm_url"
echo "intel_url=$intel_url"
echo "arm_sha=$arm_sha"
echo "intel_sha=$intel_sha"
