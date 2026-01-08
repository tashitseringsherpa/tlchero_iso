#!/bin/bash

# Configuration
PROJECT="TLC HERO.xcodeproj"
SCHEME="TLC HERO"
ARCHIVE_PATH="build/TLC_HERO.xcarchive"

echo "🚀 Starting Deployment Process..."

# 1. Ensure we are in the project root (simple check)
if [ ! -d "$PROJECT" ]; then
    echo "❌ Error: Could not find $PROJECT. Run from project root."
    exit 1
fi

# 2. Increment Build Number
echo "🔢 Incrementing Build Number..."
agvtool next-version -all

# 3. Clean and Archive
echo "📦 Archiving Project..."
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE_PATH" \
    clean archive

if [ $? -ne 0 ]; then
    echo "❌ Archive failed!"
    exit 1
fi

echo "✅ Archive successful at $ARCHIVE_PATH"

# 4. Open in Organizer
echo "📂 Opening Archive in Xcode Organizer..."
open "$ARCHIVE_PATH"

echo "🎉 Implementation Complete! in Xcode Organizer:"
echo "   1. Click 'Distribute App'"
echo "   2. Choose 'App Store Connect' -> 'Upload'"
echo "   3. Follow the wizard to upload to TestFlight."
