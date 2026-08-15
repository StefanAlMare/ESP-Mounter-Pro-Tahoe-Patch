#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
VERSION="2.0"
DIST="$ROOT/dist"
STAGE="$DIST/ESP-Mounter-Pro-Tahoe-Patcher-$VERSION-PUBLIC"
APP="$STAGE/ESP Mounter Pro Tahoe Patcher.app"

rm -rf "$DIST"
mkdir -p "$APP/Contents/MacOS"
cp "$ROOT/app-template/Contents/Info.plist" "$APP/Contents/Info.plist"
cp "$ROOT/src/tahoe-patcher.sh" "$APP/Contents/MacOS/tahoe-patcher"
chmod 755 "$APP/Contents/MacOS/tahoe-patcher"
cp "$ROOT/README.md" "$STAGE/README.md"
cp "$ROOT/LICENSE" "$STAGE/LICENSE"
cp "$ROOT/NOTICE.md" "$STAGE/NOTICE.md"
cp "$ROOT/src/tahoe-patcher.sh" "$STAGE/SOURCE-tahoe-patcher.sh"

cd "$DIST"
/usr/bin/zip -qry "ESP-Mounter-Pro-Tahoe-Patcher-$VERSION-PUBLIC.zip" "$(basename "$STAGE")"
/usr/bin/shasum -a 256 "ESP-Mounter-Pro-Tahoe-Patcher-$VERSION-PUBLIC.zip"
