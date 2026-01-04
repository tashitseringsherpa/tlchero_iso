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
        case .home: return baseURL
        case .buzz: return baseURL.appendingPathComponent("buzz")
        case .flights: return baseURL.appendingPathComponent("flights")
        case .market: return baseURL.appendingPathComponent("marketplace")
        case .menu: return baseURL // Menu is native, doesn't load a URL directly
        }
    }
}

class TabManager: ObservableObject {
    @Published var selectedTab: TabItem = .home
    @Published var menuPath = NavigationPath() // For Native Menu Navigation
    
    func switchTab(to tab: TabItem) {
        selectedTab = tab
    }
    
    // Map PWA paths to Native Tabs
    func selectTab(for urlString: String) {
        guard let url = URL(string: urlString) else { return }
        // Extract path (e.g., "/buzz")
        let path = url.path.lowercased() 
        
        // Find matching tab
        // Simple matching strategies
        if path == "/" || path == "" {
            selectedTab = .home
        } else if path.contains("/buzz") {
            selectedTab = .buzz
        } else if path.contains("/flights") {
            selectedTab = .flights
        } else if path.contains("/marketplace") {
            selectedTab = .market
        }
        // Menu items usually don't switch the main tab, they might just exist within the current view
        // But if we wanted to deep link to a main tab from a link, this handles it.
    }
}
