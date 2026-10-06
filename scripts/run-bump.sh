#!/usr/bin/env bash
# 运行单个 cask 的 bump 脚本并记录结果，自身永不失败（退出码恒为 0）。
# 故障隔离仍由它提供，但失败不再静默：结果写进 $BUMP_SUMMARY 表格，
# 由 finish-bump.sh 汇总并让整个 job 变红。
# 用法: scripts/run-bump.sh <cask 名> <命令...>
set -uo pipefail

name="${1:?用法: run-bump.sh <cask 名> <命令...>}"
shift

summary="${BUMP_SUMMARY:-${RUNNER_TEMP:-/tmp}/bump-summary.md}"
mkdir -p "$(dirname "$summary")"

log=$(mktemp)
trap 'rm -f "$log"' EXIT
if "$@" >"$log" 2>&1; then
  status=0
else
  status=$?
fi
cat "$log"

# 取脚本自己的结论行，方便在汇总表里一眼看出是"已最新"还是"升级了"
detail=$(grep -m1 -E '^bumped |already up-to-date|^::warning::' "$log" || true)
[ -n "$detail" ] || detail=$(grep -v '^[[:space:]]*$' "$log" | tail -1)
[ -n "$detail" ] || detail="(无输出, exit=$status)"

if [ "$status" -eq 0 ]; then mark="ok"; else mark="FAIL(exit $status)"; fi
printf '| %s | %s | %s |\n' "$name" "$mark" "${detail//|/\\|}" >> "$summary"

if [ "$status" -ne 0 ]; then
  echo "::error::$name bump 失败 (exit $status)，该 cask 可能已停止跟踪上游"
fi
exit 0
