#!/usr/bin/env bash
# PreToolUse hook on Agent: keeps sub-agent launches quota-aware.
# Reads .claude/quota.json (written by quota-statusline.sh).
#   >= 90% of the 5-hour or >= 95% of the 7-day limit: deny the launch.
#   >= 70% of either: allow, but tell the model the current usage.
# Missing or stale (> 15 min) data: allow silently.
f="${CLAUDE_PROJECT_DIR:-.}/.claude/quota.json"
[ -f "$f" ] || exit 0
jq --argjson now "$(date +%s)" '
  (.five_hour.used_percentage // 0) as $h |
  (.seven_day.used_percentage // 0) as $w |
  "Usage: 5-hour \($h | floor)%, 7-day \($w | floor)%." as $msg |
  if ($now - (.updated_at // 0)) > 900 then empty
  elif $h >= 90 or $w >= 95 then
    {hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny",
      permissionDecisionReason: "\($msg) Quota nearly exhausted: do not launch sub-agents. Finish the current step in this context, commit, and tell the user what is left (see AGENTS.md, Quota)."}}
  elif $h >= 70 or $w >= 70 then
    {hookSpecificOutput: {hookEventName: "PreToolUse",
      additionalContext: "\($msg) Quota is getting tight: launch only the sub-agents that are essential and keep their briefs narrow (see AGENTS.md, Quota)."}}
  else empty end' "$f"
