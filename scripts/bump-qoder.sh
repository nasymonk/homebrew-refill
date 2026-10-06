#!/usr/bin/env bash
# Bump the qoder cask (全新 Qoder / agentic platform, 0.1.x 版本线) via the
# official desktop update API + electron-updater 的 latest-mac.yml。
# 注意：这条线与旧 "Qoder IDE"(1.2x) 是不同产品，更新通道为 desktop；
# 桶里只有带版本号路径（无 latest 别名），版本号必须来自更新接口。
set -euo pipefail

CASK="${1:-Casks/qoder.rb}"
UPDATE_API="https://center.qoder.sh/algo/api/update/desktop/darwin-arm64/stable/latest"

# --- 1. 查询更新接口，取最新版本号与 latest-mac.yml 地址 ---
# 更新接口偶尔连接抖动（SSL_ERROR_SYSCALL），用较长重试间隔兜底；
# 失败则本次跳过，由下一次调度重试；该 cask 会在 Job summary 中标为 FAIL 并使 job 变红，
# 不再静默（见 scripts/run-bump.sh），也不影响其它 cask。
api_json=$(curl -fsSL --retry 3 --retry-delay 15 --retry-all-errors --max-time 30 "$UPDATE_API?version=0.0.0")

new_ver=$(python3 -c 'import json,sys; print(json.load(sys.stdin)["name"])' <<<"$api_json")
yml_url=$(python3 -c 'import json,sys; print(json.load(sys.stdin)["url"])' <<<"$api_json")

if [ -z "$new_ver" ] || [ -z "$yml_url" ]; then
  echo "failed to parse update API response: $api_json" >&2
  exit 1
fi

cur_ver=$(grep -m1 'version "' "$CASK" | sed -E 's/.*version "([^"]+)".*/\1/')

# --- 2. 版本未变 → 跳过 ---
if [ "$new_ver" = "$cur_ver" ]; then
  echo "already up-to-date ($cur_ver)"
  exit 0
fi

# --- 3. 解析 latest-mac.yml 取 arm64 zip 地址与官方 sha256 ---
yml=$(curl -fsSL --retry 2 --retry-delay 10 --max-time 30 "$yml_url")
arm_url=$(grep -oE 'https://[^ ]+Qoder-mac-arm64\.zip' <<<"$yml" | head -1 || true)
if [ -z "$arm_url" ]; then
  echo "failed to parse arm zip url from $yml_url" >&2
  exit 1
fi

# x64 不在 yml 的 files 列表里，按同路径替换架构后缀推导并探活
intel_url="${arm_url/Qoder-mac-arm64.zip/Qoder-mac-x64.zip}"
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

# 防御：本地计算的 arm sha 须与 yml 声明一致（防 CDN 不一致/篡改）
yml_sha=$(awk '/url:.*Qoder-mac-arm64\.zip/{f=1;next} f && /sha256:/{print $2; exit}' <<<"$yml")
if [ -n "$yml_sha" ] && [ "$arm_sha" != "$yml_sha" ]; then
  echo "arm zip sha256 mismatch: local=$arm_sha yml=$yml_sha" >&2
  exit 1
fi

# --- 5. 从 zip 提取顶层 .app 名与真实版本号（以 App Bundle 为权威）---
app_name=$(unzip -Z1 "$tmp/arm.zip" | grep -oE '^[^/]+\.app' | head -1 || true)
if [ -z "$app_name" ]; then
  echo "failed to locate .app inside arm zip" >&2
  exit 1
fi
unzip -o -q "$tmp/arm.zip" "$app_name/Contents/Info.plist" -d "$tmp"
bundle_ver=$(plutil -p "$tmp/$app_name/Contents/Info.plist" 2>/dev/null | grep CFBundleShortVersionString | sed -E 's/.*"([^"]+)".*/\1/' || true)
if [ -n "$bundle_ver" ] && [ "$bundle_ver" != "$new_ver" ]; then
  echo "::warning::bundle version ($bundle_ver) differs from API version ($new_ver), using bundle version"
  new_ver="$bundle_ver"
fi

# --- 6. 改写 cask（url 使用 #{version} 插值，只需改 version / sha256 / app）---

sed -i.bak -E "s/version \"[^\"]+\"/version \"$new_ver\"/" "$CASK" && rm -f "$CASK.bak"
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
