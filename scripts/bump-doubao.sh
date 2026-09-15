#!/usr/bin/env bash
# Bump the doubao cask（豆包电脑版）到上游最新版。
#
# 为什么不直接指向官方 DMG：官方 DMG 外层未签名，macOS 26/27 上 Homebrew
# 挂载/暂存它会失败（hdiutil 弹“磁盘映像可能有问题”或只读卷报错）。故把 App
# 重打成 zip（Homebrew 解 zip 走 ditto，完全不碰 hdiutil），托管到自有 ACS。
#
# 运行环境：设计为在 macOS 上执行（依赖 hdiutil/mount_hfs/ditto/codesign/spctl）。
#   · GitHub Actions 的 macos runner 每小时跑本脚本（见 .github/workflows/autobump.yml），
#     用存在 Secret 里的 SSH 密钥把 zip 传到 ACS；
#   · 也可在本机手动跑（用 ~/.ssh/config 里的 acs 别名）。
#
# 流程：分发接口取版本 → 下载 universal DMG → 无交互挂载（兼容旧/新 macOS）→
#       取 Doubao.app 校验签名/公证 → ditto 打 zip 并解压回验 → 上传 ACS 并核对 sha →
#       清理 ACS 旧包 → 改写 cask version/sha256。
# 提交/推送由 CI 的统一步骤完成（本脚本默认只在本机手动时才自行 commit）。
# App 本体 auto_updates 会自行更新，本脚本只保证 cask 与 ACS 备份同步到最新，
# 不强制重装、不打断正在运行的 App。
#
# 用法: scripts/bump-doubao.sh [Casks/doubao.rb]
# 环境变量:
#   ACS_HOST     SSH 目标（本机默认 acs 别名；CI 传 root@host）
#   ACS_DIR      服务器目录（默认 /srv/refill/doubao）
#   KEEP         ACS 上保留的历史 zip 个数（默认 2）
#   NO_COMMIT=1  只改文件，不 git commit/push（CI 统一提交时必传）
set -euo pipefail

CASK="${1:-Casks/doubao.rb}"
ACS_HOST="${ACS_HOST:-acs}"
ACS_DIR="${ACS_DIR:-/srv/refill/doubao}"
KEEP="${KEEP:-2}"
API="https://www.doubao.com/service/settings/v3/?device_platform=web&brand=doubao&aid=582465"
APP_NAME="Doubao.app"
ZIP_PREFIX="Doubao_universal"
mnt=""; dev=""

[ -f "$CASK" ] || { echo "cask not found: $CASK（请在 tap 根目录运行）" >&2; exit 1; }

tmp=$(mktemp -d)

# 无交互挂载 DMG，成功后把挂载点写入全局变量 mnt、设备写入 dev。
# 方法一：常规 hdiutil attach（CI 的 macOS、以及签名正常的镜像走这里）。
# 方法二：macOS 26/27 未签名镜像被拦时，先 -nomount 附加再用 mount_hfs 只读挂载。
mount_dmg() {
  local dmg="$1" out att
  if out=$(hdiutil attach -nobrowse -readonly -mountrandom "$tmp" "$dmg" 2>/dev/null); then
    mnt=$(echo "$out" | awk 'END{print $NF}')
    # 记录整盘设备节点，便于 cleanup 完整 detach（否则只卸载卷、镜像仍附加）
    dev=$(printf '%s\n' "$out" | awk '/GUID_partition_scheme/{print $1; exit}')
    [ -z "$dev" ] && dev=$(printf '%s\n' "$out" | awk '/\/dev\/disk/{print $1; exit}')
    [ -d "$mnt/$APP_NAME" ] && return 0
  fi
  echo "常规挂载失败，改用 -nomount + mount_hfs 回退方案" >&2
  att=$(hdiutil attach -nomount -readonly -noverify "$dmg" 2>/dev/null)
  dev=$(awk '/Apple_HFS/{print $1; exit}' <<<"$att")
  [ -n "$dev" ] || { echo "DMG 附加失败: $att" >&2; return 1; }
  mnt="$tmp/mnt"; mkdir -p "$mnt"
  /sbin/mount_hfs -o rdonly "$dev" "$mnt"
}

cleanup() {
  [ -n "$mnt" ] && /sbin/umount "$mnt" >/dev/null 2>&1 || true
  [ -n "$dev" ] && hdiutil detach "$dev" -force >/dev/null 2>&1 || true
  rm -rf "$tmp"
}
trap cleanup EXIT

