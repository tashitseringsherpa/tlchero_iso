//
//  MainTabView.swift
//  TLC HERO
//
//  Created by Tashi Sherpa on 1/3/26.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var tabManager = TabManager()
    @StateObject private var paymentManager = PaymentManager.shared // Ensure payment manager is alive
    
    // Shared state for Loading/Error could be per tab or global.
    // Ideally per tab so switching tabs doesn't show loading for a loaded tab.
    // For simplicity, we can have separate states.
    
    @State private var loadingStates: [TabItem: Bool] = [:]
    @State private var errors: [TabItem: Error?] = [:]
    
    private let baseURL = URL(string: "https://tlchero.com")!
    
    var body: some View {
        TabView(selection: $tabManager.selectedTab) {
            
            // Home Tab
            NavigationStack {
                WebViewWrapper(
                    url: TabItem.home.url(baseURL: baseURL),
                    isLoading: binding(for: .home, in: $loadingStates),
                    error: binding(for: .home, in: $errors)
                )
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Home", systemImage: TabItem.home.icon)
            }
            .tag(TabItem.home)
            
            // Buzz Tab
            NavigationStack {
                WebViewWrapper(
                    url: TabItem.buzz.url(baseURL: baseURL),
                    isLoading: binding(for: .buzz, in: $loadingStates),
                    error: binding(for: .buzz, in: $errors)
                )
                .navigationTitle("Buzz")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Buzz", systemImage: TabItem.buzz.icon)
            }
            .tag(TabItem.buzz)
            
            // Flights Tab
            NavigationStack {
                WebViewWrapper(
                    url: TabItem.flights.url(baseURL: baseURL),
                    isLoading: binding(for: .flights, in: $loadingStates),
                    error: binding(for: .flights, in: $errors)
                )
                .navigationTitle("Flights")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Flights", systemImage: TabItem.flights.icon)
            }
            .tag(TabItem.flights)
            
            // Market Tab
            NavigationStack {
                WebViewWrapper(
                    url: TabItem.market.url(baseURL: baseURL),
                    isLoading: binding(for: .market, in: $loadingStates),
                    error: binding(for: .market, in: $errors)
                )
                .navigationTitle("Market")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Market", systemImage: TabItem.market.icon)
            }
            .tag(TabItem.market)
            
            // Menu Tab
            MenuView(
                isLoading: binding(for: .menu, in: $loadingStates),
                error: binding(for: .menu, in: $errors)
            )
            .tabItem {
                Label("Menu", systemImage: TabItem.menu.icon)
            }
            .tag(TabItem.menu)
        }
        .accentColor(.blue) // Customize to brand color
        .onAppear {
            // Initialize states
            for tab in TabItem.allCases {
                loadingStates[tab] = false
            }
        }
        // Handle Global Bridge Actions (Settings, Payment)
        // We can overlay a sheet/modal here if needed.
        .alert(item: $paymentManager.paymentError) { errorString in
             Alert(title: Text("Payment"), message: Text(errorString), dismissButton: .default(Text("OK")))
        }
        // Listen for Route Updates from Bridge (JS or Fallback)
        .onReceive(BridgeManager.shared.$activeRoute) { route in
            if let route = route {
                tabManager.selectTab(for: route)
            }
        }
    }
    
    // Helper to create bindings for dictionary
    private func binding(for tab: TabItem, in dict: Binding<[TabItem: Bool]>) -> Binding<Bool> {
        Binding(
            get: { dict.wrappedValue[tab] ?? false },
            set: { dict.wrappedValue[tab] = $0 }
        )
    }
    
    private func binding(for tab: TabItem, in dict: Binding<[TabItem: Error?]>) -> Binding<Error?> {
        Binding(
            get: { dict.wrappedValue[tab] ?? nil },
            set: { dict.wrappedValue[tab] = $0 }
        )
    }
}

// Extension to make String identifiable for Alert
extension String: Identifiable {
    public var id: String { self }
}
