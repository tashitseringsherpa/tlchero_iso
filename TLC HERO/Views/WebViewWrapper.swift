//
//  WebViewWrapper.swift
//  TLC HERO
//
//  Created by Tashi Sherpa on 1/3/26.
//

import SwiftUI
import WebKit

struct WebViewWrapper: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var error: Error?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        
        // Setup Bridge
        let contentController = WKUserContentController()
        contentController.add(BridgeManager.shared, name: "ios")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        // PWA specific settings
        config.applicationNameForUserAgent = "TLCHeroSafewrapper/1.0 Mobile/15E148 Safari/604.1"
        
        // Enable javaScriptCanOpenWindowsAutomatically for Stripe
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = true
        
        // Inject JS helper
        let js = """
        window.isNativeIOS = true;
        var style = document.createElement('style');
        style.innerHTML = `
          * { -webkit-tap-highlight-color: rgba(0,0,0,0) !important; }
          a:active, button:active { background-color: rgba(0,0,0,0.1) !important; transition: background-color 0.1s; }
        `;
        document.head.appendChild(style);

        // Intercept History API for SPA Routing
        function notifyBridge(url) {
            try {
                var path = url;
                if (!path && window.location) {
                    path = window.location.pathname;
                }
                // Resolve relative URLs
                if (path && !path.startsWith('/') && !path.startsWith('http')) {
                     var temp = new URL(path, window.location.href);
                     path = temp.pathname;
                } else if (path && path.startsWith('http')) {
                     var temp = new URL(path);
                     path = temp.pathname;
                }
                
                // Avoid notifying if path hasn't changed to filter noise if needed
                // But for now, safe to send all. Bridge handles it.
                window.webkit.messageHandlers.ios.postMessage({route: path});
            } catch(err) {
                console.error("Bridge Error:", err);
            }
        }

        var originalPushState = history.pushState;
        history.pushState = function(state, title, url) {
            var ret = originalPushState.apply(history, arguments);
            notifyBridge(url);
            return ret;
        };

        var originalReplaceState = history.replaceState;
        history.replaceState = function(state, title, url) {
            var ret = originalReplaceState.apply(history, arguments);
            notifyBridge(url);
            return ret;
        };

        window.addEventListener('popstate', function() {
            notifyBridge(window.location.pathname);
        });

        // Fallback: Poll for location changes every 500ms
        // This handles frameworks that might suppress pushState or use other methods
        var lastPath = window.location.pathname;
        setInterval(function() {
            if (window.location.pathname !== lastPath) {
                lastPath = window.location.pathname;
                notifyBridge(lastPath);
            }
        }, 500);
        """
        let script = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        config.userContentController.addUserScript(script)
        
        // Setup Pull to Refresh
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .systemOrange
        
        let refreshAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 15, weight: .bold)
        ]
        refreshControl.attributedTitle = NSAttributedString(string: "Revving up...", attributes: refreshAttributes)
        
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.reloadWebView(_:)), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            webView.topAnchor.constraint(equalTo: containerView.topAnchor),
            webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let webView = uiView.subviews.first(where: { $0 is WKWebView }) as? WKWebView else { return }
        
        if webView.url == nil {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebViewWrapper
        weak var popupWebView: WKWebView?
        var isRefreshing: Bool = false
        weak var activeRefreshControl: UIRefreshControl?
        
        init(_ parent: WebViewWrapper) {
            self.parent = parent
        }
        
        let driverHumor = [
            "Dodging inspectors...",
            "Guarding the paycheck...",
            "Finding a relief stand...",
            "Scanning for summonses...",
            "Waiting for the rider to 'come down'...",
            "Cleaning the back seat... again. 🧽",
            "Chasing a surge that disappears...",
            "Looking for a relief stand that exists...",
            "Praying pax doesn't cancel...",
            "Avoiding the 'Click it or Ticket' eye...",
            "Smiling for the school zone camera... 📸",
            "Trying not to blink at a 25mph sign...",
            "Debating if that yellow light was worth it...",
            "Praying for a JFK trip...",
            "Where are the 45+ min trips??",
            "Dodging inspectors (again)...",
            "Looking for a legal relief stand...",
            "Avoiding BQE traffic...",
            "Not blocking the box...",
            "Searching for a clean bathroom...",
            "Praying for no new summonses..."
        ]
        
        @objc func reloadWebView(_ sender: UIRefreshControl) {
            guard let webView = sender.superview as? UIScrollView,
                  let wkWebView = webView.superview as? WKWebView else {
                sender.endRefreshing()
                return
            }
            
            // Randomize Title on each refresh
            let randomMessage = driverHumor.randomElement() ?? "Revving up..."
            let refreshAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 15, weight: .bold)
            ]
            sender.attributedTitle = NSAttributedString(string: randomMessage, attributes: refreshAttributes)
            
            self.isRefreshing = true
            self.activeRefreshControl = sender
            wkWebView.reload()
            // We do NOT call sender.endRefreshing() here. We wait for navigation to finish.
        }
        
        // MARK: - WKUIDelegate (Alerts)
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            print("WKWebView Alert: \(message)")
            // Optionally present a native alert here if needed for debugging
            completionHandler()
        }
        
        // MARK: - WKNavigationDelegate
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                print("Navigating to: \(url.absoluteString)")
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            if webView == popupWebView { return }
            
            // If refreshing, do NOT show the full screen loader
            if isRefreshing { return }
            
            DispatchQueue.main.async {
                self.parent.isLoading = true
                self.parent.error = nil
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if webView == popupWebView { return }
            
            // Stop Refreshing if needed
            if isRefreshing {
                DispatchQueue.main.async {
                    self.activeRefreshControl?.endRefreshing()
                    self.isRefreshing = false
                }
            }
            
            // Fallback: Notify Bridge of route change if JS didn't already
            if let url = webView.url {
                DispatchQueue.main.async {
                    // We only send path to keep consistency with JS bridge
                    // This acts as a backup for deep links or initial loads
                    // But we rely on JS for SPA transitions
                    // BridgeManager.shared.activeRoute = url.path
                    // Commented out to avoid double firing or resetting if SPA handled it differently
                    // Actually, let's keep it but logging it
                    print("Native Navigation Finished: \(url.path)")
                }
            }
            
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            if webView == popupWebView { return }
            
            print("WebView Failed: \(error.localizedDescription) Code: \((error as NSError).code)")
            
            // Reset refreshing state
            if isRefreshing {
                DispatchQueue.main.async {
                    self.activeRefreshControl?.endRefreshing()
                    self.isRefreshing = false
                }
            }
            
            // Ignore NSURLErrorCancelled (-999) which happens on redirects or reloading
            if (error as NSError).code == NSURLErrorCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.error = error
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            if webView == popupWebView { return }
            
            print("WebView Prov Failed: \(error.localizedDescription) Code: \((error as NSError).code)")
            
            // Reset refreshing state
            if isRefreshing {
                DispatchQueue.main.async {
                    self.activeRefreshControl?.endRefreshing()
                    self.isRefreshing = false
                }
            }
            
            // Ignore NSURLErrorCancelled (-999)
            if (error as NSError).code == NSURLErrorCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.error = error
            }
        }
        
        // MARK: - WKUIDelegate (Popup Handling)
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            
            let popup = WKWebView(frame: webView.frame, configuration: configuration)
            popup.navigationDelegate = self
            popup.uiDelegate = self
            popup.translatesAutoresizingMaskIntoConstraints = false
            
            guard let container = webView.superview else { return nil }
            container.addSubview(popup)
            
            NSLayoutConstraint.activate([
                popup.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                popup.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                popup.topAnchor.constraint(equalTo: container.topAnchor),
                popup.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            
            self.popupWebView = popup
            return popup
        }
        
        func webViewDidClose(_ webView: WKWebView) {
            if webView == popupWebView {
                webView.removeFromSuperview()
                popupWebView = nil
            }
        }
    }
}
