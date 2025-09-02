//
//  RoleGuard.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-21.
//

import SwiftUI

struct RoleGuard<Content: View>: View {
    let allowedRole: UserType
    @EnvironmentObject var authViewModel: AuthViewModel
    let content: () -> Content

    var body: some View {
        Group {
            // if the logged-in user’s userType matches the allowedRole show the relevant content
            if let user = authViewModel.currentUser {
                if user.userType == allowedRole {
                    content()
                } else {
                    VStack(spacing: 20) {
                        Text(" -- Access Denied -- ")
                            .font(.title2)
                            .foregroundColor(.red)

                        Button(action: {
                            authViewModel.signOut()
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
                                color: .black.opacity(0.05), radius: 5, x: 0,
                                y: 2)
                        }
                    }
                    .padding()
                }
            } else {
                Text("Loading…")
            }
        }
    }
}
