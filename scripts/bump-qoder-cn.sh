#!/usr/bin/env bash
# Bump the qoder-cn cask (Qoder CN 全新形态, 0.1.x 版本线) via latest-mac.yml。
# 注意：该 cask 与旧 "Qoder CN IDE"(1.2x) 是不同产品。
set -euo pipefail

CASK="${1:-Casks/qoder-cn.rb}"
YML_URL="https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/latest-mac.yml"

# --- 1. 获取 latest-mac.yml ---
yml=$(curl -fsSL --retry 3 --retry-delay 10 --max-time 30 "$YML_URL")

new_ver=$(grep -m1 '^version:' <<<"$yml" | sed -E 's/^version: *//' | tr -d '\r"' || true)

if [ -z "$new_ver" ]; then
  echo "failed to parse version from $YML_URL" >&2
  exit 1
fi

cur_ver=$(grep -m1 'version "' "$CASK" | sed -E 's/.*version "([^"]+)".*/\1/')

# --- 2. 版本未变 → 跳过 ---
if [ "$new_ver" = "$cur_ver" ]; then
  echo "already up-to-date ($cur_ver)"
  exit 0
fi

# --- 3. 解析 arm64 zip 与推导 intel zip ---
arm_url=$(grep -oE 'https://[^ ]+Qoder-CN-mac-arm64\.zip' <<<"$yml" | head -1 || true)
if [ -z "$arm_url" ]; then
  arm_url="https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/${new_ver}/Qoder-CN-mac-arm64.zip"
fi

intel_url="${arm_url/Qoder-CN-mac-arm64.zip/Qoder-CN-mac-x64.zip}"
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

# 防御：本地计算的 arm sha 须与 yml 声明一致
yml_sha=$(awk '/url:.*Qoder-CN-mac-arm64\.zip/{f=1;next} f && /sha256:/{print $2; exit}' <<<"$yml")
if [ -n "$yml_sha" ] && [ "$arm_sha" != "$yml_sha" ]; then
  echo "arm zip sha256 mismatch: local=$arm_sha yml=$yml_sha" >&2
  exit 1
fi

# --- 5. 从 zip 提取顶层 .app 名与真实版本号 ---
app_name=$(unzip -Z1 "$tmp/arm.zip" | grep -oE '^[^/]+\.app' | head -1 || true)
if [ -z "$app_name" ]; then
  echo "failed to locate .app inside arm zip" >&2
  exit 1
fi
unzip -o -q "$tmp/arm.zip" "$app_name/Contents/Info.plist" -d "$tmp"
bundle_ver=$(plutil -p "$tmp/$app_name/Contents/Info.plist" 2>/dev/null | grep CFBundleShortVersionString | sed -E 's/.*"([^"]+)".*/\1/' || true)
if [ -n "$bundle_ver" ] && [ "$bundle_ver" != "$new_ver" ]; then
  echo "::warning::bundle version ($bundle_ver) differs from YAML version ($new_ver), using bundle version"
  new_ver="$bundle_ver"
fi

# --- 6. 改写 cask ---
sed -i.bak -E "s/version \"[^\"]+\"/version \"$new_ver\"/" "$CASK" && rm -f "$CASK.bak"
sed -i.bak -E "s|app \"[^\"]+\"|app \"$app_name\"|" "$CASK" && rm -f "$CASK.bak"

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
