//
//  LoginView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-06.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var viewModel : AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {

                VStack(alignment: .leading, spacing: 0) {
                    //welcom section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome Back 👋")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Text("Sign to your account")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .padding(.top, 20)

                    //form feilds
                    VStack(spacing: 24) {
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
                    }
                    .padding(.horizontal, 24)

                    //forgot password
                    HStack {
                        Button(action: {
                            // Handle forgot password
                        }) {
                            Text("Forgot Password?")
                                .font(.subheadline)
                                .foregroundColor(
                                    Color(red: 0.4, green: 0.3, blue: 0.8))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 32)

                    // btns section
                    VStack(spacing: 16) {
                        Button(action: {
                            Task{
                                try await viewModel.signIn(withEmail: email, password: password)
                            }
                        }) {
                            Text("Login")
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

                        Button(action: {
                            // Handle Face ID login
                        }) {
                            Text("Login in with Face ID")
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

                    HStack {
                        Spacer()
                        NavigationLink(destination: SignUpView()) {
                            HStack(spacing: 2) {
                                Text("Don't have an account?")
                                    .foregroundColor(.secondary)
                                Text("Sign Up")
                                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                                    .fontWeight(.medium)
                            }
                            .font(.subheadline)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                    // sso
                    VStack(spacing: 16) {
                        Text("Or with")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)

                        VStack(spacing: 12) {
                            //google
                            Button(action: {
                                // Handle Google sign in
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "globe")
                                        .foregroundColor(.black)
                                        .font(.title3)
                                    Text("Sign in with Google")
                                        .foregroundColor(.black)
                                        .font(.headline)
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .frame(height: 50)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color(.systemGray4), lineWidth: 1)
                                )
                            }

                            //apple
                            Button(action: {
                                // Handle Apple sign in
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "applelogo")
                                        .foregroundColor(.black)
                                        .font(.title3)
                                    Text("Sign in with Apple")
                                        .foregroundColor(.black)
                                        .font(.headline)
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .frame(height: 50)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color(.systemGray4), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    HStack {
                        Spacer()
                        Rectangle()
                            .frame(width: 134, height: 5)
                            .cornerRadius(2.5)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.bottom, 8)
                }
            }
            .background(Color.white)
        }
        .navigationBarHidden(true)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}


//https://adorawellnessioscw2.firebaseapp.com/__/auth/handler
