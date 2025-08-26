//
//  SplashScreen.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-05
//

import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.3, blue: 0.8),
                    Color(red: 0.5, green: 0.4, blue: 0.9),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "leaf.circle")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .opacity(0.9)

                Text("ADORA")
                    .font(.system(size: 32, weight: .light, design: .default))
                    .foregroundColor(.white)
                    .tracking(8)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                isActive = true
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            destinationView()
        }
    }

    @ViewBuilder
    private func destinationView() -> some View {
        let isFirstLaunch = !UserDefaults.standard.bool(
            forKey: "hasLaunchedBefore")

        if isFirstLaunch {
            //1st launch -> onboarding
            OnboardingScreen1()
                .onAppear {
                    UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                }

        } else if viewModel.showAccountCreatedScreen {
            //registration -> profile setup
            if let currentUser = viewModel.currentUser {
                if currentUser.userType == .student {
                    StudentProfileSetupView()
                        .environmentObject(viewModel)
                } else if currentUser.userType == .instructor {
                    InstructorProfileSetupView()
                        .environmentObject(viewModel)
                }
            } else {
                //fetching current user
                VStack {
                    ProgressView()
                    Text("Loading account...")
                }
            }

        } else if viewModel.userSession == nil {
            //no user session -> login
            LoginView()

        } else if viewModel.currentUser == nil {
            //user data loading
            VStack {
                ProgressView()
                Text("Loading...")
            }

        } else if let currentUser = viewModel.currentUser {
            //logged in -> dashboard
            if currentUser.userType == .student {
                RoleGuard(allowedRole: .student) {
                    DashboardView()
                        .environmentObject(viewModel)
                }
            } else if currentUser.userType == .instructor {
                RoleGuard(allowedRole: .instructor) {
                    InstructorDashboardView()
                        .environmentObject(viewModel)
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
}
