//
//  NewDashboardView.swift
//  AdoraWellness
//
//  Created by Assistant on 2025-08-21.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject private var sessionViewModel = SessionViewModel()
    @StateObject private var instructorViewModel = InstructorViewModel()
    @StateObject private var studentViewModel = StudentViewModel()
    @StateObject private var lessonsViewModel = LessonsViewModel()
    
    @State private var randomSession: Session?
    @State private var instructors: [Instructor] = []
    @State private var hasBookedSessions = false
    @State private var isLoading = true
    
    var body: some View {
        if let user = viewModel.currentUser {
            NavigationStack {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            // Header section (same as original)
                            headerSection(user: user)
                            
                            // Section 1: Random Session
                            randomSessionSection()
                            
                            // Section 2: Top 3 Instructors
                            instructorsSection()
                            
                            // Section 3: Booked Sessions or Book a Session
                            bookedSessionsSection()
                            
                            // Section 4: User Stats (Height, Weight, BMI)
                            userStatsSection()
                        }
                    }
                    
                    FooterNavigationView(selectedTab: 0)
                }
                .background(Color.white)
                .ignoresSafeArea(.all, edges: .bottom)
            }
            .navigationBarHidden(true)
            .task {
                await loadDashboardData()
            }
        }
    }
    
    // MARK: - Header Section
    @ViewBuilder
    private func headerSection(user: User) -> some View {
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
        }
    }
    
    // MARK: - Random Session Section
    @ViewBuilder
    private func randomSessionSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Featured Session")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.horizontal, 24)
            
            if let session = randomSession {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(session.title)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 16) {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                    Text("\(session.durationMinutes) min")
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
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("$\(String(format: "%.0f", session.price))")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(session.sessionType)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if !session.description.isEmpty {
                        Text(session.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button(action: {
                        // Handle book session
                    }) {
                        Text("Book This Session")
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
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal, 24)
            } else {
                // Loading or empty state
                VStack(spacing: 12) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "figure.yoga")
                            .font(.title)
                            .foregroundColor(.secondary)
                        Text("No sessions available")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Instructors Section
    @ViewBuilder
    private func instructorsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Top Instructors")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                NavigationLink(destination: FindInstructorsView()) {
                    Text("See All")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                }
            }
            .padding(.horizontal, 24)
            
            if instructors.isEmpty && isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(0.8)
                    Spacer()
                }
                .frame(height: 80)
            } else if instructors.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.slash")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("No instructors available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 80)
                .frame(maxWidth: .infinity)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(instructors.prefix(3)) { instructor in
                            InstructorMiniCard(instructor: instructor)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Booked Sessions Section
    @ViewBuilder
    private func bookedSessionsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Sessions")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.horizontal, 24)
            
            if hasBookedSessions {
                // Show booked sessions (placeholder for now)
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Upcoming Session")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("Morning Yoga - Today at 8:00 AM")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Handle join session
                        }) {
                            Text("Join")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.green)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(20)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal, 24)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    
                    Text("No Booked Sessions")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Book your first session and start your wellness journey!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    NavigationLink(destination: FindInstructorsView()) {
                        Text("Book a Session")
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
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - User Stats Section
    @ViewBuilder
    private func userStatsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Health Stats")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.horizontal, 24)
            
            if let student = studentViewModel.currentStudent {
                HStack(spacing: 16) {
                    // Height
                    VStack(spacing: 8) {
                        Image(systemName: "ruler")
                            .font(.title2)
                            .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                        
                        Text("\(String(format: "%.1f", student.height)) cm")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Height")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Weight
                    VStack(spacing: 8) {
                        Image(systemName: "scalemass")
                            .font(.title2)
                            .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                        
                        Text("\(String(format: "%.1f", student.weight)) kg")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Weight")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // BMI
                    VStack(spacing: 8) {
                        Image(systemName: "heart.text.square")
                            .font(.title2)
                            .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                        
                        Text(String(format: "%.1f", calculateBMI(weight: student.weight, height: student.height)))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("BMI")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.title)
                        .foregroundColor(.secondary)
                    
                    Text("Complete your profile to see health stats")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    NavigationLink(destination: StudentProfileSetupView().environmentObject(viewModel)) {
                        Text("Complete Profile")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.4, green: 0.3, blue: 0.8).opacity(0.1))
                            .cornerRadius(16)
                    }
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 100) // Space for footer
    }
    
    // MARK: - Helper Functions
    private func loadDashboardData() async {
        isLoading = true
        
        // Load student profile
        await studentViewModel.fetchStudentProfile()
        
        // Load random session (simulate getting random session from available sessions)
        // In a real app, you'd fetch all sessions and pick a random one
        // For now, we'll create a sample session
        randomSession = createSampleSession()
        
        // Load top 3 instructors
        let allInstructors = await instructorViewModel.fetchAllInstructors()
        instructors = Array(allInstructors.prefix(3))
        
        // Check for booked sessions (placeholder logic)
        // In a real app, you'd check if the current user has any booked sessions
        hasBookedSessions = false // Set to true if user has booked sessions
        
        isLoading = false
    }
    
    private func createSampleSession() -> Session {
        return Session(
            id: "sample-session",
            instructorId: "instructor-1",
            title: "Morning Energy Flow",
            description: "Start your day with this energizing yoga sequence designed to awaken your body and mind.",
            startTime: "08:00",
            endTime: "09:00",
            durationMinutes: 60,
            price: 25.0,
            sessionType: "Online",
            date: Date(),
            createdAt: Date(),
            level: "Beginner",
            registeredStudents: []
        )
    }
    
    private func calculateBMI(weight: Double, height: Double) -> Double {
        if height > 0 {
            let heightInMeters = height / 100 // Convert cm to meters
            return weight / (heightInMeters * heightInMeters)
        }
        return 0
    }
}

// MARK: - Mini Instructor Card
struct InstructorMiniCard: View {
    let instructor: Instructor
    
    var body: some View {
        NavigationLink(destination: InstructorDetailsView(instructor: instructor)) {
            VStack(spacing: 12) {
                // Profile image with initials
                Text(instructor.initials)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color(.systemGray3))
                    .clipShape(Circle())
                
                VStack(spacing: 4) {
                    Text(instructor.fullName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(instructor.specialities.first ?? "Instructor")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Text("$\(String(format: "%.0f", instructor.hourlyRate))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                }
            }
            .frame(width: 120)
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NewDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(AuthViewModel())
    }
}
