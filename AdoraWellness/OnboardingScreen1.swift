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
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Illustration placeholder - replace with your meditation illustration
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: 300, height: 300)
                    
                    Image(systemName: "figure.mind.and.body")
                        .font(.system(size: 120))
                        .foregroundColor(.purple)
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
                    
                    Text("Find your balance, connect with your breath, and move with purpose. Begin your mindful movement journey today.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }
                
                Spacer()
                
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
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 40)
                    
                    Button(action: {
                        // Handle sign in
                    }) {
                        Text("Sign in")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                    }
                }
                
                Spacer().frame(height: 50)
            }
        }
        .fullScreenCover(isPresented: $showNextScreen) {
            OnboardingScreen2()
        }
    }
}

#Preview {
    OnboardingScreen1()
}
