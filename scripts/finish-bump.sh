#!/usr/bin/env bash
# 汇总 run-bump.sh 记录的各 cask 结果：写入 GitHub step summary，
# 任一 cask 失败则以非零退出，让本次 autobump 显示为红。
set -uo pipefail

summary="${BUMP_SUMMARY:-${RUNNER_TEMP:-/tmp}/bump-summary.md}"
out="${GITHUB_STEP_SUMMARY:-/dev/stdout}"

{
  echo "## autobump 结果"
  echo
  echo "| cask | 结果 | 详情 |"
  echo "|---|---|---|"
  if [ -s "$summary" ]; then
    cat "$summary"
  else
    echo "| (无) | FAIL | 没有任何 bump 记录，检查 workflow 步骤 |"
  fi
} >> "$out"

if [ ! -s "$summary" ] || grep -qE '\| FAIL' "$summary"; then
  echo "存在失败的 cask bump，详见 Job summary" >&2
  exit 1
fi

echo "全部 cask 与上游一致或已升级"
