//
//  AuthViewModel.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-07.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore


class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        
        
    }
    
    // Sign in existing user
    func signIn(withEmail email: String, password: String) async throws {
        print ("print 1")

    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            
            let userData: [String: Any] = [
                "id": user.id,
                "fullname": user.fullname,
                "email": user.email,
            ]
            
            try await Firestore.firestore()
                .collection("users")
                .document(user.id)
                .setData(userData)
            
            await fetchUser()
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
            throw error
        }
    }
     
    // Sign out current user
    func signOut() {

    }
    
    // Delete account
    func deleteAccount() {
    }
    
    // Fetch current user from Firestore
    func fetchUser() async {

    }
}
