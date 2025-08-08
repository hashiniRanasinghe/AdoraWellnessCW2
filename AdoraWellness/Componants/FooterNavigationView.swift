//
//  FooterNavigationView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-08.
//

import SwiftUI

struct FooterNavigationView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Home indicator line
            Rectangle()
                .frame(width: 134, height: 5)
                .cornerRadius(2.5)
                .foregroundColor(.black)
                .padding(.top, 8)
                .padding(.bottom, 20)
            
            HStack {
                // Home
                VStack(spacing: 4) {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        .font(.title2)
                        .foregroundColor(selectedTab == 0 ? Color(red: 0.4, green: 0.3, blue: 0.8) : .gray)
                    Text("Home")
                        .font(.caption)
                        .foregroundColor(selectedTab == 0 ? Color(red: 0.4, green: 0.3, blue: 0.8) : .gray)
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    selectedTab = 0
                }
                
                // Discover
                VStack(spacing: 4) {
                    Image(systemName: selectedTab == 1 ? "doc.text.fill" : "doc.text")
                        .font(.title2)
                        .foregroundColor(selectedTab == 1 ? Color(red: 0.4, green: 0.3, blue: 0.8) : .gray)
                    Text("Discover")
                        .font(.caption)
                        .foregroundColor(selectedTab == 1 ? Color(red: 0.4, green: 0.3, blue: 0.8) : .gray)
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    selectedTab = 1
                }
                
                // Practice
                VStack(spacing: 4) {
                    Image(systemName: selectedTab == 2 ? "figure.yoga" : "figure.yoga")
                        .font(.title2)
                        .foregroundColor(selectedTab == 2 ? Color(red: 0.4, green: 0.3, blue: 0.8) : .gray)
                    Text("Practice")
                        .font(.caption)
                        .foregroundColor(selectedTab == 2 ? Color(red: 0.4, green: 0.3, blue: 0.8) : .gray)
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    selectedTab = 2
                }
                
                // Profile
                VStack(spacing: 4) {
                    Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                        .font(.title2)
                        .foregroundColor(selectedTab == 3 ? Color(red: 0.4, green: 0.3, blue: 0.8) : .gray)
                    Text("Profile")
                        .font(.caption)
                        .foregroundColor(selectedTab == 3 ? Color(red: 0.4, green: 0.3, blue: 0.8) : .gray)
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    selectedTab = 3
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34) // Safe area bottom padding
        }
        .background(Color.white)
    }
}
