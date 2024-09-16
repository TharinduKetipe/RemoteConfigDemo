//
//  ThemesManagerDemoApp.swift
//  ThemesManagerDemo
//
//  Created by Tharindu Ketipearachchi on 2023-12-13.
//

import SwiftUI
import Firebase

@main
struct ThemesManagerDemoApp: App {
    init() {
        FirebaseApp.configure()
        RemoteConfigProvider.shared.fetchCloudValues()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
