//
//  MenuView.swift
//  TLC HERO
//
//  Created by Tashi Sherpa on 1/3/26.
//

import SwiftUI

struct MenuView: View {
   let baseURL = URL(string: "https://tlchero.com")!
    // let baseURL = URL(string: "http://localhost:9002/")!
    
    @ObservedObject var tabManager: TabManager
    @Binding var isLoading: Bool
    @Binding var error: Error?
    
    @AppStorage("userTheme") private var userTheme: String = "system"
    private let brandBlue = Color(red: 10/255, green: 40/255, blue: 80/255) // Dark Blue

    var body: some View {
        NavigationStack(path: $tabManager.menuPath) {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Stylish Theme Toggle
                        HStack(spacing: 15) {
                            // Light Mode Button
                            Button(action: {
                                withAnimation {
                                    userTheme = (userTheme == "light") ? "system" : "light"
                                }
                            }) {
                                HStack {
                                    Image(systemName: "sun.max.fill")
                                    Text("Light")
                                }
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(userTheme == "light" ? brandBlue : Color(uiColor: .secondarySystemGroupedBackground))
                                .foregroundColor(userTheme == "light" ? .white : .primary)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(userTheme == "light" ? brandBlue : Color.clear, lineWidth: 2)
                                )
                            }
                            
                            // Dark Mode Button
                            Button(action: {
                                withAnimation {
                                    userTheme = (userTheme == "dark") ? "system" : "dark"
                                }
                            }) {
                                HStack {
                                    Image(systemName: "moon.fill")
                                    Text("Dark")
                                }
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(userTheme == "dark" ? brandBlue : Color(uiColor: .secondarySystemGroupedBackground))
                                .foregroundColor(userTheme == "dark" ? .white : .primary)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(userTheme == "dark" ? brandBlue : Color.clear, lineWidth: 2)
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20) // Add top spacing since header is gone
                        
                        // Menu Grid/List
                        VStack(spacing: 12) {
                            ForEach(MenuItem.allItems) { item in
                                NavigationLink(value: item) {
                                    HStack(spacing: 15) {
                                        ZStack {
                                            Circle()
                                                .fill(brandBlue.opacity(0.1))
                                                .frame(width: 44, height: 44)
                                            
                                            Image(systemName: item.icon)
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundColor(brandBlue)
                                        }
                                        
                                        Text(item.title)
                                            .font(.system(size: 17, weight: .medium, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.gray.opacity(0.5))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Footer Stuff
                        VStack(spacing: 4) {
                            Text("Version 1.0.0")
                                .font(.caption2)
                                .foregroundColor(Color(uiColor: .tertiaryLabel))
                            Text("Made in NYC 🍎")
                                .font(.caption2)
                                .foregroundColor(Color(uiColor: .tertiaryLabel))
                        }
                        .padding(.top, 30)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Menu")
            .toolbar(.hidden, for: .navigationBar) // Hide default native navbar
            .navigationDestination(for: MenuItem.self) { item in
                WebViewWrapper(url: URL(string: item.path, relativeTo: baseURL) ?? baseURL, isLoading: $isLoading, error: $error)
                    .overlay {
                        if isLoading {
                            LoadingView()
                        }
                    }
                    .ignoresSafeArea(edges: .top) // Match PWA background
                    .toolbar(.hidden, for: .navigationBar) // Hide navbar to show PWA header
                    .onAppear {
                        // Reset any webview specific state if needed
                    }
            }
        }
    }
}
