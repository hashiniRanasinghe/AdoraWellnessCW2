//
//  CheckEmailView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-09.
//

import SwiftUI

struct CheckEmailView: View {
    let email: String
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {

                //header
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
                .padding(.bottom, 40)

                VStack(alignment: .center, spacing: 0) {

                    Text("Check Your Email")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.bottom, 32)

                    VStack(spacing: 8) {
                        Text(
                            "We have sent password reset instructions to your email. Please check your inbox and follow the link to reset your password."
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)

                        Text(email)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                    //resend
                    HStack(spacing: 4) {
                        Text("If you didn't receive a code?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Button(action: {
                            Task {
                                await viewModel.resetPassword(by: email)
                            }
                        }) {
                            Text("Resend")
                                .font(.subheadline)
                                .foregroundColor(
                                    Color(red: 0.4, green: 0.3, blue: 0.8)
                                )
                                .fontWeight(.medium)
                        }
                    }
                    .padding(.bottom, 40)

                    //open mail
                    Button(action: {
                        openMailApp()
                    }) {
                        Text("Open Mail")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.4, green: 0.3, blue: 0.8))
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 24)
                    .alert("Info", isPresented: $viewModel.showAlert) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text(viewModel.alertMessage ?? "Something went wrong")
                    }

                    NavigationLink(destination: LoginView()) {
                        Text("Back To Login")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.4, green: 0.3, blue: 0.8))
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                        .padding(.bottom, 8)
                }
            }
            .background(Color.white)
            .navigationBarBackButtonHidden(true)
        }
        .navigationBarHidden(true)
    }

    private func openMailApp() {
        if let url = URL(string: "message://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                //fallback to setting app mail
                if let settingsUrl = URL(string: "App-Prefs:root=MAIL") {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        }
    }
}

struct CheckEmailView_Previews: PreviewProvider {
    static var previews: some View {
        CheckEmailView(email: "johndoe@email.com")
    }
}
