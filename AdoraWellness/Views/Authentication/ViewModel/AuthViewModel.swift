//
//  AuthViewModel.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-07.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation

//form validator
protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var alertMessage: String?
    @Published var showAlert = false

    init() {
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchUser()
        }
    }

    //login
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(
                withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: \(error.localizedDescription)")
            self.alertMessage = Utils.userFriendlyErrorMessage(from: error)
            self.showAlert = true
        }
    }

    //register
    func createUser(
        withEmail email: String, password: String, fullname: String,
        userType: String
    ) async throws {
        do {
            let result = try await Auth.auth().createUser(
                withEmail: email, password: password)
            self.userSession = result.user

            let user = User(
                id: result.user.uid, fullname: fullname, email: email,
                userType: userType)

            let userData: [String: Any] = [
                "id": user.id,
                "fullname": user.fullname,
                "email": user.email,
                "userType": userType,
            ]

            try await Firestore.firestore()
                .collection("users")
                .document(user.id)
                .setData(userData)

            await fetchUser()
        } catch {
            print(
                "DEBUG: Failed to create user with error \(error.localizedDescription)"
            )
            self.alertMessage = Utils.userFriendlyErrorMessage(from: error)
            self.showAlert = true
        }
    }

    //logout
    func signOut() {
        do {
            try Auth.auth().signOut()
            //clear the user session
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print(
                "DEBUG: Failed to sign out with error \(error.localizedDescription)"
            )
        }
    }

    //delete acc
    func deleteAccount() async {
        guard let user = Auth.auth().currentUser else {
            print("DEBUG: No user is currently logged in.")
            return
        }

        do {
           //delete the user from firestire
            try await Firestore.firestore()
                .collection("users")
                .document(user.uid)
                .delete()

    //delete the user from firebase auth
            try await user.delete()

//clear the user session
            self.userSession = nil
            self.currentUser = nil
            print("DEBUG: User account deleted successfully.")
        } catch {
            print("DEBUG: Failed to delete user account: \(error.localizedDescription)")
            self.alertMessage = Utils.userFriendlyErrorMessage(from: error)
            self.showAlert = true
        }
    }

    //get user data
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard
            let snapshot = try? await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()
        else { return }
        self.currentUser = try? snapshot.data(as: User.self)
    }

}
