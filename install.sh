#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
DEST="/Applications/GlanceMD.app"
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister

"$ROOT/build.sh" >/dev/null
osascript -e 'quit app "GlanceMD"' >/dev/null 2>&1 || true
rm -rf "$DEST"
cp -R "$ROOT/build/GlanceMD.app" "$DEST"

"$LSREGISTER" -u "$ROOT/build/GlanceMD.app" >/dev/null 2>&1 || true
"$LSREGISTER" -f -R "$DEST"
pluginkit -a "$DEST/Contents/PlugIns/QuickLookPreview.appex"
qlmanage -r >/dev/null 2>&1

echo "Installed $DEST"
