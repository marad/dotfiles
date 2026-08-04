#!/bin/bash
# Statusline: context window usage, e.g. "24.6k (5%)".
# Input: Claude Code statusline JSON on stdin (.context_window).

OUT=$(jq -r '
  (.context_window // {}) as $c
  | (($c.total_input_tokens // 0) + ($c.total_output_tokens // 0)) as $t
  | ($c.used_percentage // 0) as $p
  | if $t == 0 then ""
    else (if $t < 1000 then ($t | tostring)
          else (($t / 100 | round) / 10 | tostring) + "k" end)
         + " (" + ($p | round | tostring) + "%)"
    end
')

[ -n "$OUT" ] && printf '\033[38;5;172m%s\033[0m' "$OUT"
exit 0
