//
//  Dashboard.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-08.
//
//
// FooterNavigationView.swift
// AdoraWellness
//

import SwiftUI

struct DashboardView: View {
    @State private var progress: Double = 0.72
    @EnvironmentObject var viewModel : AuthViewModel
    
    var body: some View {
   if let user = viewModel.currentUser {
       NavigationStack {
           VStack(spacing: 0) {
               ScrollView {
                   VStack(alignment: .leading, spacing: 0) {
                       // Header section
                       
                       NavigationLink(destination: StudentProfileSetupView().environmentObject(viewModel)) {
                           Text("StudentProfileSetupView")
                               .font(.headline)
                               .fontWeight(.semibold)
                               .foregroundColor(.white)
                               .frame(maxWidth: .infinity)
                               .frame(height: 50)
                               .background(Color(red: 0.4, green: 0.3, blue: 0.8))
                               .cornerRadius(25)
                       }
                       
                       Spacer()
                       Spacer()
                       VStack(alignment: .leading, spacing: 0) {
                           HStack {

                               HStack(spacing: 12) {
                                   // Profile image
                                   Text(user.initials)
                                       .font(.title)
                                       .fontWeight(.semibold)
                                       .foregroundColor(.white)
                                       .frame(width: 62, height: 62)
                                       .background(Color(.systemGray3))
                                       .clipShape(Circle())
                                   
                                   VStack(alignment: .leading, spacing: 4) {
                                       Text("\(Utils.greetingMessage()), \(user.fullname.components(separatedBy: " ").first ?? "")")
                                           .font(.title2)
                                           .fontWeight(.bold)
                                           .foregroundColor(.primary)

                                       
                                       Text(Utils.formattedDate())
                                           .font(.subheadline)
                                           .foregroundColor(.secondary)
                                   }
                               }
                               
                               Spacer()
                               
                               Button(action: {
                                   // Handle notification
                               }) {
                                   Image(systemName: "bell")
                                       .font(.title2)
                                       .foregroundColor(.primary)
                               }
                           }
                           .padding(.horizontal, 24)
                           .padding(.top, 20)
                           .padding(.bottom, 32)
                           
                           // Progress card
                           VStack(spacing: 20) {
                               HStack(alignment: .center, spacing: 32) {
                                   // Left side - Progress ring
                                   VStack(alignment: .leading, spacing: 8) {
                                       HStack(spacing: 8) {
                                           Image(systemName: "medal")
                                               .foregroundColor(.secondary)
                                           Text("Level 2")
                                               .font(.subheadline)
                                               .foregroundColor(.secondary)
                                       }
                                       
                                       ProgressRingView(progress: progress)
                                           .frame(width: 80, height: 80)
                                   }
                                   
                                   // Right side - Stats
                                   VStack(alignment: .leading, spacing: 12) {
                                       HStack(spacing: 8) {
                                           Image(systemName: "bolt")
                                               .foregroundColor(.secondary)
                                           Text("7-day streak")
                                               .font(.subheadline)
                                               .foregroundColor(.secondary)
                                       }
                                       
                                       VStack(alignment: .leading, spacing: 4) {
                                           Text("This week points")
                                               .font(.caption)
                                               .foregroundColor(.secondary)
                                           
                                           Text("35/50 pts")
                                               .font(.title2)
                                               .fontWeight(.bold)
                                               .foregroundColor(.primary)
                                       }
                                   }
                                   
                                   Spacer()
                               }
                           }
                           .padding(24)
                           .background(Color(.systemGray6))
                           .cornerRadius(16)
                           .padding(.horizontal, 24)
                           .padding(.bottom, 32)
                           
                           // Continue session section
                           VStack(alignment: .leading, spacing: 16) {
                               Text("Pick up where you left off")
                                   .font(.title3)
                                   .fontWeight(.bold)
                                   .foregroundColor(.primary)
                                   .padding(.horizontal, 24)
                               
                               VStack(spacing: 12) {
                                   HStack {
                                       VStack(alignment: .leading, spacing: 4) {
                                           Text("Morning Flow")
                                               .font(.headline)
                                               .fontWeight(.medium)
                                               .foregroundColor(.primary)
                                           
                                           // Progress bar
                                           ProgressView(value: 0.6)
                                               .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.4, green: 0.3, blue: 0.8)))
                                               .scaleEffect(x: 1, y: 2, anchor: .center)
                                       }
                                       
                                       Spacer()
                                       
                                       Text("15 min remaining")
                                           .font(.subheadline)
                                           .foregroundColor(.secondary)
                                   }
                                   
                                   Button(action: {
                                       // Handle continue session
                                   }) {
                                       Text("Continue Session")
                                           .font(.headline)
                                           .fontWeight(.semibold)
                                           .foregroundColor(.white)
                                           .frame(maxWidth: .infinity)
                                           .frame(height: 50)
                                           .background(Color(red: 0.4, green: 0.3, blue: 0.8))
                                           .cornerRadius(25)
                                   }
                               }
                               .padding(20)
                               .background(Color.white)
                               .cornerRadius(16)
                               .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                               .padding(.horizontal, 24)
                           }
                           .padding(.bottom, 32)
                           
                           // Today's recommendation
                           VStack(alignment: .leading, spacing: 16) {
                               HStack {
                                   Text("Today's Recommendation")
                                       .font(.title3)
                                       .fontWeight(.bold)
                                       .foregroundColor(.primary)
                                   
                                   Spacer()
                                   
                                   Button(action: {
                                       // Handle more options
                                   }) {
                                       Image(systemName: "ellipsis")
                                           .foregroundColor(.secondary)
                                   }
                               }
                               .padding(.horizontal, 24)
                               
                               HStack(spacing: 16) {
                                   // Session icon
                                   ZStack {
                                       Circle()
                                           .fill(Color(.systemGray6))
                                           .frame(width: 60, height: 60)
                                       
                                       Image(systemName: "figure.yoga")
                                           .font(.title2)
                                           .foregroundColor(.secondary)
                                   }
                                   
                                   VStack(alignment: .leading, spacing: 4) {
                                       Text("Morning Energizer")
                                           .font(.headline)
                                           .fontWeight(.bold)
                                           .foregroundColor(.primary)
                                       
                                       Text("Beginner Level Light Yoga")
                                           .font(.subheadline)
                                           .foregroundColor(.secondary)
                                   }
                                   
                                   Spacer()
                                   
                                   Text("20 min")
                                       .font(.subheadline)
                                       .fontWeight(.medium)
                                       .foregroundColor(.secondary)
                               }
                               .padding(.horizontal, 24)
                               .padding(.bottom, 100) // Space for footer
                           }
                       }
                   }
               }
               
               FooterNavigationView(selectedTab: 0)

           }
           .background(Color.white)
           .ignoresSafeArea(.all, edges: .bottom)
       }        .navigationBarHidden(true)
        }

    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
