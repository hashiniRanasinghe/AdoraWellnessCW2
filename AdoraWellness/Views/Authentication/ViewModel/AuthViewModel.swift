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
import GoogleSignIn

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
    @Published var isError = false
    @Published var isSuccess = false

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
            let userTypeEnum =
                UserType(rawValue: userType.lowercased()) ?? .student

            let user = User(
                id: result.user.uid, fullname: fullname, email: email,
                userType: userTypeEnum)

            let userData: [String: Any] = [
                "id": user.id,
                "fullname": user.fullname,
                "email": user.email,
                "userType": user.userType.rawValue,
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
            GoogleSignIn.GIDSignIn.sharedInstance.signOut()

            // Clear the user session
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
            print(
                "DEBUG: Failed to delete user account: \(error.localizedDescription)"
            )
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

    // always creates/updates user document in google
    func signInWithGoogle() async throws {
        guard
            let presentingViewController = UIApplication.shared.windows.first?
                .rootViewController
        else {
            throw NSError(
                domain: "GoogleSignIn", code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "No presenting view controller found"
                ])
        }

        do {
            let result = try await GoogleSignIn.GIDSignIn.sharedInstance.signIn(
                withPresenting: presentingViewController)

            guard let idToken = result.user.idToken?.tokenString else {
                throw NSError(
                    domain: "GoogleSignIn", code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Failed to get ID token"
                    ])
            }

            let accessToken = result.user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken, accessToken: accessToken)

            let authResult = try await Auth.auth().signIn(with: credential)
            self.userSession = authResult.user

            await createOrUpdateUser(from: authResult.user)
            await fetchUser()

        } catch {
            print(
                "DEBUG: Google Sign In failed with error: \(error.localizedDescription)"
            )
            self.alertMessage = "Google Sign In failed. Please try again."
            self.showAlert = true
            throw error
        }
    }

    // sets user data
    func createOrUpdateUser(from firebaseUser: FirebaseAuth.User) async {
        let user = User(
            id: firebaseUser.uid,
            fullname: firebaseUser.displayName ?? "Unknown User",
            email: firebaseUser.email ?? "",
            userType: UserType(rawValue: "student") ?? .student
        )

        let userData: [String: Any] = [
            "id": user.id,
            "fullname": user.fullname,
            "email": user.email,
            "userType": user.userType,
        ]

        do {
            try await Firestore.firestore()
                .collection("users")
                .document(user.id)
                .setData(userData)
        } catch {
            print(
                "DEBUG: Error creating/updating user: \(error.localizedDescription)"
            )
        }
    }
    func resetPassword(by email: String) async {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            isError = false
            isSuccess = true
            print("Password send to the mail: \(email)")
        } catch {
            print("Password reset error: \(error.localizedDescription)")
            isError = true
        }
    }

}
