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
    @Published var isError = false  //to use in reset password screen
    @Published var isSuccess = false  //to use in reset password screen
    @Published var showAccountCreatedScreen = false  //to use in profile setup screens

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
            print("error: \(error.localizedDescription)")
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

            //convert user type
            let userTypeEnum =
                UserType(rawValue: userType.lowercased()) ?? .student
            //create swift user object
            let user = User(
                id: result.user.uid, fullname: fullname, email: email,
                userType: userTypeEnum)
            //prapare data to db
            let userData: [String: Any] = [
                "id": user.id,
                "fullname": user.fullname,
                "email": user.email,
                "userType": user.userType.rawValue,
            ]
            //store data in db
            try await Firestore.firestore()
                .collection("users")
                .document(user.id)
                .setData(userData)

            await fetchUser()
            DispatchQueue.main.async {
                self.showAccountCreatedScreen = true
            }

        } catch {
            print(
                "error - Failed to create user with error \(error.localizedDescription)"
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

            //clear the user session
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print(
                "error - Failed to sign out with error \(error.localizedDescription)"
            )
        }
    }

    //delete acc
    func deleteAccount() async {
        guard let user = Auth.auth().currentUser else {
            print("Error: No user is currently logged in.")
            return
        }

        do {
            //delete the user from firestore
            try await Firestore.firestore()
                .collection("users")
                .document(user.uid)
                .delete()

            //delete the user from firebase auth
            try await user.delete()

            //clear the user session
            self.userSession = nil
            self.currentUser = nil
            print("user account deleted successfully.")
        } catch {
            print(
                "feild to delete- \(error.localizedDescription)"
            )
            self.alertMessage = Utils.userFriendlyErrorMessage(from: error)
            self.showAlert = true
        }
    }

    //get user data
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }  //returns nil if fails
        guard
            let snapshot = try? await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()
        else { return }
        //convert the document db data into a user object
        self.currentUser = try? snapshot.data(as: User.self)
    }

    //    https://firebase.google.com/docs/auth/ios/google-signin
    // always creates/updates user document in google
    func signInWithGoogle() async throws {
        //get the active window
        guard
            let windowScene = UIApplication.shared.connectedScenes.first
                as? UIWindowScene,
            let rootViewController = windowScene.windows.first?
                .rootViewController
        else {
            throw NSError(
                domain: "GoogleSignIn", code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "No presenting view controller found"
                ]
            )
        }

        do {
            //show the google ui
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController
            )

            //get the id token
            guard let idToken = result.user.idToken?.tokenString else {
                throw NSError(
                    domain: "GoogleSignIn", code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Failed to get ID token"
                    ]
                )
            }

            //access token
            let accessToken = result.user.accessToken.tokenString

            //build firebase credentials
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )

            //sign into firebase with Google credentials
            let authResult = try await Auth.auth().signIn(with: credential)
            self.userSession = authResult.user

            await createOrUpdateUser(from: authResult.user)
            await fetchUser()

        } catch {
            print("Google Sign In failed: \(error.localizedDescription)")
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
                "error creating/updating user: \(error.localizedDescription)"
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
