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
cur_url=$(grep -m1 'url "' "$CASK" 2>/dev/null | sed -E 's/.*url "([^"]+)".*/\1/' || true)

if [ "$cur_url" = "$new_url" ] && [ -n "$cur_ver" ]; then
  echo "already up-to-date ($cur_ver, url unchanged)"
  exit 0
fi

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

sha=$(shasum -a 256 "$tmp/app.dmg" | cut -d' ' -f1)

sed -i.bak -E \
  -e "s|version \"[^\"]+\"|version \"$new_ver\"|" \
  -e "s|sha256 \"[^\"]+\"|sha256 \"$sha\"|" \
  -e "s|url \"https://[^\"]+\"|url \"$new_url\"|" \
  "$CASK" && rm -f "$CASK.bak"

echo "bumped ${cur_ver:-none} -> $new_ver"
echo "url=$new_url"
echo "sha256=$sha"
