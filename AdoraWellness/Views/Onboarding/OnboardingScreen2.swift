//
//  OnboardingScreen2.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-05.
//

import SwiftUI

struct OnboardingScreen2: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            ScrollView {
            VStack(spacing: 30) {
                VStack(spacing: 8) {
                    Text("Choose Your Path")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 30)
                        .padding(.bottom,-25)
                }
                
                Spacer()
                
                //option 1 - instructor
                VStack(spacing: 10) {
                    Text("I want to teach & guide")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .frame(height: 150)
                        
                        if let logoImage = UIImage(named: "InstructorIMG.jpeg") {
                            Image(uiImage: logoImage)
                                .resizable()
                                .frame(width: 200, height: 200)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                            Text("Create your instructor profile")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                            Text("Schedule live sessions")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                            Text("Build your student community")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                            Text("Earn from your expertise")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Button(action: {
                        // Handle instructor path
                    }) {
                        Text("Continue as Instructor")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.4, green: 0.3, blue: 0.8))
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                //option 2 - student
                VStack(spacing: 20) {
                    Text("I want to learn & practice")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .frame(height: 150)
                        
                        if let logoImage = UIImage(named: "StudentIMG3.jpeg") {
                            Image(uiImage: logoImage)
                                .resizable()
                                .frame(width: 200, height: 200)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                            Text("AI-guided solo sessions")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                            Text("Find expert instructors")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                            Text("Track my progress")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                            Text("Join live classes")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Button(action: {
                        // Handle student path
                    }) {
                        Text("Continue as Student")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.4, green: 0.3, blue: 0.8))
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

#Preview {
    OnboardingScreen2()
}
