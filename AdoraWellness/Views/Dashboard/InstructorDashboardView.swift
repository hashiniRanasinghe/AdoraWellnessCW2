//
//  InstructorDashboardView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-23.
//

import SwiftUI

struct InstructorDashboardView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject private var sessionViewModel = SessionViewModel()
    @StateObject private var instructorViewModel = InstructorViewModel()

    @State private var monthSessions: [Session] = []
    @State private var weekSessions: [Session] = []
    @State private var isLoading = true
    @State private var sessionIcons: [String: String] = [:]

    //weekily info
    @State private var totalStudentsThisWeek = 0
    @State private var totalClassesThisWeek = 0
    @State private var totalHoursThisWeek = 0.0
    @State private var totalRevenueThisWeek = 0.0

    var body: some View {
        RoleGuard(allowedRole: .instructor) {
            dashboardContent
        }
        .environmentObject(viewModel)
    }

    @ViewBuilder
    private var dashboardContent: some View {
        if let user = viewModel.currentUser {
            NavigationStack {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            //section 1 - header
                            headerSection(user: user)

                            //section 2 - weekly info
                            weeklyInfoSection()

                            //section 3 - this month sessions
                            thisMonthsSessionsSection()

                        }
                    }

                    FooterNavigationView(selectedTab: 0, userRole: .instructor)
                }
                .background(Color.white)
                .ignoresSafeArea(.all, edges: .bottom)
            }
            .navigationBarHidden(true)
            .task {
                await loadDashboardData()
            }
        } else {
            ProgressView("Loading…")
        }
    }

    //section 1 - header
    @ViewBuilder
    private func headerSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 12) {
                    AvatarView(initials: user.initials, size: 62)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(
                            "Welcome back, \(user.fullname.components(separatedBy: " ").first ?? "")"
                        )
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                        Text(Utils.formattedDate())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                }

                Spacer()

                //                Button(action: {
                //                    //action
                //                }) {
                //                    Image(systemName: "bell")
                //                        .font(.title2)
                //                        .foregroundColor(.primary)
                //                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
    }

    //section 3 - this month sessions
    @ViewBuilder
    private func thisMonthsSessionsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Month's Sessions")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.horizontal, 24)

            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading this month's sessions...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
            } else if monthSessions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)

                    Text("No Sessions This Month")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text("Create your first session to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    NavigationLink(destination: Text("Add Session View")) {
                        Text("Create Session")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.4, green: 0.3, blue: 0.8))
                            .cornerRadius(25)
                    }
                }
                .padding(24)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal, 24)
            } else {
                VStack(spacing: 12) {
                    ForEach(monthSessions.prefix(5)) { session in
                        MonthSessionCard(session: session)
                    }

                    if monthSessions.count > 5 {
                        NavigationLink(destination: Text("All Sessions View")) {
                            Text(
                                "View All Month Sessions (\(monthSessions.count))"
                            )
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(
                                Color(red: 0.4, green: 0.3, blue: 0.8))
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 32)
    }

    //section 2 - weekly info
    @ViewBuilder
    private func weeklyInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("This Week Information")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.horizontal, 24)

            VStack(spacing: 20) {
                // row 1 - classes and revenue
                HStack(spacing: 20) {
                    //classes stats
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "flame.fill")
                                .font(.title2)
                                .foregroundColor(
                                    Color(red: 0.4, green: 0.3, blue: 0.8))

                            Text("Classes")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }

                        Text("\(totalClassesThisWeek)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)

                        Text("This Week")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    //revenue stats
                    VStack(alignment: .trailing, spacing: 8) {
                        HStack(spacing: 8) {
                            Text("Revenue")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)

                            Image(systemName: "dollarsign.circle.fill")
                                .font(.title2)
                                .foregroundColor(
                                    Color(red: 0.4, green: 0.3, blue: 0.8))
                        }

                        Text("$\(String(format: "%.0f", totalRevenueThisWeek))")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)

                        Text("This Week")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                //row 2 - hrs and students
                HStack(spacing: 20) {
                    //hours stats
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "clock.fill")
                                .font(.title2)
                                .foregroundColor(
                                    Color(red: 0.4, green: 0.3, blue: 0.8))

                            Text("Hours")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }

                        Text("\(String(format: "%.0f", totalHoursThisWeek))")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)

                        Text("This Week")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    //students stats
                    VStack(alignment: .trailing, spacing: 8) {
                        HStack(spacing: 8) {
                            Text("Students")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)

                            Image(systemName: "person.3.fill")
                                .font(.title2)
                                .foregroundColor(
                                    Color(red: 0.4, green: 0.3, blue: 0.8))
                        }

                        Text("\(totalStudentsThisWeek)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)

                        Text("This Week")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(20)
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 30)
    }

    //load dashboard data
    private func loadDashboardData() async {
        isLoading = true

        guard let instructorId = viewModel.currentUser?.id else {
            isLoading = false
            return
        }

        //fetch all sessions for instructor
        let allSessions = await sessionViewModel.fetchSessionsByInstructor(
            instructorId: instructorId)

        //filter this month's sessions
        let today = Date()
        let calendar = Calendar.current

        let startOfMonth =
            calendar.dateInterval(of: .month, for: today)?.start ?? today
        let endOfMonth =
            calendar.dateInterval(of: .month, for: today)?.end ?? today

        monthSessions = allSessions.filter { session in
            session.date >= startOfMonth && session.date <= endOfMonth
        }.sorted { session1, session2 in
            let time1 = Utils.combineDateAndTime(
                date: session1.date, timeString: session1.startTime)
            let time2 = Utils.combineDateAndTime(
                date: session2.date, timeString: session2.startTime)
            return time1 < time2
        }

        //filter this week's sessions
        let startOfWeek =
            calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let endOfWeek =
            calendar.dateInterval(of: .weekOfYear, for: today)?.end ?? today

        weekSessions = allSessions.filter { session in
            session.date >= startOfWeek && session.date <= endOfWeek
        }

        //calculate weekly stats
        calculateWeeklyMetrics()

        isLoading = false
    }

    //calculate weekly metrics
    private func calculateWeeklyMetrics() {
        totalClassesThisWeek = weekSessions.count
        totalHoursThisWeek =
            Double(weekSessions.reduce(0) { $0 + $1.durationMinutes }) / 60.0

        //unique students counts in all sessions
        var uniqueStudents = Set<String>()
        for session in weekSessions {
            uniqueStudents.formUnion(session.registeredStudents)
        }
        totalStudentsThisWeek = uniqueStudents.count

        //total revenue from week sessions
        totalRevenueThisWeek = weekSessions.reduce(0) { total, session in
            total + (session.price * Double(session.registeredStudents.count))
        }
    }

}

//month session card
struct MonthSessionCard: View {
    let session: Session

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text(Utils.formatDate(session.date, format: "MMM d"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text("\(session.startTime) - \(session.endTime)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text("\(session.registeredStudents.count) Students")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

            }

            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct InstructorDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        InstructorDashboardView()
            .environmentObject(AuthViewModel())
    }
}
