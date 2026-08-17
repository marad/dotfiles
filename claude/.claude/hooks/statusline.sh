#!/bin/bash
# Statusline: model, context usage, git branch, folder.
# e.g. "Opus 5 | 24.6k (5%) | transfer | notes"
# Input: Claude Code statusline JSON on stdin.

INPUT=$(cat)

# One jq call, one line per field; blank lines keep the field order intact.
{ read -r MODEL; read -r CTX; read -r DIR; } <<EOF
$(printf '%s' "$INPUT" | jq -r '
  (.model.display_name // .model.id // ""),
  ( (.context_window // {}) as $c
    | (($c.total_input_tokens // 0) + ($c.total_output_tokens // 0)) as $t
    | ($c.used_percentage // 0) as $p
    | if $t == 0 then ""
      else (if $t < 1000 then ($t | tostring)
            else (($t / 100 | round) / 10 | tostring) + "k" end)
           + " (" + ($p | round | tostring) + "%)"
      end ),
  (.workspace.current_dir // .cwd // "")
')
EOF

# Reads .git instead of running git: the statusline runs on every render and
# each exec pays the EDR inspection tax on this machine.
git_branch() {
  local dir=$1 gitdir="" head ref
  while [ -n "$dir" ] && [ "$dir" != "/" ]; do
    if [ -d "$dir/.git" ]; then
      gitdir="$dir/.git"
      break
    elif [ -f "$dir/.git" ]; then
      read -r _ gitdir <"$dir/.git"
      case $gitdir in
        /*) ;;
        *) gitdir="$dir/$gitdir" ;;
      esac
      break
    fi
    dir=${dir%/*}
  done
  [ -n "$gitdir" ] && [ -f "$gitdir/HEAD" ] || return
  read -r head <"$gitdir/HEAD"
  case $head in
    ref:*)
      ref=${head#ref: }
      printf '%s' "${ref#refs/heads/}"
      ;;
    *) printf '%s' "${head:0:7}" ;;
  esac
}

BRANCH=""
FOLDER=""
if [ -n "$DIR" ]; then
  BRANCH=$(git_branch "$DIR")
  FOLDER=${DIR##*/}
fi

OUT=""
add() {
  [ -n "$2" ] || return
  [ -n "$OUT" ] && OUT="$OUT$(printf '\033[38;5;240m | \033[0m')"
  OUT="$OUT$(printf '\033[38;5;%sm%s\033[0m' "$1" "$2")"
}

add 110 "$MODEL"
add 172 "$CTX"
add 114 "$BRANCH"
add 245 "$FOLDER"

[ -n "$OUT" ] && printf '%s' "$OUT"
exit 0
