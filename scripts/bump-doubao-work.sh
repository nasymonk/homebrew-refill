#!/usr/bin/env bash
# Bump the doubao-work cask by querying the official ByteDance link dispatcher API.
set -euo pipefail

CASK="${1:-Casks/doubao-work.rb}"

# Request the latest macOS download link from official landpage dispatcher
api_res=$(curl -fsSL -X POST "https://99uri.com/ug/pc/landpage_click" \
  -H "Content-Type: application/json" \
  -d '{"type":1,"os":"mac","content":"{\"web_url\":\"https%3A%2F%2Fwww.doubao.com%2Fwork\",\"surl_token\":\"NW5Kp\"}"}' 2>/dev/null || true)

new_url_raw=$(grep -oE 'https://[^"'\''\\]+\.dmg' <<<"$api_res" | head -1 || true)

if [ -z "$new_url_raw" ]; then
  echo "failed to parse download URL from landpage dispatcher API" >&2
  exit 1
fi

# Clean up query params if present
new_url="${new_url_raw%%\?*}"

cur_ver=$(grep -m1 'version "' "$CASK" 2>/dev/null | sed -E 's/.*version "([^"]+)".*/\1/' || true)

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/app.dmg" "$new_url"

# Extract real version from Info.plist
vol_path=$(hdiutil attach "$tmp/app.dmg" -nobrowse -readonly -mountrandom "$tmp" | awk 'END{print $NF}')
app_path=$(echo "$vol_path"/*.app | head -1)
new_ver=$(plutil -p "$app_path/Contents/Info.plist" 2>/dev/null | grep CFBundleShortVersionString | sed -E 's/.*"([^"]+)".*/\1/')
hdiutil detach "$vol_path" -force >/dev/null 2>&1 || true

if [ -z "$new_ver" ]; then
  echo "failed to extract version from app bundle" >&2
  exit 1
fi

if [ "$cur_ver" = "$new_ver" ]; then
  echo "already up-to-date ($cur_ver)"
  exit 0
fi

# Fetch official CDN checksums for both architectures
arm_url="https://lf-flow-web-cdn.doubao.com/obj/flow-doubao/doubao_pc/${new_ver}/DoubaoWork_Arm64_${new_ver}.dmg"
intel_url="https://lf-flow-web-cdn.doubao.com/obj/flow-doubao/doubao_pc/${new_ver}/DoubaoWork_X64_${new_ver}.dmg"

echo "calculating checksums for $new_ver..."
sha_arm=$(curl -fsSL "$arm_url" | shasum -a 256 | cut -d' ' -f1)
sha_intel=$(curl -fsSL "$intel_url" | shasum -a 256 | cut -d' ' -f1)

if [ -z "$sha_arm" ] || [ -z "$sha_intel" ]; then
  echo "failed to compute sha256 for CDN artifacts" >&2
  exit 1
fi

python3 -c '
import sys, re
cask_file = sys.argv[1]
new_ver = sys.argv[2]
sha_arm = sys.argv[3]
sha_intel = sys.argv[4]

with open(cask_file, "r", encoding="utf-8") as f:
    content = f.read()

content = re.sub(r'\''version "[^"]+"\'', f'\''version "{new_ver}"\'', content)
content = re.sub(r'\''sha256 arm:\s*"[^"]+",\s*intel:\s*"[^"]+"\'', f'\''sha256 arm:   "{sha_arm}",\n         intel: "{sha_intel}"\'', content)

with open(cask_file, "w", encoding="utf-8") as f:
    f.write(content)
' "$CASK" "$new_ver" "$sha_arm" "$sha_intel"

echo "bumped ${cur_ver:-none} -> $new_ver"
echo "sha256_arm=$sha_arm"
echo "sha256_intel=$sha_intel"
