#!/bin/zsh
set -euo pipefail
PROJECT_DIR="${0:A:h:h}"
BUILD_DIR="$PROJECT_DIR/build"
APP_DIR="$BUILD_DIR/Aftertone.app"
CONTENTS_DIR="$APP_DIR/Contents"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
SDK_PATH="$(xcrun --show-sdk-path)"
mkdir -p "$CONTENTS_DIR/MacOS" "$RESOURCES_DIR" "$BUILD_DIR/ModuleCache" "$BUILD_DIR/SwiftModuleCache"
CLANG_MODULE_CACHE_PATH="$BUILD_DIR/ModuleCache" SWIFT_MODULE_CACHE_PATH="$BUILD_DIR/SwiftModuleCache" \
xcrun swiftc -parse-as-library -O -sdk "$SDK_PATH" -target arm64-apple-macosx14.0 \
  -framework SwiftUI -framework AppKit -framework AVFoundation -framework UniformTypeIdentifiers \
  "$PROJECT_DIR"/Sources/*.swift -o "$CONTENTS_DIR/MacOS/Aftertone"
cp "$PROJECT_DIR/Resources/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$PROJECT_DIR/Resources/AftertoneIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
for asset in AftertoneIcon.png EarthHorizon.jpg EarthSurface.png; do
  cp "$PROJECT_DIR/Resources/$asset" "$RESOURCES_DIR/$asset"
done
printf 'APPL????' > "$CONTENTS_DIR/PkgInfo"
codesign --force --deep --sign - "$APP_DIR"
echo "$APP_DIR"
