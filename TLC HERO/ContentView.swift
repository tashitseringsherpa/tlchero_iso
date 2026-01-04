//
//  ContentView.swift
//  TLC HERO
//
//  Created by Tashi Sherpa on 1/3/26.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var bridgeManager = BridgeManager.shared
    @State private var showingSettings = false
    
    var body: some View {
        ZStack {
            if networkMonitor.isConnected {
                MainTabView()
                    // Bridge Action - Settings
                    .sheet(isPresented: $bridgeManager.showSettings) {
                        Text("Settings Page")
                            .font(.title)
                            .presentationDetents([.medium])
                    }
                    // Handle Logout if needed (e.g. switch to login screen or reset tabs)
                    .onChange(of: bridgeManager.shouldLogout) { shouldLogout in
                         if shouldLogout {
                             // Perform any broader app logout logic here
                             // For now, we just reset the flag
                             print("Logged out")
                             bridgeManager.shouldLogout = false
                         }
                    }
            } else {
                ErrorView {
                    // Retry action can be handled proactively by network monitor
                }
            }
            
            // Offline Overlay
            if !networkMonitor.isConnected {
                ErrorView {
                    
                }
                .zIndex(3)
            }
        }
    }
}

#Preview {
    ContentView()
}
