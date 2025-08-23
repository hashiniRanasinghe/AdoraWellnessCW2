//
//  InstructorScheduleView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-23.
//

import SwiftUI

struct InstructorScheduleView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var sessionViewModel = SessionViewModel()
    @State private var sessions: [Session] = []
    @State private var selectedFilter = "All"
    @State private var showingAddSession = false
    @State private var sessionIcons: [String: String] = [:]

    private let filterOptions = [
        "All", "Today", "This Week", "History"
    ]
    
    var filteredSessions: [Session] {
        let now = Date()
        let calendar = Calendar.current
        
        switch selectedFilter {
        case "Today":
            return sessions.filter { session in
                calendar.isDate(session.date, inSameDayAs: now)
            }
        case "This Week":
            return sessions.filter { session in
                let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
                let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
                return session.date >= startOfWeek && session.date <= endOfWeek
            }
        case "History":
            return sessions.filter { session in
                let sessionDateTime = Utils.combineDateAndTime(date: session.date, timeString: session.endTime)
                return sessionDateTime < now
            }.sorted { $0.date > $1.date }
        default:
            return sessions.sorted { $0.date < $1.date }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Spacer()
                            
                            Text("Schedule")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            //add new session
                            Button(action: {
                                showingAddSession = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 32)
                        
                        //filter tabs
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 32) {
                                ForEach(filterOptions, id: \.self) { filter in
                                    Button(action: {
                                        selectedFilter = filter
                                    }) {
                                        VStack(spacing: 8) {
                                            Text(filter)
                                                .font(.headline)
                                                .fontWeight(.medium)
                                                .foregroundColor(
                                                    selectedFilter == filter
                                                    ? .primary : .secondary
                                                )
                                            
                                            Rectangle()
                                                .fill(
                                                    selectedFilter == filter
                                                    ? Color(
                                                        red: 0.4,
                                                        green: 0.3,
                                                        blue: 0.8)
                                                    : Color.clear
                                                )
                                                .frame(height: 2)
                                                .frame(
                                                    width: filter.count > 6
                                                    ? 80 : 60)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 32)
                        
                        //sessions list
                        if sessionViewModel.isLoading {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("Loading sessions...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        } else if filteredSessions.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)
                                Text("No Sessions Found")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Text("Create your first session to get started")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(filteredSessions) { session in
                                    InstructorSessionCard(
                                        session: session,
                                        iconName: sessionIcons[session.id]
                                    )
                                    .padding(.horizontal, 24)
                                }
                            }
                            .padding(.bottom, 100)
                        }
                    }
                }
                
                FooterNavigationView(selectedTab: 1, userRole: .instructor)
            }
            .background(Color.white)
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddSession, onDismiss: {
            Task {
                await loadSessions()
            }
        }) {
            AddSessionView()
                .environmentObject(authViewModel)
        }
        .task {
            await loadSessions()
        }
    }
    
    //load sessions instructor
    private func loadSessions() async {
        guard let instructorId = authViewModel.currentUser?.id else { return }
        sessions = await sessionViewModel.fetchSessionsByInstructor(instructorId: instructorId)
        assignIcons(to: sessions)
    }

    //assign icons to sessions
    private func assignIcons(to sessions: [Session]) {
        let availableIcons = [
            "figure.mind.and.body",
            "figure.core.training",
            "brain.head.profile",
            "heart.fill",
            "figure.strengthtraining.traditional",
            "figure.flexibility",
            "figure.walk"
        ]
        
        let shuffledIcons = availableIcons.shuffled()
        for (index, session) in sessions.enumerated() {
            let iconIndex = index % shuffledIcons.count
            sessionIcons[session.id] = shuffledIcons[iconIndex]
        }
    }
}

//session card
struct InstructorSessionCard: View {
    let session: Session
    let iconName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 16) {
                //session icon
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(width: 60, height: 60)
                        .background(Color.white)
                        .clipShape(Circle())

                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("\(session.registeredStudents.count) Students")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("\(session.durationMinutes) min")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(Utils.formatDate(session.date, format: "MMM d"))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text("\(session.startTime) - \(session.endTime)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text("$\(String(format: "%.0f", session.price))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text(session.level)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            //action button
            HStack(spacing: 12) {
                Button(action: {
                    // view session details or start session
                    print("Viewing session: \(session.title)")
                }) {
                    Text("View")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color(red: 0.4, green: 0.3, blue: 0.8))
                        .cornerRadius(20)
                }
                
                Spacer()
                
                //session type
                Text(session.sessionType)
                    .font(.caption)
                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.4, green: 0.3, blue: 0.8).opacity(0.1))
                    .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct InstructorScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        InstructorScheduleView()
            .environmentObject(AuthViewModel())
    }
}
