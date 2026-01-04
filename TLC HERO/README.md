# TLC Hero iOS App

This is a native SwiftUI wrapper for the TLC Hero PWA (https://tlchero.com).

## Project Structure

The source files are located in the `Sources` directory.
- `TLCHeroApp.swift`: App entry point.
- `ContentView.swift`: Main UI controller.
- `Views/WebViewWrapper.swift`: The `WKWebView` integration.
- `Views/`: Supporting UI views (Loading, Error, Offline).
- `Utilities/`: Helper classes (NetworkMonitor).

## How to Build in Xcode

Since this is a generated source set, you need to create an Xcode project to run it.

1. **Open Xcode** and create a **New Project**.
2. Select **App** under iOS.
3. Name it **TLCHero** (or similar).
4. Interface: **SwiftUI**.
5. Language: **Swift**.
6. **Important**: Delete the default files created by Xcode (`ContentView.swift`, `TLCHeroApp.swift`, `Assets.xcassets` is fine to keep).
7. Drag and drop the `Sources` folder from this directory into your Xcode project navigator. Make sure "Copy items if needed" is unchecked (or checked if you want to duplicate them) and "Create groups" is selected.
8. Ensure `TLCHeroApp.swift` is added to your target.

## App Store Compliance & Capabilities

To ensure the app is compliant and functions correctly:

### 1. Info.plist Configuration
Add the following keys to your `Info.plist` (or Target Properties):

- **App Transport Security Settings**:
    - `Allow Arbitrary Loads`: NO (Keep strictly HTTPS)
- **Apple Pay**:
    - Ensure you have the Apple Pay capability enabled in "Signing & Capabilities".
    - You must have a Merchant ID configured.
    - **Crucial**: Your PWA domain (`tlchero.com`) must be verified in your Apple Developer account for Apple Pay on the Web.

### 2. Capabilities
Go to project settings -> Signing & Capabilities and add:
- **Apple Pay**: Check your merchant ID.
- **Background Modes** (Optional): If you need background audio or notifications (unlikely for this wrapper).

### 3. App Review Notes
When submitting to the App Store, include a note in the Review Information:
> "This app serves as a mobile client for our existing web platform handling government payment services (tickets/fines). It does not sell digital goods or unlock content within the app. All payments are for physical/real-world services."

## Customization

- **Change URL**: Open `Sources/ContentView.swift` and edit the `pwaURL` property.
- **Styling**: Edit `Sources/Views/` files to match your brand colors if needed.

## Testing
- **Simulator**: Run in Xcode Simulator.
- **Device**: Connect your iPhone and run. Make sure to trust your developer profile in Settings -> General -> VPN & Device Management.
