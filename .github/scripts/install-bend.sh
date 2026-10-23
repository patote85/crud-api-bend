#!/bin/sh
set -eu

if [ -z "${BEND_VERSION:-}" ] || [ -z "${BEND_SHA256:-}" ]; then
  printf 'install-bend: set BEND_VERSION and BEND_SHA256\n' >&2
  exit 1
fi

case "$BEND_VERSION" in
  *[!0-9.]*)
    printf 'install-bend: BEND_VERSION must look like 2.0.37, got %s\n' "$BEND_VERSION" >&2
    exit 1
    ;;
esac

case "$BEND_SHA256" in
  *[!0-9a-f]*)
    printf 'install-bend: BEND_SHA256 must be 64 lowercase hex characters\n' >&2
    exit 1
    ;;
esac

if [ "${#BEND_SHA256}" -ne 64 ]; then
  printf 'install-bend: BEND_SHA256 must be 64 lowercase hex characters\n' >&2
  exit 1
fi

os=$(uname -s)
arch=$(uname -m)
if [ "$os" != "Linux" ] || { [ "$arch" != "x86_64" ] && [ "$arch" != "amd64" ]; }; then
  printf 'install-bend: pinned artifact is linux-x64; this host is %s %s\n' "$os" "$arch" >&2
  exit 1
fi

name="bend-${BEND_VERSION}-linux-x64.tar.gz"
url="https://github.com/bendlang/bend/releases/download/v${BEND_VERSION}/${name}"
home=${BEND_HOME:-$HOME/.bend}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl --proto '=https' --tlsv1.2 -fsSL -o "$tmp/$name" "$url"
printf '%s  %s\n' "$BEND_SHA256" "$tmp/$name" | sha256sum -c -
tar --warning=no-unknown-keyword -xzf "$tmp/$name" -C "$tmp"
mkdir -p "$home/bin"
rm -rf "$home/bend2" "$home/guide"
mv "$tmp/bend/bend2" "$tmp/bend/guide" "$home/"
mv -f "$tmp/bend/bin/bend" "$home/bin/bend"
printf 'installed Bend %s at %s\n' "$BEND_VERSION" "$home/bin/bend"
