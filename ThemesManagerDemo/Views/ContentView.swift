//
//  ContentView.swift
//  ThemesManagerDemo
//
//  Created by Tharindu Ketipearachchi on 2023-12-13.
//
import SwiftUI

struct ContentView: View {
    @StateObject var themeManager = ThemeManager()
    var body: some View {
        NavigationView {
            HomeView()
                .environmentObject(themeManager)
                .onAppear {
                    let theme = RemoteConfigProvider.shared.theme()
                    switch theme {
                    case 1:
                        themeManager.setTheme(Main())
                    case 2:
                        themeManager.setTheme(Asian())
                    default:
                        themeManager.setTheme(Main())
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
