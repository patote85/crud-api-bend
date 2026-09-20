#!/bin/sh
# Unit = LAWS/PROOF (type checker). Automated = this script + CI.
set -eu
export BEND_NO_TELEMETRY=1
BEND="${BEND:-bend}"
if ! command -v "$BEND" >/dev/null 2>&1; then
  if [ -x "$HOME/.bend/bin/bend" ]; then
    BEND="$HOME/.bend/bin/bend"
  else
    echo "bend not on PATH. curl -fsSL https://bend-lang.com/install.sh | sh" >&2
    exit 127
  fi
fi
cd "$(dirname "$0")"
echo "== PROOF (unit laws) =="
"$BEND" PROOF.bend
echo "== DEMO (in-process) =="
"$BEND" main.bend
echo "OK"
