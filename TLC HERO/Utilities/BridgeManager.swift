//
//  BridgeManager.swift
//  TLC HERO
//
//  Created by Tashi Sherpa on 1/3/26.
//

import Foundation
import WebKit
import SwiftUI
import Combine

// Define the supported actions
enum BridgeAction: String {
    case openApplePay
    case logout
    case openSettings
}

class BridgeManager: NSObject, ObservableObject, WKScriptMessageHandler {
    static let shared = BridgeManager()
    
    // Publish events for views to react to
    @Published var showSettings = false
    @Published var shouldLogout = false
    @Published var activeRoute: String? // New: Track active route
    
    // Delegate for complex actions like Payments that might need UI Context
    weak var paymentDelegate: PaymentDelegate?
    
    override init() {
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "ios",
              let body = message.body as? [String: Any] else { return }
        
        // 1. Handle Route Updates (No specific action key, just 'route')
        // Format: { "route": "/buzz" }
        if let route = body["route"] as? String {
            DispatchQueue.main.async {
                self.activeRoute = route
                print("Received Route Update: \(route)")
            }
            return
        }
        
        // 2. Handle Explicit Actions
        // Format: { "action": "logout" }
        guard let actionString = body["action"] as? String,
              let action = BridgeAction(rawValue: actionString) else {
            print("Invalid message received: \(body)")
            return
        }
        
        switch action {
        case .openApplePay:
            if let ticketId = body["ticketId"] as? String {
                DispatchQueue.main.async {
                    self.paymentDelegate?.handleApplePayRequest(ticketId: ticketId)
                }
            }
        case .logout:
            DispatchQueue.main.async {
                self.handleLogout()
            }
        case .openSettings:
            DispatchQueue.main.async {
                self.showSettings = true
            }
        }
    }
    
    private func handleLogout() {
        // Clear cookies and website data
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date(timeIntervalSince1970: 0)) {
            print("Web data cleared")
            // Notify app to reset state if needed
            self.shouldLogout = true
        }
    }
}

protocol PaymentDelegate: AnyObject {
    func handleApplePayRequest(ticketId: String)
}
