#!/usr/bin/env bash
# Status line that also records subscription usage for agents.
# Claude Code pipes session JSON on stdin; we persist .rate_limits to
# .claude/quota.json (gitignored) so the orchestrator, sub-agents and the
# quota-guard hook can read it. Prints: model | ctx % | 5h % | 7d %.
input=$(cat)
dir=$(jq -r '.workspace.project_dir // .cwd // empty' <<<"$input")
dir=${dir:-${CLAUDE_PROJECT_DIR:-.}}
if jq -e '.rate_limits' >/dev/null 2>&1 <<<"$input"; then
  tmp=$(mktemp "$dir/.claude/.quota.XXXXXX") &&
    jq --argjson now "$(date +%s)" '.rate_limits + {updated_at: $now}' <<<"$input" >"$tmp" &&
    mv "$tmp" "$dir/.claude/quota.json"
fi
jq -r '[
  (.model.display_name // "?"),
  ("ctx " + ((.context_window.used_percentage // 0) | floor | tostring) + "%"),
  (if .rate_limits.five_hour then "5h " + (.rate_limits.five_hour.used_percentage | floor | tostring) + "%" else empty end),
  (if .rate_limits.seven_day then "7d " + (.rate_limits.seven_day.used_percentage | floor | tostring) + "%" else empty end)
] | join(" | ")' <<<"$input"
