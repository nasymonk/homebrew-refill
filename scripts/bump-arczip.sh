#!/usr/bin/env bash
# Bump the arczip cask from its Sparkle appcast.
# appcast 的 enclosure 即官方 zip（根级 ArcZip.app），cask url 直接指向它，
# 无需像 iqiyi 那样重打镜像。逻辑与 bump-buhocleaner.sh 同源。
set -euo pipefail

CASK="${1:-Casks/arczip.rb}"
FEED="https://download.arczip.app/appcast.xml"

xml=$(curl -fsSL "$FEED")

# 以 item 为单位解析，保证版本号与 zip 地址取自同一条发布记录。
# 多个 item 时按 Sparkle 语义取 sparkle:version(构建号)最大者，构建号相同或缺失时退回短版本号数值比较。
parsed=$(python3 -c '
import re, sys

xml = sys.stdin.read()

def find_field(item, name):
    # ArcZip 的 appcast 把 sparkle:version / sparkle:shortVersionString 放成 <item> 的
    # 子元素（<sparkle:version>232</sparkle:version>），而非常见的 enclosure 属性；
    # 这里两种写法都兼容。
    m = re.search(r"<" + name + r">([^<]+)</" + name + r">", item)
    if m:
        return m.group(1).strip()
    m = re.search(name + r"=\"([^\"]+)\"", item)
    return m.group(1) if m else None

cands = []
for item in re.findall(r"<item>.*?</item>", xml, re.S):
    enc = re.search(r"<enclosure\b[^>]*>", item)
    if not enc:
        continue
    url = re.search(r"url=\"([^\"]+)\"", enc.group(0))
    ver = find_field(item, "sparkle:shortVersionString")
    build = find_field(item, "sparkle:version")
    if not (url and ver):
        continue
    num = int(build) if build and build.isdigit() else -1
    parts = tuple(int(p) for p in re.findall(r"\d+", ver))
    cands.append((num, parts, ver, url.group(1)))

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
curl -fsSL -o "$tmp/app.zip" "$new_url"
sha=$(shasum -a 256 "$tmp/app.zip" | cut -d' ' -f1)

# 只改写顶层下载 stanza（两空格缩进 ^  url），livecheck 的 url 缩进更深不受影响。
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
