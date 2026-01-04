//
//  MenuView.swift
//  TLC HERO
//
//  Created by Tashi Sherpa on 1/3/26.
//

import SwiftUI

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let path: String
}

struct MenuView: View {
    let baseURL = URL(string: "https://tlchero.com")!
    
    let menuItems = [
        MenuItem(title: "Inbox", icon: "envelope", path: "messages"),
        MenuItem(title: "Dashboard", icon: "gauge", path: "dashboard"),
        MenuItem(title: "My Listing", icon: "list.bullet.rectangle", path: "marketplace?view=mine"),
        MenuItem(title: "Active Vehicles & Drivers", icon: "car.2.fill", path: "tlc-data"),
        MenuItem(title: "Suspended Vehicles & Drivers", icon: "exclamationmark.triangle.fill", path: "tlc-suspended"),
        MenuItem(title: "Market Trend", icon: "chart.line.uptrend.xyaxis", path: "market-insights")
        // "Settings" and "Logout" could also be here or handled via Bridge
    ]
    
    @Binding var isLoading: Bool
    @Binding var error: Error?
    
    var body: some View {
        NavigationStack {
            List(menuItems) { item in
                NavigationLink(destination: 
                    WebViewWrapper(url: baseURL.appendingPathComponent(item.path), isLoading: $isLoading, error: $error)
                        .overlay {
                            if isLoading {
                                LoadingView()
                            }
                        }
                        .navigationTitle(item.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .onAppear {
                            // Reset any webview specific state if needed
                        }
                ) {
                    HStack {
                        Image(systemName: item.icon)
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        Text(item.title)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Menu")
            .listStyle(.insetGrouped)
        }
    }
}
