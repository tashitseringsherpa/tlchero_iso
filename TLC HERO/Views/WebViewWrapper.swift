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
        """
        let script = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        config.userContentController.addUserScript(script)
        
        // Setup Pull to Refresh
        let refreshControl = UIRefreshControl()
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
        
        init(_ parent: WebViewWrapper) {
            self.parent = parent
        }
        
        @objc func reloadWebView(_ sender: UIRefreshControl) {
            guard let webView = sender.superview as? UIScrollView,
                  let wkWebView = webView.superview as? WKWebView else {
                sender.endRefreshing()
                return
            }
            wkWebView.reload()
            sender.endRefreshing()
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
            
            DispatchQueue.main.async {
                self.parent.isLoading = true
                self.parent.error = nil
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if webView == popupWebView { return }
            
            // Fallback: Notify Bridge of route change if JS didn't already
            if let url = webView.url {
                DispatchQueue.main.async {
                    // We only send path to keep consistency with JS bridge
                    // This acts as a backup for deep links or initial loads
                    BridgeManager.shared.activeRoute = url.path
                }
            }
            
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            if webView == popupWebView { return }
            
            print("WebView Failed: \(error.localizedDescription) Code: \((error as NSError).code)")
            
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
