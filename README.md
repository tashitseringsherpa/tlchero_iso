# TLC Hero iOS Native Shell

This is the native iOS shell application for TLC Hero, built with SwiftUI and WKWebView. It wraps the React PWA (`https://tlchero.com`) and provides native capabilities like persistent navigation tabs, Apple Pay integration, and deep linking.

## Features

- **Native Tab Bar**: Home, Buzz, Flights, Market, and a Native Menu.
- **Bi-directional Navigation Sync**: 
  - Native tabs update when the PWA navigates internally.
  - PWA receives specific flags to hide its own headers/footers.
- **Bridge**: `WKScriptMessageHandler` ("ios") for managing Apple Pay, Settings, and Logging out.
- **Resilient Retry**: "Try Again" functionality fully recreates the WebView to clear stuck states.

## Navigation Sync Integration

To ensure the native tab bar stays in sync with React Router:

### 1. Check for Native Environment
```javascript
export const isNativeIOS = () => {
  return window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.ios;
};
```

### 2. Send Route Updates
Call this whenever the route changes (e.g., in `history.listen` or `useEffect` with `useLocation`):

```javascript
export const syncNativeRoute = (pathname) => {
  if (isNativeIOS()) {
    window.webkit.messageHandlers.ios.postMessage({
      route: pathname
    });
  }
};
```

## Native Bridge Actions

Send messages to `window.webkit.messageHandlers.ios`:

- **Logout**: `{ "action": "logout" }`
- **Open Settings**: `{ "action": "openSettings" }`
- **Apple Pay**: `{ "action": "openApplePay", "ticketId": "12345" }`

## Requirements

- iOS 16.0+
- Xcode 14+
- Stripe iOS SDK (Must be added via SPM for Apple Pay to work)
