//
//  ResetPasswordView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-09.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var email: String = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToCheckEmail = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {

                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 32)

                VStack(alignment: .leading, spacing: 0) {
                    //title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reset Password")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Text(
                            "Please enter your email, we will send verification code to your email."
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)

                    //feild
                    VStack(spacing: 24) {
                        InputView(
                            text: $email,
                            title: "Email",
                            placeholder: "example@email.com"
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                    //btn
                    VStack(spacing: 16) {
                        Button(action: {
                            Task {
                                await viewModel.resetPassword(by: email)
                            }
                        }) {
                            Text("Send")
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
                        .alert("Error", isPresented: $viewModel.isError) {
                            Button("OK", role: .cancel) {}
                        } message: {
                            Text(
                                "Failed to send password reset email. Please try again."
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                    Spacer()
                        .padding(.bottom, 8)
                }
            }
            .background(Color.white)

            .onChange(of: viewModel.isSuccess) {
                if viewModel.isSuccess {
                    navigateToCheckEmail = true
                    viewModel.isSuccess = false
                }
            }
            .navigationDestination(isPresented: $navigateToCheckEmail) {
                CheckEmailView(email: email)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true) 
    }
}

//form validation
extension ResetPasswordView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@")
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
