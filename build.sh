#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD="$ROOT/build"
APP="$BUILD/GlanceMD.app"
APPEX="$APP/Contents/PlugIns/QuickLookPreview.appex"
MIN_MACOS=13.0

build_universal() {
    local out="$1"; shift
    local slices=()
    for arch in arm64 x86_64; do
        local slice="$BUILD/obj/$(basename "$out")-$arch"
        swiftc -O -target "$arch-apple-macosx$MIN_MACOS" -o "$slice" "$@"
        slices+=("$slice")
    done
    lipo -create -output "$out" "${slices[@]}"
}

rm -rf "$BUILD"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$APPEX/Contents/MacOS" "$BUILD/obj"
cp "$ROOT/src/app/Info.plist" "$APP/Contents/Info.plist"
cp "$ROOT/src/quicklook/Info.plist" "$APPEX/Contents/Info.plist"
cp -R "$ROOT/web" "$APP/Contents/Resources/web"
cp "$ROOT/assets/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"

build_universal "$APP/Contents/MacOS/GlanceMD" \
    "$ROOT/src/shared/Settings.swift" "$ROOT/src/shared/MarkdownPage.swift" \
    "$ROOT/src/app/SettingsWindow.swift" "$ROOT/src/app/main.swift"
build_universal "$APPEX/Contents/MacOS/QuickLookPreview" \
    -module-name QuickLookPreview -Xlinker -e -Xlinker _NSExtensionMain \
    "$ROOT/src/shared/Settings.swift" "$ROOT/src/shared/MarkdownPage.swift" \
    "$ROOT/src/quicklook/PreviewViewController.swift"
rm -rf "$BUILD/obj"

codesign --force --sign - --entitlements "$ROOT/src/quicklook/QuickLook.entitlements" "$APPEX"
codesign --force --sign - "$APP"

echo "$APP"
