#!/usr/bin/env bash
# Bump the iqiyi cask（爱奇艺 macOS 客户端）到上游最新版。
#
# 两个特殊性：
#  1) 下载地址固定（iQIYIMedia_271.dmg，271 为品牌谐音），官方原地覆写、URL 不随版本变，
#     页面“最新版本”文案也会滞后；因此以挂载 DMG 后 App Bundle 的
#     CFBundleShortVersionString 为权威版本（不信任页面文案）。
#  2) macOS 26/27 上 Homebrew 暂存只读 DMG 时会因清理 .DS_Store 报
#     “Read-only file system”而安装失败，故与豆包一样：挂载取出 .app 后重打成 zip
#     （Homebrew 解 zip 走 ditto，不碰 hdiutil），托管到自有 ACS。
#
# 运行在 macOS（GitHub Actions macos runner 每小时，或本机手动）。
# 用法: scripts/bump-iqiyi.sh [Casks/iqiyi.rb]
# 环境变量: ACS_HOST（默认 acs）、ACS_DIR（默认 /srv/refill/iqiyi）、KEEP（默认 2）、
#           NO_COMMIT=1（CI 统一提交时必传）
set -euo pipefail

CASK="${1:-Casks/iqiyi.rb}"
ACS_HOST="${ACS_HOST:-acs}"
ACS_DIR="${ACS_DIR:-/srv/refill/iqiyi}"
KEEP="${KEEP:-2}"
PAGE="https://app.iqiyi.com/mac/player/index.html"
FALLBACK_DMG="https://static-d.iqiyi.com/ext/common/iQIYIMedia_271.dmg"
APP_NAME="爱奇艺.app"
mnt=""; dev=""

[ -f "$CASK" ] || { echo "cask not found: $CASK（请在 tap 根目录运行）" >&2; exit 1; }
tmp=$(mktemp -d)

