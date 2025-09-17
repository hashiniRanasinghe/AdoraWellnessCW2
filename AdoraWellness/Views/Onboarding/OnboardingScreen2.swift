//
//  OnboardingScreen2.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-05.
//

import SwiftUI

struct OnboardingScreen2: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
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
                    //title section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose Your Path")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)

                    ScrollView {
                        VStack(spacing: 30) {
                            //option 1 - instructor
                            VStack(spacing: 10) {
                                Text("I want to teach & guide")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)

                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            Color(
                                                UIColor
                                                    .secondarySystemBackground)
                                        )
                                        .frame(height: 150)

                                    if let logoImage = UIImage(
                                        named: "InstructorIMG.jpeg")
                                    {
                                        Image(uiImage: logoImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 200, height: 150)
                                            .clipped()
                                            .cornerRadius(20)
                                    }
                                }
                                .padding(.horizontal, 40)

                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Circle()
                                            .fill(Color.secondary.opacity(0.5))
                                            .frame(width: 6, height: 6)
                                        Text("Create your instructor profile")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    HStack {
                                        Circle()
                                            .fill(Color.secondary.opacity(0.5))
                                            .frame(width: 6, height: 6)
                                        Text("Schedule live sessions")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    HStack {
                                        Circle()
                                            .fill(Color.secondary.opacity(0.5))
                                            .frame(width: 6, height: 6)
                                        Text("Build your student community")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    HStack {
                                        Circle()
                                            .fill(Color.secondary.opacity(0.5))
                                            .frame(width: 6, height: 6)
                                        Text("Earn from your expertise")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 40)

                                NavigationLink(
                                    destination: SignUpView(
                                        userType: "instructor")
                                ) {
                                    Text("Continue as Instructor")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(
                                            Color(
                                                red: 0.4, green: 0.3, blue: 0.8)
                                        )
                                        .cornerRadius(28)
                                }
                                .padding(.horizontal, 40)
                            }

                            //option 2 - student
                            VStack(spacing: 10) {
                                Text("I want to learn & practice")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)

                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            Color(
                                                UIColor
                                                    .secondarySystemBackground)
                                        )
                                        .frame(height: 150)

                                    if let logoImage = UIImage(
                                        named: "StudentIMG3.jpeg")
                                    {
                                        Image(uiImage: logoImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 200, height: 150)
                                            .clipped()
                                            .cornerRadius(20)
                                    }
                                }
                                .padding(.horizontal, 40)

                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Circle()
                                            .fill(Color.secondary.opacity(0.5))
                                            .frame(width: 6, height: 6)
                                        Text("AI-guided solo sessions")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    HStack {
                                        Circle()
                                            .fill(Color.secondary.opacity(0.5))
                                            .frame(width: 6, height: 6)
                                        Text("Find expert instructors")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    HStack {
                                        Circle()
                                            .fill(Color.secondary.opacity(0.5))
                                            .frame(width: 6, height: 6)
                                        Text("Track my progress")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    HStack {
                                        Circle()
                                            .fill(Color.secondary.opacity(0.5))
                                            .frame(width: 6, height: 6)
                                        Text("Join live classes")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 40)

                                NavigationLink(
                                    destination: SignUpView(userType: "student")
                                ) {
                                    Text("Continue as Student")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(
                                            Color(
                                                red: 0.4, green: 0.3, blue: 0.8)
                                        )
                                        .cornerRadius(28)
                                }
                                .padding(.horizontal, 40)
                            }

                            Spacer().frame(height: 50)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
#Preview {
    OnboardingScreen2()
}
