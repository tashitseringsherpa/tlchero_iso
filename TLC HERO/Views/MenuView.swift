//
//  MenuView.swift
//  TLC HERO
//
//  Created by Tashi Sherpa on 1/3/26.
//

import SwiftUI

struct MenuView: View {
//    let baseURL = URL(string: "https://tlchero.com")!
    let baseURL = URL(string: "http://localhost:9002/")!
    
    @ObservedObject var tabManager: TabManager
    @Binding var isLoading: Bool
    @Binding var error: Error?
    
    var body: some View {
        NavigationStack(path: $tabManager.menuPath) {
            List(MenuItem.allItems) { item in
                NavigationLink(value: item) {
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
            .navigationDestination(for: MenuItem.self) { item in
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
            }
        }
    }
}
