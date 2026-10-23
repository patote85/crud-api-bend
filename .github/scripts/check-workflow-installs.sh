#!/bin/sh
set -eu

dir=${1:-.github/workflows}

if [ ! -d "$dir" ]; then
  printf 'check-workflow-installs: no workflow directory: %s\n' "$dir" >&2
  exit 2
fi

found=0
set -- "$dir"/*.yml "$dir"/*.yaml
for file in "$@"; do
  if [ ! -f "$file" ]; then
    continue
  fi
  if ! awk '
    function is_yaml_block(line) {
      return line ~ /:[[:space:]]*\|[-+]?[[:space:]]*$/
    }
    function flush(line, lineno) {
      if (line ~ /^[[:space:]]*#/) {
        return
      }
      pipe = line ~ /(^|[^A-Za-z0-9_])(curl|wget)([^A-Za-z0-9_][^|]*)?(\|[^|]*)*\|[[:space:]]*(sudo[[:space:]]+)?((\/usr)?\/bin\/)?(bash|sh)([^A-Za-z0-9_]|$)/
      subst = line ~ /(^|[^A-Za-z0-9_])(sudo[[:space:]]+)?((\/usr)?\/bin\/)?(bash|sh)[[:space:]]*<\([[:space:]]*(curl|wget)([^A-Za-z0-9_]|$)/
      if (pipe || subst) {
        printf "%s:%d: unpinned download-to-shell install: %s\n", FILENAME, lineno, line
        found = 1
      }
    }
    BEGIN { found = 0 }
    {
      sub(/\r$/, "")
      if (buf == "") {
        start = NR
      }
      if ($0 ~ /\\[[:space:]]*$/) {
        line = $0
        sub(/\\[[:space:]]*$/, "", line)
        buf = buf line
        next
      }
      if ($0 ~ /\|[[:space:]]*$/ && !is_yaml_block($0)) {
        buf = buf $0
        next
      }
      if ($0 ~ /<\([[:space:]]*$/) {
        buf = buf $0
        next
      }
      flush(buf $0, start)
      buf = ""
    }
    END {
      if (buf != "") {
        flush(buf, start)
      }
      exit found
    }
  ' "$file"; then
    found=1
  fi
done

if [ "$found" -ne 0 ]; then
  exit 1
fi

printf 'check-workflow-installs: no unpinned download-to-shell install in %s\n' "$dir"
