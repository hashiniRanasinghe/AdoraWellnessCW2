//
//  SignUpView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-07.
//

import SwiftUI

struct SignUpView: View {
    let userType: String

    @State private var email: String = ""
    @State private var fullname: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {

                VStack(alignment: .leading, spacing: 0) {
                    //welcom section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sign Up")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Text("Create a new account")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .padding(.top, 20)

                    //feilds
                    VStack(spacing: 24) {
                        InputView(
                            text: $fullname,
                            title: "Name",
                            placeholder: "Your name"
                        )

                        InputView(
                            text: $email,
                            title: "Email",
                            placeholder: "Your email"
                        )

                        InputView(
                            text: $password,
                            title: "Password",
                            placeholder: "Your password",
                            isSecureField: true
                        )

                        InputView(
                            text: $confirmPassword,
                            title: "Confirm Password",
                            placeholder: "Confirm Your password",
                            isSecureField: true
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                    // register btn
                    VStack(spacing: 16) {
                        Button(action: {
                            Task {
                                try await viewModel.createUser(
                                    withEmail: email, password: password,
                                    fullname: fullname, userType: userType)
                            }
                        }) {
                            Text("Register")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    formIsValid
                                        ? Color(red: 0.4, green: 0.3, blue: 0.8)
                                        : Color.gray
                                )
                                .cornerRadius(25)
                        }
                        .disabled(!formIsValid)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                    // login link
                    HStack {
                        Spacer()
                        NavigationLink(destination: LoginView()) {
                            HStack(spacing: 2) {
                                Text("Have an account?")
                                    .foregroundColor(.secondary)
                                Text("Sign In")
                                    .foregroundColor(
                                        Color(red: 0.4, green: 0.3, blue: 0.8)
                                    )
                                    .fontWeight(.medium)
                            }
                            .font(.subheadline)
                        }
                        .alert("Error", isPresented: $viewModel.showAlert) {
                            Button("OK", role: .cancel) {}
                        } message: {
                            Text(
                                viewModel.alertMessage ?? "Something went wrong"
                            )
                        }
                        Spacer()
                    }.padding(.horizontal, 24)
                        .padding(.bottom, 32)

                    //t&c
                    VStack(spacing: 4) {
                        HStack {
                            Spacer()
                            VStack(spacing: 4) {
                                Text("By clicking Register, you agree to our")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                HStack(spacing: 4) {
                                    Button(action: {
                                    }) {
                                        Text("Terms")
                                            .font(.caption)
                                            .foregroundColor(
                                                Color(
                                                    red: 0.4, green: 0.3,
                                                    blue: 0.8)
                                            )
                                            .underline()
                                    }

                                    Text("and")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Button(action: {
                                    }) {
                                        Text("Data Policy.")
                                            .font(.caption)
                                            .foregroundColor(
                                                Color(
                                                    red: 0.4, green: 0.3,
                                                    blue: 0.8)
                                            )
                                            .underline()
                                    }
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                    Spacer()

                }
            }
            .background(Color(UIColor.systemBackground))
        }
        .navigationBarHidden(true)
    }
}

//form validation
extension SignUpView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        //" test@example.com " to "test@example.com"
        let trimmedFullname = fullname.trimmingCharacters(
            in: .whitespacesAndNewlines)
        // " MYName  " to "MYName"

        guard !trimmedEmail.isEmpty,
            !trimmedFullname.isEmpty,
            !password.isEmpty
        else {
            return false
        }

        guard password.count > 6,
            confirmPassword == password
        else {
            return false
        }
        return trimmedEmail.contains("@") && trimmedEmail.contains(".")
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(userType: "student")
    }
}
