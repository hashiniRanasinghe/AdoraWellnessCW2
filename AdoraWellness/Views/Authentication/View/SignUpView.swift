//
//  SignUpView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-07.
//

import SwiftUI

struct SignUpView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var fullname: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel : AuthViewModel
    
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

                    // Form fields
                    VStack(spacing: 24) {
                        InputView(
                            text: $name,
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

                    // Register button
                    VStack(spacing: 16) {
                        Button(action: {
                            Task{
                                try await viewModel.createUser(withEmail: email, password: password, fullname: fullname)
                            }
                        }) {
                            Text("Register")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    Color(red: 0.4, green: 0.3, blue: 0.8)
                                )
                                .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                    // Sign In link
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
                        Spacer()
                    }                    .padding(.horizontal, 24)
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
            .background(Color.white)
        }
        .navigationBarHidden(true)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