# --- 1. 官方分发接口：最新版本 + universal DMG 地址 ---
info=$(curl -fsSL --retry 3 --max-time 30 "$API")
parsed=$(python3 -c 'import json,sys
d=json.load(sys.stdin)
u=d["data"]["settings"]["saman_update_address"]
print(u["version"], u.get("mac_url") or u.get("mac_arm_url"))' <<<"$info")
new=$(awk '{print $1}' <<<"$parsed")
dmg_url=$(awk '{print $2}' <<<"$parsed")
cur=$(grep -m1 'version "' "$CASK" | sed -E 's/.*version "([^"]+)".*/\1/')

if [ -z "$new" ] || [ -z "$dmg_url" ]; then
  echo "无法从分发接口解析版本/下载地址: $parsed" >&2; exit 1
fi
if [ "$cur" = "$new" ]; then echo "already up-to-date ($cur)"; exit 0; fi
echo "new version: $cur -> $new"; echo "dmg url: $dmg_url"

# --- 2. 下载 DMG ---
curl -fSL --retry 3 --max-time 900 -o "$tmp/app.dmg" "$dmg_url"

# --- 3. 无交互挂载 ---
mount_dmg "$tmp/app.dmg"
app="$mnt/$APP_NAME"

bundle_ver=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Contents/Info.plist")
if [ "$bundle_ver" != "$new" ]; then
  echo "::warning::接口版本 $new 与 DMG 内 App 版本 $bundle_ver 不一致" >&2
fi

# --- 4. 安全校验：签名有效且通过 Gatekeeper（公证） ---
codesign --verify --deep --strict "$app"
spctl -a -t execute "$app" >/dev/null

# --- 5. 取出 App、卸载镜像、ditto 打 zip（剔除 .DS_Store） ---
ditto "$app" "$tmp/$APP_NAME"
find "$tmp/$APP_NAME" -name '.DS_Store' -delete
/sbin/umount "$mnt" >/dev/null 2>&1 || hdiutil detach "$mnt" -force >/dev/null 2>&1
[ -n "$dev" ] && { hdiutil detach "$dev" -force >/dev/null 2>&1 || true; dev=""; }
mnt=""
( cd "$tmp" && ditto -c -k --keepParent "$APP_NAME" "$ZIP_PREFIX_$new.zip" )
zip="$tmp/$ZIP_PREFIX_$new.zip"

# 解压回验，确保 zip 内 App 签名仍有效
mkdir -p "$tmp/verify"
ditto -xk "$zip" "$tmp/verify"
codesign --verify --deep --strict "$tmp/verify/$APP_NAME"
sha=$(shasum -a 256 "$zip" | cut -d' ' -f1)
echo "zip sha256=$sha"

# --- 6. 上传 ACS，远端 sha 必须一致；仅保留最近 KEEP 个历史包 ---
ssh "$ACS_HOST" "mkdir -p '$ACS_DIR'"
scp -q "$zip" "$ACS_HOST:$ACS_DIR/$ZIP_PREFIX_$new.zip"
remote_sha=$(ssh "$ACS_HOST" "shasum -a 256 '$ACS_DIR/$ZIP_PREFIX_$new.zip' | cut -d' ' -f1")
if [ "$remote_sha" != "$sha" ]; then
  echo "远端 sha 不一致（local=$sha remote=$remote_sha），已中止" >&2; exit 1
fi
echo "uploaded: $ACS_HOST:$ACS_DIR/$ZIP_PREFIX_$new.zip"
ssh "$ACS_HOST" "cd '$ACS_DIR' && ls -1t ${ZIP_PREFIX}_*.zip 2>/dev/null | tail -n +$((KEEP+1)) | xargs -r rm -f"

# --- 7. 改写 cask version / sha256（url 用 #{version} 插值，无需改） ---
sed -i.bak -E \
  -e "s/version \"[^\"]+\"/version \"$new\"/" \
  -e "s/sha256 \"[^\"]+\"/sha256 \"$sha\"/" \
  "$CASK" && rm -f "$CASK.bak"
echo "bumped $cur -> $new"

# --- 8. 本机手动运行时顺手提交；CI 用 NO_COMMIT=1 交给统一步骤 ---
if [ "${NO_COMMIT:-0}" != "1" ]; then
  git add "$CASK"
  if git diff --cached --quiet; then
    echo "no git change"
  else
    git config user.name >/dev/null 2>&1 || git config user.name "refill-autobump"
    git config user.email >/dev/null 2>&1 || git config user.email "refill-autobump@users.noreply.github.com"
    git commit -m "feat: 升级豆包 (doubao) 至 $new" >/dev/null
    if git push 2>/dev/null; then echo "committed & pushed"; else echo "已本地 commit（push 失败，可稍后手动 git push）" >&2; fi
  fi
fi
