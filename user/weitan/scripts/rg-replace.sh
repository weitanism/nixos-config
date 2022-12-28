#!/usr/bin/env cached-nix-shell
#! nix-shell -i bash -p moreutils -p ripgrep

MTIME=${MTIME:-""}

set -o errexit -o pipefail

if [ "$#" -eq 0 ]; then
  echo "usage: $0 PATTERN REPLACEMENT [PATH...]" >/dev/stderr
  exit 1
fi

pattern="$1"
replacement="$2"
shift 2

paths=("$@")

rg --multiline -l "$pattern" "${paths[@]}" | while IFS=$'\n' read -r file; do
  rg --multiline --passthru "$pattern" --replace "$replacement" "$file" | sponge "$file"
  if [[ -n $MTIME ]]; then
    touch -m -t "$MTIME" "$file"
  fi
done
