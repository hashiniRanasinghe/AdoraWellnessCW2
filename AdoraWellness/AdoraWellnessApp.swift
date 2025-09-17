//
//  AdoraWellnessApp.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-05.
//

import CoreData
import Firebase
import GoogleSignIn
import SwiftUI
import UserNotifications

@main
struct AdoraWellnessApp: App {
    @StateObject var viewModel = AuthViewModel()
    let persistentContainer = CoreDataManager.shared.persistentContainer

    init() {
        FirebaseApp.configure()

        // configure google sign in
        guard
            let path = Bundle.main.path(
                forResource: "GoogleService-Info", ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: path),
            let clientId = plist["CLIENT_ID"] as? String
        else {
            fatalError(
                "GoogleService-Info.plist not found or CLIENT_ID missing")
        }
        GoogleSignIn.GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: clientId)

        //request notification permissions
        let center = UNUserNotificationCenter.current()
        center.delegate = NotificationDelegate.shared  //set delegate
        center.requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
            if granted {
                print("granted")
            } else {
                print("denied: \(error?.localizedDescription ?? "unknown")")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environment(
                    \.managedObjectContext, persistentContainer.viewContext)
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    //show banner even when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (
            UNNotificationPresentationOptions
        ) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
