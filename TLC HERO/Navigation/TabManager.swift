//
//  TabManager.swift
//  TLC HERO
//
//  Created by Tashi Sherpa on 1/3/26.
//

import Foundation
import SwiftUI
import Combine

enum TabItem: String, CaseIterable {
    case home = "Home"
    case buzz = "Buzz"
    case flights = "Flights"
    case market = "Market"
    case menu = "Menu"
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .buzz: return "bubble.left.and.bubble.right.fill"
        case .flights: return "airplane"
        case .market: return "cart.fill"
        case .menu: return "line.3.horizontal"
        }
    }
    
    func url(baseURL: URL) -> URL {
        switch self {
        case .home: return baseURL.appendingPathComponent("ios-home")
        case .buzz: return baseURL.appendingPathComponent("buzz")
        case .flights: return baseURL.appendingPathComponent("flights")
        case .market: return baseURL.appendingPathComponent("marketplace")
        case .menu: return baseURL // Menu is native, doesn't load a URL directly
        }
    }
}

struct MenuItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let path: String
    
    // Implement Hashable manually if needed, or let Swift synthesize it
    func hash(into hasher: inout Hasher) {
        hasher.combine(path) // Path should be unique enough for menu items
    }
    
    static func == (lhs: MenuItem, rhs: MenuItem) -> Bool {
        return lhs.path == rhs.path
    }
    
    // Static definition of menu items so we can reference them
    static let allItems: [MenuItem] = [
        MenuItem(title: "Inbox", icon: "envelope", path: "messages"),
        MenuItem(title: "Dashboard", icon: "gauge", path: "dashboard"),
        MenuItem(title: "My Listing", icon: "list.bullet.rectangle", path: "marketplace?view=mine"),
        MenuItem(title: "Active Vehicles & Drivers", icon: "car.2.fill", path: "tlc-data"),
        MenuItem(title: "Suspended Vehicles & Drivers", icon: "exclamationmark.triangle.fill", path: "tlc-suspended"),
        MenuItem(title: "Market Trend", icon: "chart.line.uptrend.xyaxis", path: "market-insights")
    ]
}

class TabManager: ObservableObject {
    @Published var selectedTab: TabItem = .home
    @Published var menuPath = NavigationPath()
    
    func switchTab(to tab: TabItem) {
        selectedTab = tab
    }
    
    // Map PWA paths to Native Tabs
    func selectTab(for urlString: String) {
        // Normalize path
        var path = urlString.lowercased()
        
        // If it's a full URL, get the path
        if let url = URL(string: urlString), url.scheme != nil {
            path = url.path.lowercased()
        }
        
        // Remove trailing or leading whitespace/newlines
        path = path.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("Selecting Tab for path: \(path)")
        
        // Simple matching strategies
        if path == "/" || path == "" || path == "/ios-home" {
            selectedTab = .home
        } else if path.contains("/buzz") {
            selectedTab = .buzz
        } else if path.contains("/flights") {
            selectedTab = .flights
        } else if path.contains("/marketplace") {
            selectedTab = .market
        } else if path.contains("/dashboard") {
            selectedTab = .menu
            // Find the dashboard item
            if let dashboardItem = MenuItem.allItems.first(where: { $0.path == "dashboard" }) {
                // Clear path and append dashboard
                // Resetting it ensures we go to the view even if already there
                menuPath = NavigationPath()
                menuPath.append(dashboardItem)
            }
        }
    }
}
