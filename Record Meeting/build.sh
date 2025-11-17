#!/bin/bash

# Meeting Recorder macOS Build Script
# Usage: ./build.sh [debug|release]

set -e

BUILD_TYPE="${1:-debug}"
PROJECT_NAME="MeetingRecorder"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$SCRIPT_DIR/.."
BUILD_DIR="$PROJECT_DIR/.build"
DIST_DIR="$PROJECT_DIR/dist"

# Code signing identity (use your development certificate)
# Find available identities: security find-identity -v -p codesigning
SIGNING_IDENTITY="Apple Development: patin.benjamin@gmail.com (D6Q9NGWY28)"

echo "🏗️  Building $PROJECT_NAME ($BUILD_TYPE)..."
echo "📝 Using code signing identity: $SIGNING_IDENTITY"

# Clean previous builds
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Build the app with code signing
if [ "$BUILD_TYPE" = "release" ]; then
    echo "📦 Building release version..."
    swift build -c release -v -Xswiftc "-suppress-warnings" \
        -Xswiftc "-warn-long-function-bodies=10" \
        --disable-warnings
    BUILD_PRODUCT="$BUILD_DIR/release/$PROJECT_NAME"
else
    echo "🔨 Building debug version..."
    swift build -v
    BUILD_PRODUCT="$BUILD_DIR/debug/$PROJECT_NAME"
fi

# Verify build succeeded
if [ ! -f "$BUILD_PRODUCT" ]; then
    echo "❌ Build failed: executable not found"
    exit 1
fi

echo "✅ Build successful!"
echo "📍 Executable location: $BUILD_PRODUCT"

# Copy to dist for easy access
cp "$BUILD_PRODUCT" "$DIST_DIR/$PROJECT_NAME"
echo "📋 Copied to: $DIST_DIR/$PROJECT_NAME"

# Code sign the executable
echo ""
echo "🔐 Code signing executable..."
codesign -f -s "$SIGNING_IDENTITY" "$DIST_DIR/$PROJECT_NAME" 2>/dev/null || {
    echo "⚠️  Code signing skipped (identity may not be available in this context)"
}

# Verify signing
codesign -v "$DIST_DIR/$PROJECT_NAME" 2>/dev/null || {
    echo "⚠️  Could not verify signature"
}

# Next step: DMG creation
echo ""
echo "ℹ️  DMG creation will be implemented in Phase 0"
echo "   Signed executable ready at: $DIST_DIR/$PROJECT_NAME"

exit 0
