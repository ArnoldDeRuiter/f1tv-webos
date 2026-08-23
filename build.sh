#!/bin/sh
# Hand-rolled .ipk build (ar + tar), no ares-cli dependency. See
# webos-home-customizer/build.sh for the same pattern with more comments.
set -e
cd "$(dirname "$0")"

APP_ID="nl.arnolderuiter.f1tv"
VERSION="$(python3 -c "import json;print(json.load(open('appinfo.json'))['version'])")"
INSTALL_ROOT="media/developer/apps/usr/palm/applications/$APP_ID"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

DATA_DIR="$WORK/data/$INSTALL_ROOT"
mkdir -p "$DATA_DIR"
cp -R appinfo.json index.html icon.png "$DATA_DIR/"
( cd "$WORK/data" && tar --owner=0 --group=0 -czf "$WORK/data.tar.gz" . )

mkdir -p "$WORK/control"
cat > "$WORK/control/control" <<EOF
Package: $APP_ID
Version: $VERSION
Architecture: all
Maintainer: ArnoldDeRuiter
Description: Unofficial F1TV wrapper for rooted webOS TVs -- full-screen, chrome-less launcher pointing webOS's own browser engine at F1TV's real website (DRM/login handled entirely by F1TV + the platform, not by this app).
Section: misc
Priority: optional
EOF
( cd "$WORK/control" && tar --owner=0 --group=0 -czf "$WORK/control.tar.gz" control )

echo "2.0" > "$WORK/debian-binary"
OUT="${APP_ID}_${VERSION}_all.ipk"
rm -f "$OUT"
( cd "$WORK" && ar -crf "$OUT" debian-binary control.tar.gz data.tar.gz )
mv "$WORK/$OUT" "./$OUT"

sha256sum "$OUT"
echo "Built: $(pwd)/$OUT"
