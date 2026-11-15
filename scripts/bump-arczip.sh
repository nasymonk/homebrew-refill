#!/usr/bin/env bash
# Bump the arczip cask from its Sparkle appcast.
# appcast 的 enclosure 即官方 zip（根级 ArcZip.app），cask url 直接指向它，
# 无需像 iqiyi 那样重打镜像。逻辑与 bump-buhocleaner.sh 同源。
#
# 上游 appcast 与安装包经 scripts/upstream.sh 走 ACS 国内出口：GitHub Actions
# 的境外 runner 直连 download.arczip.app 会被 Cloudflare 返回 403（2026-11 实测），
# 曾导致该 cask 自 2026-10-25 起连续 20+ 次巡检失败。
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/upstream.sh"

CASK="${1:-Casks/arczip.rb}"
FEED="https://download.arczip.app/appcast.xml"

xml=$(upstream_cat "$FEED")

# 以 item 为单位解析，保证版本号与 zip 地址取自同一条发布记录。
# 多个 item 时按 Sparkle 语义取 sparkle:version(构建号)最大者，构建号相同或缺失时退回短版本号数值比较。
parsed=$(python3 -c '
import re, sys

xml = sys.stdin.read()

def find_field(item, local):
    # 字段可能是 <item> 的子元素（<ver>232</ver>），也可能是 enclosure 属性；
    # 命名空间前缀由序列化器决定（sparkle: / ns0: / 无前缀，2026-10 上游由
    # sparkle: 切成 ns0:），因此只按本地名匹配，前缀可选。
    prefix = r"(?:\w+:)?"
    m = re.search(r"<" + prefix + re.escape(local) + r">([^<]+)</" + prefix + re.escape(local) + r">", item)
    if m:
        return m.group(1).strip()
    m = re.search(r"\s" + prefix + re.escape(local) + r"=\"([^\"]+)\"", item)
    return m.group(1) if m else None

cands = []
for item in re.findall(r"<item>.*?</item>", xml, re.S):
    enc = re.search(r"<enclosure\b[^>]*>", item)
    if not enc:
        continue
    url = re.search(r"url=\"([^\"]+)\"", enc.group(0))
    ver = find_field(item, "shortVersionString")
    build = find_field(item, "version")
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

# enclosure URL 来自上游 XML，写入 cask / 拼进远端 shell 前先钉死形态。
if [[ ! "$new_url" =~ ^https://download\.arczip\.app/releases/[0-9.]+/[0-9]+/ArcZip-[0-9.]+-[0-9]+\.zip$ ]]; then
  echo "appcast enclosure URL 形态异常，拒绝使用: $new_url" >&2
  exit 1
fi

cur_ver=$(grep -m1 'version "' "$CASK" | sed -E 's/.*version "([^"]+)".*/\1/')
cur_url=$(grep -m1 'url "' "$CASK" | sed -E 's/.*url "([^"]+)".*/\1/')

if [ "$cur_ver" = "$new_ver" ] && [ "$cur_url" = "$new_url" ]; then
  echo "already up-to-date ($cur_ver)"
  exit 0
fi

# 摘要由 ACS（或本机直连）下载官方 zip 后计算，大文件不回传 runner。
sha=$(upstream_sha256 "$new_url")

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
