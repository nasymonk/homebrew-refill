#!/usr/bin/env bash
# Bump the qoder-cn cask by detecting OSS ETag changes and extracting version from DMG.
# 上游只有无版本号 lastest 直链，以 HEAD 请求 OSS ETag 检测变更；
# 版本号取自 dmg 内 App Bundle 的 CFBundleShortVersionString（同 qoder 手法）。
set -euo pipefail

CASK="${1:-Casks/qoder-cn.rb}"

ARM_URL="https://ide.qoder.com.cn/qoder/release/lastest/QoderCN-darwin-arm64.dmg"
INTEL_URL="https://ide.qoder.com.cn/qoder/release/lastest/QoderCN-darwin-x64.dmg"

# --- 1. HEAD 双架构取变更信号 ---
# 优先取 etag;缺失时回退 content-md5(2026-08 起 ide.qoder.com.cn 经
# Tengine CDN 的部分边缘节点开始间歇性不返回 etag 头——本次 CI 报错根因)。
# 对 OSS Normal 对象 etag == content-md5 的 hex(已实测验证),base64 解码
# 转 hex 后与历史记录格式一致,可无缝比较。
# curl -fsSI:失败(超时/5xx)时返回非零;grep 未命中也返回非零,
# 统一 || true 兜住,让失败走到下面的报错分支打印原因,
# 而不是被 set -e 静默吞掉(此前偶发失败只留下 exit code 1,无法定位)。
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

# --- 4. 下载双架构 dmg、提取版本、计算 sha ---
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "ETags changed, downloading arm dmg (~200MB)..."
curl -fsSL --retry 2 --retry-delay 10 --max-time 300 -o "$tmp/arm.dmg" "$ARM_URL"
echo "downloading intel dmg (~200MB)..."
curl -fsSL --retry 2 --retry-delay 10 --max-time 300 -o "$tmp/intel.dmg" "$INTEL_URL"

# 挂载 ARM dmg 提取版本号
if ! vol_path=$(hdiutil attach "$tmp/arm.dmg" -nobrowse -readonly -mountrandom "$tmp" | awk 'END{print $NF}'); then
  echo "failed to mount arm dmg" >&2
  exit 1
fi
app_path=$(echo "$vol_path"/*.app | head -1)
new_ver=$(plutil -p "$app_path/Contents/Info.plist" 2>/dev/null | grep CFBundleShortVersionString | sed -E 's/.*"([^"]+)".*/\1/')
hdiutil detach "$vol_path" -force >/dev/null 2>&1 || true

if [ -z "$new_ver" ]; then
  echo "failed to extract version from app bundle ($app_path)" >&2
  exit 1
fi

arm_sha=$(shasum -a 256 "$tmp/arm.dmg" | cut -d' ' -f1)
intel_sha=$(shasum -a 256 "$tmp/intel.dmg" | cut -d' ' -f1)

cur_ver=$(grep -m1 'version "' "$CASK" | sed -E 's/.*version "([^"]+)".*/\1/')

# --- 5. 改写 cask ---

# version
sed -i.bak -E "s/version \"[^\"]+\"/version \"$new_ver\"/" "$CASK" && rm -f "$CASK.bak"

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

echo "bumped $cur_ver -> $new_ver"
echo "arm_sha=$arm_sha"
echo "intel_sha=$intel_sha"
echo "arm_etag=$arm_etag"
echo "intel_etag=$intel_etag"
