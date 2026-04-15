#!/bin/sh

set -eu

cwd=${1:-$(pwd)}
home_dir=${HOME:?}

resolve_root() {
  dir=$1

  if git -C "$dir" rev-parse --show-toplevel >/dev/null 2>&1; then
    git -C "$dir" rev-parse --show-toplevel
    return
  fi

  current=$dir
  while [ "$current" != "/" ]; do
    if [ -f "$current/CLAUDE.md" ] || [ -e "$current/.claude.local.md" ]; then
      printf '%s\n' "$current"
      return
    fi
    current=$(dirname "$current")
  done

  printf '%s\n' "$dir"
}

root=$(resolve_root "$cwd")
project=$(basename "$root")
link_path="$root/.claude.local.md"
target_path="$home_dir/dev/agentbrain/projects/$project.md"

if [ -e "$link_path" ] || [ -L "$link_path" ]; then
  exit 0
fi

printf '⚠ Missing .claude.local.md for %s\n' "$root"
printf 'Create it with:\n'
printf 'ln -s "%s" "%s"\n' "$target_path" "$link_path"
