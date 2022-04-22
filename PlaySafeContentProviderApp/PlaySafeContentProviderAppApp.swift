//
//  PlaySafeContentProviderAppApp.swift
//  PlaySafeContentProviderApp
//
//  Created by Calvin Lau on 10/04/2022.
//

import SwiftUI

@main
struct PlaySafeContentProviderAppApp: App {
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}

let apiBaseUrl: String = "http://192.168.1.215:8000"
