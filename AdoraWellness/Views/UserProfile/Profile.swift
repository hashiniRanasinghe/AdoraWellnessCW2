//
//  UserProfileView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-08.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteAlert = false

    var body: some View {
        if let user = viewModel.currentUser {
            NavigationStack {

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .center, spacing: 0) {
                            Spacer()
                            Spacer()

                            VStack(spacing: 32) {
                                //profile
                                VStack(spacing: 20) {
                                    AvatarView(
                                        initials: user.initials, size: 120)
                                    //user info
                                    VStack(spacing: 8) {
                                        Text(user.fullname)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)

                                        Text(user.email)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)

                                        Text(user.userType.rawValue.capitalized)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 20)

                                // btns
                                VStack(spacing: 16) {
                                    //edit profile bts
                                    Button(action: {
                                        //handle edit profile
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(
                                                systemName:
                                                    "person.crop.circle.fill"
                                            )
                                            .font(.title3)
                                            .foregroundColor(
                                                Color(
                                                    red: 0.4, green: 0.3,
                                                    blue: 0.8))

                                            Text("Edit Profile")
                                                .font(.headline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(20)
                                        .background(Color.white)
                                        .cornerRadius(16)
                                        .shadow(
                                            color: .black.opacity(0.05),
                                            radius: 5, x: 0, y: 2)
                                    }

                                    //logout btn
                                    Button(action: {
                                        viewModel.signOut()
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(
                                                systemName:
                                                    "rectangle.portrait.and.arrow.right"
                                            )
                                            .font(.title3)
                                            .foregroundColor(.orange)

                                            Text("Sign Out")
                                                .font(.headline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(20)
                                        .background(Color.white)
                                        .cornerRadius(16)
                                        .shadow(
                                            color: .black.opacity(0.05),
                                            radius: 5, x: 0, y: 2)
                                    }

                                    //delete acc btn
                                    Button(action: {
                                        showingDeleteAlert = true
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "trash")
                                                .font(.title3)
                                                .foregroundColor(.red)

                                            Text("Delete Account")
                                                .font(.headline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.red)

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(20)
                                        .background(Color.white)
                                        .cornerRadius(16)
                                        .shadow(
                                            color: .black.opacity(0.05),
                                            radius: 5, x: 0, y: 2)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 100)
                            }
                        }
                    }

                    FooterNavigationView(
                        selectedTab: user.userType == .student ? 3 : 2,
                        userRole: user.userType
                    )
                }
                .background(Color.white)
                .navigationBarBackButtonHidden(true)
                .ignoresSafeArea(.all, edges: .bottom)
                .navigationBarTitleDisplayMode(.inline)
                .alert("Delete Account", isPresented: $showingDeleteAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        Task {
                            await viewModel.deleteAccount()
                        }
                    }

                } message: {
                    Text(
                        "Are you sure you want to delete your account? This action cannot be undone."
                    )
                }
            }
        }
    }
}
