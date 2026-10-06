#!/usr/bin/env bash
# Bump the buhocleaner cask from its Sparkle appcast.
set -euo pipefail

CASK="${1:-Casks/buhocleaner.rb}"
FEED="https://www.drbuho.com/buho-public-files/buhocleaner/appcast.xml"

xml=$(curl -fsSL "$FEED")

# 以 item 为单位解析，保证版本号与 dmg 地址取自同一条发布记录。
# 多个 item 时按 Sparkle 语义取 sparkle:version(构建号)最大者，构建号相同或缺失时退回短版本号数值比较。
parsed=$(python3 -c '
import re, sys

xml = sys.stdin.read()
cands = []
for item in re.findall(r"<item>.*?</item>", xml, re.S):
    enc = re.search(r"<enclosure\b[^>]*>", item)
    if not enc:
        continue
    tag = enc.group(0)
    url = re.search(r"url=\"([^\"]+)\"", tag)
    ver = re.search(r"sparkle:shortVersionString=\"([^\"]+)\"", tag)
    build = re.search(r"sparkle:version=\"([^\"]+)\"", tag)
    if not (url and ver):
        continue
    num = int(build.group(1)) if build and build.group(1).isdigit() else -1
    parts = tuple(int(p) for p in re.findall(r"\d+", ver.group(1)))
    cands.append((num, parts, ver.group(1), url.group(1)))

if not cands:
    sys.exit("no usable <item> with enclosure in appcast")

best = max(cands)
if len(cands) > 1:
    print("::warning::appcast 有 %d 个 item，取 b%s (%s)" % (len(cands), best[0], best[2]), file=sys.stderr)
print(best[2])
print(best[3])
' <<<"$xml")

new_ver=$(head -1 <<<"$parsed")
new_url=$(tail -1 <<<"$parsed")

if [ -z "$new_ver" ] || [ -z "$new_url" ]; then
  echo "failed to parse appcast (ver='$new_ver' url='$new_url')" >&2
  exit 1
fi

cur_ver=$(grep -m1 'version "' "$CASK" | sed -E 's/.*version "([^"]+)".*/\1/')
cur_url=$(grep -m1 'url "' "$CASK" | sed -E 's/.*url "([^"]+)".*/\1/')

if [ "$cur_ver" = "$new_ver" ] && [ "$cur_url" = "$new_url" ]; then
  echo "already up-to-date ($cur_ver)"
  exit 0
fi

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/app.dmg" "$new_url"
sha=$(shasum -a 256 "$tmp/app.dmg" | cut -d' ' -f1)

# 只改写顶层下载 stanza（两空格缩进 ^  url），livecheck 的 url 缩进更深不受影响。
# 早先按 drbuho.net 字面匹配的正则与 cask 实际域名（pub-assets1.drbuho.com）不符，
# 会写入新 sha 却留下旧 url，导致安装校验失败。
if [[ "$new_url" == *"|"* ]]; then
  echo "url 含 sed 分隔符 '|'，需人工处理: $new_url" >&2
  exit 1
fi
url_repl=${new_url//&/\\&}

sed -i.bak -E \
  -e "s|^  version \"[^\"]+\"|  version \"$new_ver\"|" \
  -e "s|^  sha256 \"[^\"]+\"|  sha256 \"$sha\"|" \
  -e "s|^  url \"[^\"]+\"|  url \"$url_repl\"|" \
  "$CASK" && rm -f "$CASK.bak"

actual_url=$(grep -m1 '^  url "' "$CASK" | sed -E 's/^  url "([^"]+)".*/\1/')
if [ "$actual_url" != "$new_url" ]; then
  echo "下载 url 未改写成功 (期望 $new_url，实际 $actual_url)" >&2
  exit 1
fi

echo "bumped $cur_ver -> $new_ver"
echo "url=$new_url"
echo "sha256=$sha"
