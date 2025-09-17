//
//  InstructorSessionDetailsView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-24.
//

import MessageUI
import SwiftUI

struct InstructorSessionDetailsView: View {
    let session: Session
    @Environment(\.dismiss) private var dismiss
    @State private var showingMailComposer = false
    @State private var showingMailAlert = false
    @State private var studentEmails: [String] = []
    @StateObject private var studentViewModel = StudentViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    Spacer()

                    Text(session.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 32)

                //session info
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Date")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(
                                Utils.formatDate(
                                    session.date, format: "EEEE, MMM d")
                            )
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                            Text(Utils.formatDate(session.date, format: "yyyy"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Time & Duration")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(session.startTime)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Text("\(session.durationMinutes) minutes")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Level")
                                .foregroundColor(.secondary)

                            Text(session.level)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Type")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(session.sessionType)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Price")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            //formats price as a string with no decimal places (25.00 - 25)
                            Text("$\(String(format: "%.0f", session.price))")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

                //enrolled students
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Enrolled Students")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Text(
                                "\(session.registeredStudents.count) \(session.registeredStudents.count == 1 ? "student" : "students") registered"
                            )
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)

                    //studentslist
                    if session.registeredStudents.isEmpty {
                        //null state
                        VStack(spacing: 16) {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.6))

                            Text("No students enrolled yet")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Text(
                                "Students will appear here once they book this session"
                            )
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(session.registeredStudents, id: \.self)
                                { studentId in
                                    StudentRowView(studentId: studentId)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 140)
                        }
                    }
                }

                Spacer()
            }
            .background(Color(.systemBackground))
            .overlay(
                //mail session detials
                VStack {
                    Spacer()

                    Button(action: {
                        //if email is available on device -> open mail composer
                        if MFMailComposeViewController.canSendMail() {
                            showingMailComposer = true
                        } else {
                            //if not ->  show alert “Mail Not Available”
                            showingMailAlert = true
                        }
                    }) {
                        HStack {

                            Text("Send Session Details")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.4, green: 0.3, blue: 0.8),
                                    Color(red: 0.3, green: 0.2, blue: 0.7),
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(
                            color: Color(red: 0.4, green: 0.3, blue: 0.8)
                                .opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(session.registeredStudents.isEmpty)
                    .opacity(session.registeredStudents.isEmpty ? 0.6 : 1.0)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                }
            )
        }
        .navigationBarHidden(true)

        //presents the mail composer screen
        .sheet(isPresented: $showingMailComposer) {
            MailComposeView(
                recipients: studentEmails,
                subject: generateEmailSubject(),
                messageBody: generateEmailBody()
            )
        }
        .alert("Mail Not Available", isPresented: $showingMailAlert) {
            Button("OK") {}
        } message: {
            Text(
                "Please configure a mail account in your device settings to send emails."
            )
        }
        .task {
            await loadStudentEmails()
        }
    }

    //load student emails for the mail composer
    private func loadStudentEmails() async {
        //view model fetch student objects by their IDs
        let students = await studentViewModel.fetchStudentsByIds(
            studentIds: session.registeredStudents)
        //extract just the email address from each student
        studentEmails = students.map { $0.email }
    }

    //generate email subject
    private func generateEmailSubject() -> String {
        return
            "Session Details: \(session.title) - \(Utils.formatDate(session.date, format: "MMM d, yyyy"))"
    }

    //generate email body
    private func generateEmailBody() -> String {
        let dateString = Utils.formatDate(
            session.date, format: "EEEE, MMMM d, yyyy")

        //return a multi-line string as the email body
        return """

            Dear Student,

            This is a reminder for your upcoming session:

            📋 SESSION DETAILS
            ─────────────────────
            Session: \(session.title)
            Date: \(dateString)
            Time: \(session.startTime) - \(session.endTime)
            Duration: \(session.durationMinutes) minutes
            Level: \(session.level)
            Type: \(session.sessionType)
            Price: $\(String(format: "%.0f", session.price))

            🔗 MEETING LINK
            ─────────────────────
            [Insert Meeting Link Here]

            📝 PREPARATION
            ─────────────────────
            • Please join 5–10 minutes early  
            • Wear comfortable workout clothes  
            • Keep water nearby  
            • Yoga mat (if required for this session)  

            ❓ QUESTIONS?
            ─────────────────────
            If you have any questions or need to make changes, please feel free to contact me.

            Looking forward to seeing you in class!

            Best regards,  
            Your Fitness Instructor  

            ---  
            AdoraWellness - Your Journey to Better Health  
            """
    }

}

