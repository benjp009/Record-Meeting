#!/bin/bash

# Meeting Recorder macOS Build Script
# Usage: ./scripts/build.sh [debug|release]

set -e

BUILD_TYPE="${1:-debug}"
PROJECT_NAME="MeetingRecorder"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$SCRIPT_DIR/.."
BUILD_DIR="$PROJECT_DIR/.build"
DIST_DIR="$PROJECT_DIR/dist"

echo "🏗️  Building $PROJECT_NAME ($BUILD_TYPE)..."

# Clean previous builds
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Build the app
if [ "$BUILD_TYPE" = "release" ]; then
    echo "📦 Building release version..."
    swift build -c release -v
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

# Next step: DMG creation (to be implemented in Phase 0)
echo ""
echo "ℹ️  DMG creation will be implemented in Phase 0"
echo "   This script prepared the executable at: $DIST_DIR/$PROJECT_NAME"

exit 0
