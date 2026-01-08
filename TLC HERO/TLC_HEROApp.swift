//
//  TLC_HEROApp.swift
//  TLC HERO
//
//  Created by Tashi Sherpa on 1/3/26.
//

import SwiftUI

@main
struct TLC_HEROApp: App {
    @AppStorage("userTheme") private var userTheme: String = "system"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(getScheme())
        }
    }
    
    func getScheme() -> ColorScheme? {
        switch userTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}