//student row
struct StudentRowView: View {
    let studentId: String
    @StateObject private var studentViewModel = StudentViewModel()
    @State private var student: Student?
    @State private var isLoadingStudent = true
    @State private var showCopiedFeedback = false

    var body: some View {
        HStack(spacing: 16) {
            if isLoadingStudent {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
            } else {
                AsyncImage(url: URL(string: student?.profileImageURL ?? "")) {
                    image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    AvatarView(
                        initials: {
                            let first =
                                student?.firstName.first.map {
                                    String($0).uppercased()
                                } ?? ""
                            let last =
                                student?.lastName.first.map {
                                    String($0).uppercased()
                                } ?? ""
                            return (first + last).isEmpty ? "S" : first + last
                        }(),
                        size: 60
                    )

                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )

            }

            VStack(alignment: .leading, spacing: 6) {
                if isLoadingStudent {
                    //gray rectangles that imitate the shape of text lines
                    VStack(alignment: .leading, spacing: 6) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 18)
                            .cornerRadius(4)

                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 14)
                            .cornerRadius(3)

                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 14)
                            .cornerRadius(3)
                    }
                } else {
                    Text(student?.fullName ?? "Unknown Student")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                        Text(student?.email ?? "No email")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    if let phone = student?.phoneNumber, !phone.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)

                            Text(phone)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }

            Spacer()

            //action btns
            if !isLoadingStudent {
                //student data has finished loading
                VStack(spacing: 8) {
                    //copy email
                    Button(action: {
                        if let email = student?.email, !email.isEmpty {
                            //copies the student’s email to the clipboard - UIPasteboard
                            UIPasteboard.general.string = email
                            showCopiedFeedback = true

                            //hide after 2s
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2)
                            {
                                showCopiedFeedback = false
                            }
                        }
                    }) {
                        Image(
                            systemName: showCopiedFeedback
                                ? "checkmark.circle.fill" : "doc.on.clipboard"
                        )
                        .font(.system(size: 16))
                        .foregroundColor(
                            showCopiedFeedback ? .green : .secondary)
                    }
                    .disabled(student?.email.isEmpty ?? true)

                    //fitness level badge
                    if let fitnessLevel = student?.fitnessLevel {
                        Text(fitnessLevel.displayName.prefix(3).uppercased())
                            .font(.system(size: 10, weight: .semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        fitnessLevelColor(for: fitnessLevel)
                                            .opacity(0.2))
                            )
                            .foregroundColor(
                                fitnessLevelColor(for: fitnessLevel))
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .task {
            await loadStudentData()
        }
    }

    private func loadStudentData() async {
        isLoadingStudent = true

        //student data from db
        student = await studentViewModel.fetchStudentById(studentId: studentId)

        isLoadingStudent = false
    }

    private func fitnessLevelColor(for level: Student.FitnessLevel) -> Color {
        switch level {
        case .beginner:
            return .green
        case .intermediate:
            return .orange
        case .advanced:
            return .red
        case .expert:
            return .purple
        }
    }
}

//mail Composer
struct MailComposeView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let messageBody: String
    @Environment(\.dismiss) private var dismiss

    //create and configure the UIKit mail composer
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()  // standard mail screen
        composer.mailComposeDelegate = context.coordinator  // set listener (when the user finishes sending, cancels, or saves)
        composer.setToRecipients(recipients)
        composer.setSubject(subject)
        composer.setMessageBody(messageBody, isHTML: false)  //body is plain text not HTML
        return composer
    }
    //sync changes from SwiftUI state to the UIKit component whenever SwiftUI re-renders
    func updateUIViewController(
        _ uiViewController: MFMailComposeViewController, context: Context
    ) {}  //empty here because mail composers can't be modified after they're presented

    // messenger that reports back what happened with the email
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    //Coordinator = helper that watches the mail screen
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView

        //parent reference - when the coordinator is created, it remembers which SwiftUI view is the parent.
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        //called when user finishes (send, cancel, or save)
        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult, error: Error?
        ) {
            parent.dismiss()
        }
    }
}
