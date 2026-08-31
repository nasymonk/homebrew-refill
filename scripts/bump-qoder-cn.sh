#!/usr/bin/env bash
# Bump the qoder-cn cask (Qoder CN 全新形态安装器, 0.1.x 版本线)。
# 上游只提供无版本号的 latest 直链，以 HEAD 请求 OSS ETag 检测变更；
# 版本号取自 zip 内 App Bundle 的 CFBundleShortVersionString。
# 注意：该 cask 与旧 "Qoder CN IDE"(1.2x, ide.qoder.com.cn dmg) 是不同产品。
set -euo pipefail

CASK="${1:-Casks/qoder-cn.rb}"

ARM_URL="https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/latest/Qoder-CN-Installer-mac-arm64.zip"
INTEL_URL="https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/latest/Qoder-CN-Installer-mac-x64.zip"

# --- 1. HEAD 双架构取变更信号 ---
# 优先取 etag；缺失时回退 content-md5（OSS Normal 对象 etag == content-md5 的 hex）。
# curl/grep 失败统一 || true 兜住，让失败走到下面的报错分支打印原因，
# 而不是被 set -e 静默吞掉。
fetch_etag() {
  local headers etag md5b64
  headers=$(curl -fsSI --retry 2 --retry-delay 5 --max-time 30 "$1" 2>/dev/null || true)
  etag=$(printf '%s\n' "$headers" | grep -i '^etag:' | tr -d '\r"' | sed 's/^[Ee][Tt]ag: *//' || true)
  if [ -n "$etag" ]; then
    printf '%s' "$etag"
    return 0
  fi
  md5b64=$(printf '%s\n' "$headers" | grep -i '^content-md5:' | tr -d '\r' | sed 's/^[Cc]ontent-[Mm][Dd]5: *//' || true)
  if [ -n "$md5b64" ]; then
    printf '%s' "$md5b64" | base64 -d 2>/dev/null | xxd -p -c 256 | tr '[:lower:]' '[:upper:]' || true
  fi
  return 0
}

arm_etag=$(fetch_etag "$ARM_URL")
intel_etag=$(fetch_etag "$INTEL_URL")

if [ -z "$arm_etag" ] || [ -z "$intel_etag" ]; then
  echo "failed to fetch ETag from upstream (arm='${arm_etag:-}' intel='${intel_etag:-}')" >&2
  exit 1
fi

# --- 2. 读取上一次 ETag ---
prev_etag_line=$(grep '^  # upstream-etag ' "$CASK" 2>/dev/null || true)
prev_arm=$(echo "$prev_etag_line" | grep -o 'arm=[^ ]*' | cut -d= -f2)
prev_intel=$(echo "$prev_etag_line" | grep -o 'x64=[^ ]*' | cut -d= -f2)

# --- 3. 均未变 → 跳过 ---
if [ "$arm_etag" = "$prev_arm" ] && [ "$intel_etag" = "$prev_intel" ]; then
  echo "already up-to-date (ETags unchanged)"
  exit 0
fi

# --- 4. 下载双架构 zip、提取版本、计算 sha ---
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "ETags changed, downloading arm zip (~230MB)..."
curl -fsSL --retry 2 --retry-delay 10 --max-time 600 -o "$tmp/arm.zip" "$ARM_URL"
echo "downloading intel zip (~260MB)..."
curl -fsSL --retry 2 --retry-delay 10 --max-time 600 -o "$tmp/intel.zip" "$INTEL_URL"

# 从 ARM zip 提取顶层 .app 名与版本号（以 App Bundle 为权威）
app_name=$(unzip -Z1 "$tmp/arm.zip" | grep -oE '^[^/]+\.app' | head -1 || true)
if [ -z "$app_name" ]; then
  echo "failed to locate .app inside arm zip" >&2
  exit 1
fi
unzip -o -q "$tmp/arm.zip" "$app_name/Contents/Info.plist" -d "$tmp"
new_ver=$(plutil -p "$tmp/$app_name/Contents/Info.plist" 2>/dev/null | grep CFBundleShortVersionString | sed -E 's/.*"([^"]+)".*/\1/' || true)
if [ -z "$new_ver" ]; then
  echo "failed to extract version from app bundle ($app_name)" >&2
  exit 1
fi

arm_sha=$(shasum -a 256 "$tmp/arm.zip" | cut -d' ' -f1)
intel_sha=$(shasum -a 256 "$tmp/intel.zip" | cut -d' ' -f1)

cur_ver=$(grep -m1 'version "' "$CASK" | sed -E 's/.*version "([^"]+)".*/\1/')

# 原地覆写通道可能渠道滞后：ETag 变了但包内版本未涨 → 只刷新 etag 注释行
if [ "$new_ver" = "$cur_ver" ]; then
  echo "::warning::ETags changed but bundle version unchanged ($cur_ver), refreshing etag marker only"
  sed -i.bak -E "s/^  # upstream-etag .*/  # upstream-etag arm=${arm_etag} x64=${intel_etag}/" "$CASK" && rm -f "$CASK.bak"
  exit 0
fi

# --- 5. 改写 cask ---

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

# upstream-etag 注释行
if grep -q '^  # upstream-etag ' "$CASK"; then
  sed -i.bak -E "s/^  # upstream-etag .*/  # upstream-etag arm=${arm_etag} x64=${intel_etag}/" "$CASK" && rm -f "$CASK.bak"
else
  # 兼容：首次运行 cask 中无 etag 行时插入
  awk -v arm="$arm_etag" -v intel="$intel_etag" '
    /^  version "/ && !done {
      print
      print "  # upstream-etag arm=" arm " x64=" intel
      done=1
      next
    }
    { print }
  ' "$CASK" > "$CASK.tmp" && mv "$CASK.tmp" "$CASK"
fi

echo "bumped $cur_ver -> $new_ver (app: $app_name)"
echo "arm_sha=$arm_sha"
echo "intel_sha=$intel_sha"
echo "arm_etag=$arm_etag"
echo "intel_etag=$intel_etag"
