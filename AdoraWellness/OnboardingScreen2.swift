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
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Text("Choose Your Path")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 60)
                }
                
                Spacer()
                
                // Instructor Option
                VStack(spacing: 20) {
                    Text("I want to teach & guide")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    // Instructor illustration placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.orange.opacity(0.1))
                            .frame(height: 150)
                        
                        HStack {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                            
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.green)
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
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Student Option
                VStack(spacing: 20) {
                    Text("I want to learn & practice")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    // Student illustration placeholder
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "figure.yoga")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
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
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer().frame(height: 50)
            }
        }
    }
}

#Preview {
    OnboardingScreen2()
}
