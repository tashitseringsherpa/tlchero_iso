#!/bin/bash

# Configuration
SCHEME="TLC HERO"
BUNDLE_ID="com.tlchero.TLC-HERO"
TARGET_DEVICE_NAME="iPhone 17" # Preferred device name
PROJECT="TLC HERO.xcodeproj"
DERIVED_DATA_PATH="build"

echo "🚀 Implementing iOS Build & Run Script..."

# 1. Find a valid destination ID using xcodebuild
echo "🔍 Finding eligible destination for $TARGET_DEVICE_NAME..."
DESTINATIONS=$(xcodebuild -showdestinations -project "$PROJECT" -scheme "$SCHEME")

# Try to find the specific device in valid destinations
DEVICE_ID=$(echo "$DESTINATIONS" | grep "name:$TARGET_DEVICE_NAME" | grep "id:" | head -n 1 | sed 's/.*id:\([^,]*\).*/\1/')

# If not found, try any iPhone
if [ -z "$DEVICE_ID" ]; then
    echo "⚠️ '$TARGET_DEVICE_NAME' not found in eligible destinations. Trying any iPhone..."
    DEVICE_ID=$(echo "$DESTINATIONS" | grep "name:iPhone" | grep "id:" | head -n 1 | sed 's/.*id:\([^,]*\).*/\1/')
fi

if [ -z "$DEVICE_ID" ]; then
    echo "❌ Error: No eligible iOS Simulator found!"
    echo "Available destinations:"
    echo "$DESTINATIONS"
    exit 1
fi

# Find the device name for the ID we found (for logging)
ACTUAL_DEVICE_NAME=$(xcrun simctl list devices | grep "$DEVICE_ID" | sed 's/.*(\(.*\)).*/\1/' | head -n 1) # Simple extraction
echo "✅ Selected Device ID: $DEVICE_ID"

# 2. Boot the simulator if not already booted
STATUS=$(xcrun simctl list devices | grep "$DEVICE_ID" | grep "Booted")
if [ -z "$STATUS" ]; then
    echo "📱 Booting simulator ($DEVICE_ID)..."
    xcrun simctl boot "$DEVICE_ID"
    # Wait for boot
    echo "⏳ Waiting for simulator to boot..."
    xcrun simctl bootstatus "$DEVICE_ID"
else
    echo "📱 Simulator ($DEVICE_ID) already booted."
fi

# Open Simulator GUI
open -a Simulator

# 3. Build the app
echo "🛠 Building project..."
# Use pipefail to catch build errors if using xcpretty
set -o pipefail
if command -v xcpretty &> /dev/null; then
    xcodebuild \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -destination "platform=iOS Simulator,id=$DEVICE_ID" \
        -derivedDataPath "$DERIVED_DATA_PATH" \
        clean build | xcpretty
else
    echo "⚠️ xcpretty not installed. Using raw output."
    xcodebuild \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -destination "platform=iOS Simulator,id=$DEVICE_ID" \
        -derivedDataPath "$DERIVED_DATA_PATH" \
        clean build
fi

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

APP_PATH="$DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator/$SCHEME.app"

if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: App not found at $APP_PATH"
    exit 1
fi

echo "✅ Build successful!"

# 4. Install the app
echo "mb Installing app..."
xcrun simctl install "$DEVICE_ID" "$APP_PATH"

# 5. Launch the app
echo "🚀 Launching app..."
xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"

echo "🎉 Done! App is running."
