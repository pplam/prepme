#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Skills shipped by this repo. prepme generates the study sheet; anslog saves
# worked answers back into it.
SKILLS=( "prepme" "anslog" )

# Always install for Claude; also install for Codex if it's set up.
TARGETS=( "$HOME/.claude/skills" )
[[ -d "$HOME/.codex" ]] && TARGETS+=( "$HOME/.codex/skills" )

for skill in "${SKILLS[@]}"; do
  src="$SCRIPT_DIR/skills/$skill"
  if [[ ! -d "$src" ]]; then
    echo "Error: skill source not found at $src" >&2
    exit 1
  fi

  for target in "${TARGETS[@]}"; do
    dest="$target/$skill"
    mkdir -p "$target"

    if [[ -e "$dest" ]]; then
      echo "Removing existing $dest"
      rm -rf "$dest"
    fi
    echo "Installing to $dest"
    mkdir -p "$dest"
    cp -r "$src/SKILL.md" "$dest/"
    # Some skills ship data only and have no assets directory (e.g. anslog).
    [[ -d "$src/assets" ]] && cp -r "$src/assets" "$dest/"
  done
done

echo "Done."
