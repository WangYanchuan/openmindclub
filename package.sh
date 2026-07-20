#!/bin/bash
# 一键打包 开智元学.app 并生成/更新 Homebrew cask
# 用法：
#   ./package.sh <版本号> <GitHub用户名>
# 例：
#   ./package.sh 1.1 zhangsan
set -e

VERSION="${1:-1.0}"
GH_USER="${2:-YOUR_GITHUB_USERNAME}"

DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="开智元学.app"
BUILD="$DIR/build"
RELEASE="$DIR/release"
CASK="$DIR/homebrew-tap/Casks/openmindclub.rb"

echo "==> 1/5 编译主程序"
mkdir -p "$BUILD"
swiftc "$DIR/main.swift" -o "$BUILD/openmindclub" -framework Cocoa -framework WebKit -O

echo "==> 2/5 生成图标（若不存在）"
if [ ! -f "$BUILD/openmindclub.icns" ]; then
  swiftc "$DIR/makeicon.swift" -o "$BUILD/makeicon"
  (cd "$BUILD" && ./makeicon icon_1024.png)
  rm -rf "$BUILD/openmindclub.iconset"; mkdir -p "$BUILD/openmindclub.iconset"
  for s in 16 32 64 128 256 512; do
    d=$((s*2))
    sips -z $s $s "$BUILD/icon_1024.png" --out "$BUILD/openmindclub.iconset/icon_${s}x${s}.png" >/dev/null
    sips -z $d $d "$BUILD/icon_1024.png" --out "$BUILD/openmindclub.iconset/icon_${s}x${s}@2x.png" >/dev/null
  done
  sips -z 1024 1024 "$BUILD/icon_1024.png" --out "$BUILD/openmindclub.iconset/icon_512x512@2x.png" >/dev/null
  iconutil -c icns "$BUILD/openmindclub.iconset" -o "$BUILD/openmindclub.icns"
fi

echo "==> 3/5 组装 .app"
APP="$BUILD/$APP_NAME"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BUILD/openmindclub" "$APP/Contents/MacOS/"
cp "$BUILD/openmindclub.icns" "$APP/Contents/Resources/"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key><string>zh_CN</string>
    <key>CFBundleExecutable</key><string>openmindclub</string>
    <key>CFBundleIconFile</key><string>openmindclub</string>
    <key>CFBundleIdentifier</key><string>com.user.openmindclub</string>
    <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
    <key>CFBundleName</key><string>开智元学</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>${VERSION}</string>
    <key>CFBundleVersion</key><string>${VERSION}</string>
    <key>LSMinimumSystemVersion</key><string>12.0</string>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSAppTransportSecurity</key><dict><key>NSAllowsArbitraryLoads</key><true/></dict>
</dict>
</plist>
PLIST

echo "==> 4/5 打包 zip"
mkdir -p "$RELEASE"
ZIP="$RELEASE/OpenMindClub-${VERSION}.zip"
rm -f "$ZIP"
ditto -c -k --keepParent "$APP" "$ZIP"
SHA=$(shasum -a 256 "$ZIP" | awk '{print $1}')

echo "==> 5/5 更新 cask 文件"
sed -i '' \
  -e "s/version \".*\"/version \"${VERSION}\"/" \
  -e "s/sha256 \".*\"/sha256 \"${SHA}\"/" \
  -e "s#github.com/[^/]*/openmindclub-mac#github.com/${GH_USER}/openmindclub-mac#" \
  "$CASK"

echo ""
echo "完成 ✅"
echo "  zip:    $ZIP"
echo "  sha256: $SHA"
echo "  cask:   $CASK （已回填 version/sha256/用户名）"
echo ""
echo "下一步：把 $ZIP 传到 GitHub Release (tag v${VERSION})，再推送 homebrew-tap 仓库。"
