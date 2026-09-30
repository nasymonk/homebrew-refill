#!/usr/bin/env bash
# Bump the deepseek-harness cask via 官方 electron-builder YAML 巡检。
# 官方 nightly-mac.yml 提供了最新版本号与 macOS Apple Silicon 版 zip 下载直链。
set -euo pipefail

CASK="${1:-Casks/deepseek-harness.rb}"
FEED="https://download.deepseek.com/dsh-desk/feeds/mac-arm64/nightly-mac.yml"

yml=$(curl -fsSL --retry 3 --retry-delay 5 --max-time 30 "$FEED")

parsed=$(python3 -c '
import sys, re

content = sys.stdin.read()
ver_m = re.search(r"^version:\s*(.+)$", content, re.MULTILINE)
url_m = re.search(r"(https://download\.deepseek\.com/[^\s\n]+\.zip)", content)

if not ver_m:
    sys.exit("failed to find version in feed")

ver = ver_m.group(1).strip().strip("\"'\''")
url = url_m.group(1).strip() if url_m else f"https://download.deepseek.com/dsh-desk/bin/mac-arm64/deepseek-harness-{ver}-mac-arm64.zip"

print(ver)
print(url)
' <<<"$yml")

new_ver=$(head -1 <<<"$parsed")
new_url=$(tail -1 <<<"$parsed")

if [ -z "$new_ver" ] || [ -z "$new_url" ]; then
  echo "failed to parse deepseek-harness feed" >&2
  exit 1
fi

cur_ver=$(grep -m1 'version "' "$CASK" | sed -E 's/.*version "([^"]+)".*/\1/')

if [ "$cur_ver" = "$new_ver" ]; then
  echo "already up-to-date ($cur_ver)"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "downloading $new_url for verification..."
curl -fsSL --retry 2 --max-time 900 -o "$tmp/app.zip" "$new_url"
sha=$(shasum -a 256 "$tmp/app.zip" | cut -d' ' -f1)

sed -i.bak -E \
  -e "s|version \"[^\"]+\"|version \"$new_ver\"|" \
  -e "s|sha256 \"[^\"]+\"|sha256 \"$sha\"|" \
  "$CASK" && rm -f "$CASK.bak"

echo "bumped $cur_ver -> $new_ver"
echo "url=$new_url"
echo "sha256=$sha"
