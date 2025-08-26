//
//  Dashboard.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-08.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject private var sessionViewModel = SessionViewModel()
    @StateObject private var instructorViewModel = InstructorViewModel()
    @StateObject private var studentViewModel = StudentViewModel()
    @StateObject private var lessonsViewModel = LessonsViewModel()

    @State private var randomSession: Session?
    @State private var randomLesson: Lesson?
    @State private var instructors: [Instructor] = []
    @State private var enrolledSessions: [Session] = []
    @State private var isLoading = true

    var body: some View {
        RoleGuard(allowedRole: .student) {
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
                            //greeting section with user info
                            headerSection(user: user)

                            //daily lesson recommendation
                            recommendedLesson()

                            //session recommendation from available sessions
                            randomSessionSection()

                            //instructors recommendation
                            instructorsSection()

                            //booked sessions
                            bookedSessionsSection()

                            //health data display
                            userStatsSection()
                        }
                    }

                    FooterNavigationView(selectedTab: 0, userRole: .student)
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

    private func recommendedLesson() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Recommendation")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.horizontal, 24)

            // lesson card content
            if let lesson = randomLesson {
                HStack(spacing: 16) {
                    // lesson icon
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 60, height: 60)

                        Image(systemName: lesson.iconName)
                            .font(.title2)
                            .foregroundColor(
                                Color(red: 0.4, green: 0.3, blue: 0.8))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(lesson.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Text(lesson.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                                Text(lesson.formattedDuration)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        // play btn
                        Button(action: {
                            print("Playing - TO DOOO \(lesson.title)")
                            // start playing the lesson
                        }) {
                            Image(systemName: "play.circle.fill")
                                .font(.title)
                                .foregroundColor(
                                    Color(red: 0.4, green: 0.3, blue: 0.8))
                        }

                        if lesson.calories > 0 {
                            Text("\(lesson.calories) cal")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(
                                    Color(red: 0.4, green: 0.3, blue: 0.8))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            } else {
                // show loading or no lessons available
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 60, height: 60)

                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.6)
                        } else {
                            Image(systemName: "figure.yoga")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        if isLoading {
                            Text("Loading recommendation...")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                        } else {
                            Text("No lessons available")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                        }

                        Text("Check back later")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }

    //greeting section with user info
    @ViewBuilder
    private func headerSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 12) {
                    //initials img
                    AvatarView(initials: user.initials, size: 62).font(.title)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(
                            "\(Utils.greetingMessage()), \(user.fullname.components(separatedBy: " ").first ?? "")"
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
                //                    //bell action
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

    //daily lesson recommendation user hasn t booked yet
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

                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                    Text(
                                        Utils.formatDate(
                                            session.date, format: "MMM d")
                                    )
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

                    HStack(spacing: 8) {
                        Text("\(session.startTime) - \(session.endTime)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("\(session.registeredStudents.count) enrolled")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    //book session btn
                    if let instructor = getInstructorById(session.instructorId)
                    {
                        NavigationLink(
                            destination: SessionDetailsView(
                                session: session, instructor: instructor)
                        ) {
                            Text("Book This Session")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    Color(red: 0.4, green: 0.3, blue: 0.8)
                                )
                                .cornerRadius(25)
                        }
                    } else {
                        Button(action: {}) {
                            Text("Loading...")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.gray)
                                .cornerRadius(25)
                        }
                        .disabled(true)
                    }
                }
                .padding(20)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal, 24)
            } else {
                //empty when no sessions
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

    //instructors recommendation
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

    //booked sessions by user
    @ViewBuilder
    private func bookedSessionsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Sessions")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.horizontal, 24)

            if !enrolledSessions.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        //all enrolled sessions
                        ForEach(enrolledSessions) { session in
                            EnrolledSessionCard(session: session)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .frame(maxHeight: 200)
            } else {
                //user hasn t booked any sessions
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)

                    Text("No Booked Sessions")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text(
                        "Book your first session and start your wellness journey!"
                    )
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

    //health data
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
                    //height
                    VStack(spacing: 8) {
                        Image(systemName: "ruler")
                            .font(.title2)
                            .foregroundColor(
                                Color(red: 0.4, green: 0.3, blue: 0.8))

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

                    //weight
                    VStack(spacing: 8) {
                        Image(systemName: "scalemass")
                            .font(.title2)
                            .foregroundColor(
                                Color(red: 0.4, green: 0.3, blue: 0.8))

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

                    //calculate bmi card
                    VStack(spacing: 8) {
                        Image(systemName: "heart.text.square")
                            .font(.title2)
                            .foregroundColor(
                                Color(red: 0.4, green: 0.3, blue: 0.8))

                        Text(
                            String(
                                format: "%.1f",
                                calculateBMI(
                                    weight: student.weight,
                                    height: student.height))
                        )
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
                //user profile isn't complete
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.title)
                        .foregroundColor(.secondary)

                    Text("Complete your profile to see health stats")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    NavigationLink(
                        destination: StudentProfileSetupView()
                            .environmentObject(viewModel)
                    ) {
                        Text("Complete Profile")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(
                                Color(red: 0.4, green: 0.3, blue: 0.8)
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Color(red: 0.4, green: 0.3, blue: 0.8).opacity(
                                    0.1)
                            )
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
        .padding(.bottom, 100)
    }

    //load all dashboard items
    private func loadDashboardData() async {
        isLoading = true

        //get user profile info
        await studentViewModel.fetchStudentProfile()

        //get random lesson
        await loadRandomLesson()

        //user s enrolled sessions
        await loadEnrolledSessions()

        //random session user hasnt booked yet
        await loadRandomSession()

        //instructors
        let allInstructors = await instructorViewModel.fetchAllInstructors()
        instructors = Array(allInstructors.prefix(3))

        isLoading = false
    }

    //get random lesson
    private func loadRandomLesson() async {
        let allLessons = await lessonsViewModel.fetchAllLessons()
        let activeLessons = allLessons.filter { $0.isActive }

        // pick one randomly
        if !activeLessons.isEmpty {
            randomLesson = activeLessons.randomElement()
        } else {
            randomLesson = nil
        }
    }

    //random session user hasnt booked yet
    private func loadRandomSession() async {
        guard let currentUserId = viewModel.currentUser?.id else {
            randomSession = nil
            return
        }

        //all available sessions in db
        let allSessions = await sessionViewModel.fetchAllSessions()

        //filter by user havnt booked and sessions hasnt started
        let availableSessions = allSessions.filter { session in
            //sessions hasnt started
            let sessionDateTime = Utils.combineDateAndTime(
                date: session.date, timeString: session.startTime)
            let isFuture = sessionDateTime > Date()

            //user havnt booke
            let notAlreadyBooked = !session.registeredStudents.contains(
                currentUserId)

            return isFuture && notAlreadyBooked
        }

        //random session
        if !availableSessions.isEmpty {
            randomSession = availableSessions.randomElement()
        } else {
            randomSession = nil
        }
    }

    //user enrolled active sessions
    private func loadEnrolledSessions() async {
        guard let currentUserId = viewModel.currentUser?.id else {
            enrolledSessions = []
            return
        }

        //fetch all
        let allSessions = await sessionViewModel.fetchAllSessions()

        let userSessions = allSessions.filter { session in
            let isRegistered = session.registeredStudents.contains(
                currentUserId)

            let sessionDateTime = Utils.combineDateAndTime(
                date: session.date, timeString: session.startTime)
            let isUpcoming =
                sessionDateTime >= Calendar.current.startOfDay(for: Date())

            return isRegistered && isUpcoming
        }

        //show closest sessions first
        enrolledSessions = userSessions.sorted { session1, session2 in
            let date1 = Utils.combineDateAndTime(
                date: session1.date, timeString: session1.startTime)
            let date2 = Utils.combineDateAndTime(
                date: session2.date, timeString: session2.startTime)
            return date1 < date2
        }
    }

    //instructor info
    private func getInstructorById(_ instructorId: String) -> Instructor? {
        return instructors.first { $0.id == instructorId }
    }

    // calculate bmi
    private func calculateBMI(weight: Double, height: Double) -> Double {
        if height > 0 {
            let heightInMeters = height / 100  //cm to m
            return weight / (heightInMeters * heightInMeters)
        }
        return 0
    }
}

//user enrolled sessions card
struct EnrolledSessionCard: View {
    let session: Session

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                HStack(spacing: 16) {
                    //session date info
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text(Utils.formatDate(session.date, format: "MMM d"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    //time info
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text("\(session.startTime) - \(session.endTime)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // action button or session details on the right
            VStack(alignment: .trailing, spacing: 4) {
                if isSessionToday(session) {
                    Button(action: {
                        //
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
                } else {
                    Text(session.sessionType)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("$\(String(format: "%.0f", session.price))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // check if the session today
    private func isSessionToday(_ session: Session) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(session.date)
    }

}

//instructor card
struct InstructorMiniCard: View {
    let instructor: Instructor

    var body: some View {
        NavigationLink(
            destination: InstructorDetailsView(instructor: instructor)
        ) {
            VStack(spacing: 12) {
                //instructor profile img
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

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(AuthViewModel())
    }
}
