//
//  AdoraWellnessApp.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-05.
//

import Firebase
import SwiftUI
import GoogleSignIn
import CoreData

@main
struct AdoraWellnessApp: App {
    @StateObject var viewModel = AuthViewModel()
    let persistentContainer = CoreDataManager.shared.persistentContainer
     
    init() {
        FirebaseApp.configure()
        
        //configure google sign in
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else {
            fatalError("GoogleService-Info.plist not found or CLIENT_ID missing")
        }
        
        GoogleSignIn.GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
    }
    

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environment(\.managedObjectContext, persistentContainer.viewContext)
        }
    }
}
