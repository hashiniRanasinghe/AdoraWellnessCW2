//
//  OnboardingScreen1.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-05.
//

import SwiftUI

struct OnboardingScreen1: View {
    @State private var showNextScreen = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    ZStack {

                        if let logoImage = UIImage(
                            named: "OnlineYogaClassIMG.jpeg")
                        {
                            Image(uiImage: logoImage)
                                .resizable()
                                .frame(width: 400, height: 400)
                        }
                    }

                    VStack(spacing: 16) {
                        Text("Your Personal Yoga &")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)

                        Text("Pilates Journey Starts Here")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)

                        Text(
                            "Find your balance, connect with your breath, and move with purpose. Begin your mindful movement journey today."
                        )
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }

                    VStack(spacing: 16) {
                        Button(action: {
                            showNextScreen = true
                        }) {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    Color(red: 0.4, green: 0.3, blue: 0.8)
                                )
                                .cornerRadius(28)
                        }
                        .padding(.horizontal, 40)

                        //                        NavigationLink(destination: LoginView()) {
                        //                            Text("Sign in")
                        //                                .font(.headline)
                        //                                .foregroundColor(
                        //                                    Color(red: 0.4, green: 0.3, blue: 0.8))
                        //                        }

                    }

                    Spacer().frame(height: 50)
                }
            }
            .fullScreenCover(isPresented: $showNextScreen) {
                NavigationStack {
                    OnboardingScreen2()
                }
            }
        }
    }
}

#Preview {
    OnboardingScreen1()
}
