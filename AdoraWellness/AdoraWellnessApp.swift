//
//  AdoraWellnessApp.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-05.
//

import SwiftUI

@main
struct AdoraWellnessApp: App {
    @StateObject var viewModel = AuthViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel) 
        }
    }
}