# 无交互挂载：先常规 hdiutil（CI/签名正常镜像），失败再 -nomount + mount_hfs/mount_apfs（macOS 27）
mount_dmg() {
  local dmg="$1" out att fs
  if out=$(hdiutil attach -nobrowse -readonly -mountrandom "$tmp" "$dmg" 2>/dev/null); then
    mnt=$(echo "$out" | awk 'END{print $NF}')
    # 记录整盘设备节点，便于 cleanup 完整 detach（否则只卸载卷、镜像仍附加）
    dev=$(printf '%s\n' "$out" | awk '/GUID_partition_scheme/{print $1; exit}')
    [ -z "$dev" ] && dev=$(printf '%s\n' "$out" | awk '/\/dev\/disk/{print $1; exit}')
    compgen -G "$mnt"/*.app >/dev/null 2>&1 && return 0
  fi
  echo "常规挂载失败，改用 -nomount 回退方案" >&2
  att=$(hdiutil attach -nomount -readonly -noverify "$dmg" 2>/dev/null)
  dev=$(awk '/Apple_(HFS|APFS)/{print $1; exit}' <<<"$att")
  fs=$(awk '/Apple_(HFS|APFS)/{if($0 ~ /Apple_HFS/) print "hfs"; else print "apfs"; exit}' <<<"$att")
  [ -n "$dev" ] || { echo "DMG 附加失败: $att" >&2; return 1; }
  mnt="$tmp/mnt"; mkdir -p "$mnt"
  if [ "$fs" = "hfs" ]; then /sbin/mount_hfs -o rdonly "$dev" "$mnt"; else /sbin/mount_apfs -o rdonly "$dev" "$mnt"; fi
}

cleanup() {
  [ -n "$mnt" ] && /sbin/umount "$mnt" >/dev/null 2>&1 || true
  [ -n "$dev" ] && hdiutil detach "$dev" -force >/dev/null 2>&1 || true
  rm -rf "$tmp"
}
trap cleanup EXIT

# --- 1. 解析 DMG 地址（页面结构变化时回退到固定地址） ---
html=$(curl -fsSL --retry 3 "$PAGE" || true)
dmg_url=$(grep -oE 'https://static-d\.iqiyi\.com/ext/common/iQIYIMedia_[0-9]+\.dmg' <<<"$html" | head -1 || true)
[ -n "$dmg_url" ] || dmg_url="$FALLBACK_DMG"

cur=$(grep -m1 'version "' "$CASK" | sed -E 's/.*version "([^"]+)".*/\1/')

# --- 2. 下载并挂载，读权威版本 ---
curl -fSL --retry 3 --max-time 600 -o "$tmp/app.dmg" "$dmg_url"
mount_dmg "$tmp/app.dmg"
app_path=$(find "$mnt" -maxdepth 1 -name '*.app' | head -1)
new_ver=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app_path/Contents/Info.plist")
[ -n "$new_ver" ] || { echo "无法从 App Bundle 读取版本" >&2; exit 1; }

ver_key() { awk -F. '{printf "%05d%05d%05d%05d", $1,$2,$3,$4}' <<<"$1"; }
if [ "$(ver_key "$new_ver")" -le "$(ver_key "$cur")" ]; then
  echo "already up-to-date (cask=$cur, dmg=$new_ver)"; exit 0
fi
echo "new version: $cur -> $new_ver"

# --- 3. 安全校验 ---
codesign --verify --deep --strict "$app_path"
spctl -a -t execute "$app_path" >/dev/null

# --- 4. 取出 App、卸载、ditto 打 zip（去 .DS_Store），并解压回验 ---
ditto "$app_path" "$tmp/$APP_NAME"
find "$tmp/$APP_NAME" -name '.DS_Store' -delete
/sbin/umount "$mnt" >/dev/null 2>&1 || hdiutil detach "$mnt" -force >/dev/null 2>&1
[ -n "$dev" ] && { hdiutil detach "$dev" -force >/dev/null 2>&1 || true; dev=""; }
mnt=""
zip_name="iQIYI_$new_ver.zip"
( cd "$tmp" && ditto -c -k --keepParent "$APP_NAME" "$zip_name" )
mkdir -p "$tmp/verify"; ditto -xk "$tmp/$zip_name" "$tmp/verify"
codesign --verify --deep --strict "$tmp/verify/$APP_NAME"
sha=$(shasum -a 256 "$tmp/$zip_name" | cut -d' ' -f1)
echo "zip sha256=$sha"

# --- 5. 上传 ACS、核对 sha、保留最近 KEEP 个 ---
ssh "$ACS_HOST" "mkdir -p '$ACS_DIR'"
scp -q "$tmp/$zip_name" "$ACS_HOST:$ACS_DIR/$zip_name"
remote_sha=$(ssh "$ACS_HOST" "shasum -a 256 '$ACS_DIR/$zip_name' | cut -d' ' -f1")
if [ "$remote_sha" != "$sha" ]; then
  echo "远端 sha 不一致（local=$sha remote=$remote_sha），已中止" >&2; exit 1
fi
echo "uploaded: $ACS_HOST:$ACS_DIR/$zip_name"
ssh "$ACS_HOST" "cd '$ACS_DIR' && ls -1t iQIYI_*.zip 2>/dev/null | tail -n +$((KEEP+1)) | xargs -r rm -f"

# --- 6. 改写 cask version / sha256（url 为 #{version} 插值，无需改） ---
sed -i.bak -E \
  -e "s/version \"[^\"]+\"/version \"$new_ver\"/" \
  -e "s/sha256 \"[^\"]+\"/sha256 \"$sha\"/" \
  "$CASK" && rm -f "$CASK.bak"
echo "bumped $cur -> $new_ver"

# --- 7. 本机手动时提交；CI 用 NO_COMMIT=1 交给统一步骤 ---
if [ "${NO_COMMIT:-0}" != "1" ]; then
  git add "$CASK"
  if git diff --cached --quiet; then echo "no git change"; else
    git config user.name >/dev/null 2>&1 || git config user.name "refill-autobump"
    git config user.email >/dev/null 2>&1 || git config user.email "refill-autobump@users.noreply.github.com"
    git commit -m "feat: 升级爱奇艺 (iqiyi) 至 $new_ver" >/dev/null
    git push 2>/dev/null && echo "committed & pushed" || echo "已本地 commit（push 失败可手动）" >&2
  fi
fi
