//
//  FooterNavigationView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-08.
//

import SwiftUI

struct FooterNavigationView: View {
    let selectedTab: Int
    @State private var navigateToProfile = false
    @State private var navigateToDiscover = false
    @State private var navigateToPractice = false
    @State private var navigateToHome = false
    
    init(selectedTab: Int = 0) {
        self.selectedTab = selectedTab
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
                    if selectedTab != 0 {
                        navigateToHome = true
                    }
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
                    if selectedTab != 1 {
                        navigateToDiscover = true
                    }
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
                    if selectedTab != 2 {
                        navigateToPractice = true
                    }
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
                    if selectedTab != 3 {
                        navigateToProfile = true
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34) // Safe area bottom padding
        }
        .background(Color.white)
        // Hidden NavigationLinks
        .background(
            Group {
                NavigationLink(destination: DashboardView(), isActive: $navigateToHome) { EmptyView() }
//                NavigationLink(destination: DiscoverView(), isActive: $navigateToDiscover) { EmptyView() }
//                NavigationLink(destination: PracticeView(), isActive: $navigateToPractice) { EmptyView() }
                NavigationLink(destination: UserProfileView(), isActive: $navigateToProfile) { EmptyView() }
            }
        )
    }
}
