//
//  InstructorDetailsView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-16.
//

import SwiftUI

struct InstructorDetailsView: View {
    let instructor: Instructor
    @StateObject private var viewModel = SessionViewModel()
    @State private var sessions: [Session] = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }

                            Spacer()

                            Text("Instructors")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Spacer()

                            //                            Button(action: {
                            //                            }) {
                            //                                Image(systemName: "heart")
                            //                                    .font(.title2)
                            //                                    .foregroundColor(.primary)
                            //                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 32)

                        //profile
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Spacer()

                                //img
                                Text(instructor.initials)
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: 100)
                                    .background(Color(.systemGray3))
                                    .clipShape(Circle())

                                Spacer()
                            }

                            VStack(alignment: .center, spacing: 8) {
                                Text("Certified Yoga Instructor")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)

                                Text(instructor.fullName)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)

                        //about
                        VStack(alignment: .leading, spacing: 16) {
                            Text("About")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)

                            Text(
                                instructor.bio.isEmpty
                                    ? getDefaultBio() : instructor.bio
                            )
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .lineLimit(nil)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)

                        VStack(alignment: .leading, spacing: 20) {
                            Text("Date and time")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)

                            //date time selector
                            HStack(spacing: 16) {
                                Image(systemName: "calendar")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                    .frame(width: 24, height: 24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Date & time")
                                        .font(
                                            .system(size: 16, weight: .medium)
                                        )
                                        .foregroundColor(.primary)

                                    Text("Choose date and time")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .padding(16)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)

                        //available sessions
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Available Times")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)

                            if viewModel.isLoading {
                                VStack(spacing: 12) {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                    Text("Loading sessions...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else if sessions.isEmpty {
                                VStack(spacing: 12) {
                                    Image(
                                        systemName:
                                            "calendar.badge.exclamationmark"
                                    )
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                    Text("No sessions available")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                VStack(spacing: 16) {
                                    ForEach(sessions) { session in
                                        SessionCard(
                                            session: session,
                                            instructor: instructor)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100)
                    }
                }

            }
            .background(Color.white)
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .navigationBarHidden(true)
        .task {
            await loadSessions()
        }
    }

    private func loadSessions() async {
        sessions = await viewModel.fetchSessionsByInstructor(
            instructorId: instructor.id)
    }

    //if the bio is empty
    private func getDefaultBio() -> String {
        return
            "\(instructor.firstName) was born and raised with a passion for wellness and fitness. With \(instructor.experience) years of experience in \(instructor.specialities.joined(separator: ", ")), \(instructor.firstName) brings expertise and dedication to every session."
    }

}

struct SessionCard: View {
    let session: Session
    let instructor: Instructor

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(session.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                Text("\(session.durationMinutes) min")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
            }

            HStack {
                Text(
                    Utils.formatTimeRange(
                        startTime: session.startTime, endTime: session.endTime)
                )
                .font(.system(size: 14))
                .foregroundColor(.secondary)

                Spacer()

                Text("Beginner Level")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            HStack {
                Text(Utils.formatDate(session.date))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                Spacer()
            }

            if !session.description.isEmpty {
                Text(session.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            HStack {
                Text("$\(String(format: "%.0f", session.price))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                NavigationLink(
                    destination: SessionDetailsView(
                        session: session, instructor: instructor)
                ) {
                    Text("Book Session")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.4, green: 0.3, blue: 0.8))
                        .cornerRadius(16)
                }
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

}

struct InstructorDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        InstructorDetailsView(
            instructor: Instructor(
                id: "1",
                firstName: "Denith",
                lastName: "Rasel",
                email: "123@example.com",
                phoneNumber: "123-456-7890",
                dateOfBirth: Date(),
                address: "123 Main St",
                city: "New York",
                country: "United States",
                latitude: 40.7128,
                longitude: -74.0060,
                specialities: ["Yoga", "Pilates"],
                certifications: "Certified Yoga Instructor",
                experience: 5,
                hourlyRate: 35.0,
                bio: "Experienced yoga instructor with a passion for wellness.",
                isActive: true
            ))
    }
}
