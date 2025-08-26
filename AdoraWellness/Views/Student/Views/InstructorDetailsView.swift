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
    @State private var allSessions: [Session] = []
    @State private var filteredSessions: [Session] = []
    @State private var selectedDate: Date? = nil
    @State private var showDatePicker = false
    @State private var isDateFilterActive = false
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
                                AvatarView(
                                    initials: instructor.initials, size: 100)

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
                            Text("Filter by Date")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)

                            //date time selector
                            Button(action: {
                                showDatePicker.toggle()
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "calendar")
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                        .frame(width: 24, height: 24)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(
                                            isDateFilterActive
                                                ? "Selected Date"
                                                : "Select Date (Optional)"
                                        )
                                        .font(
                                            .system(size: 16, weight: .medium)
                                        )
                                        .foregroundColor(.primary)

                                        Text(
                                            isDateFilterActive
                                                ? formatSelectedDate(
                                                    selectedDate ?? Date())
                                                : "Tap to filter sessions by date"
                                        )
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(16)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .sheet(isPresented: $showDatePicker) {
                                DatePickerSheet(
                                    selectedDate: Binding(
                                        get: { selectedDate ?? Date() },
                                        set: { selectedDate = $0 }
                                    ),
                                    onDateSelected: {
                                        isDateFilterActive = true
                                        filterSessionsByDate()
                                    },
                                    onClearFilter: {
                                        selectedDate = nil
                                        isDateFilterActive = false
                                        filterSessionsByDate()
                                    },
                                    isFilterActive: isDateFilterActive
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)

                        //available sessions
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("Available Times")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)

                                Spacer()

                                if isDateFilterActive {
                                    Text(
                                        "(\(filteredSessions.count) sessions on \(Utils.formatDate(selectedDate ?? Date())))"
                                    )
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                } else {
                                    Text(
                                        "(\(filteredSessions.count) total sessions)"
                                    )
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                }
                            }

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
                            } else if filteredSessions.isEmpty {
                                VStack(spacing: 12) {
                                    Image(
                                        systemName:
                                            "calendar.badge.exclamationmark"
                                    )
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)

                                    if isDateFilterActive {
                                        Text(
                                            "No sessions available for selected date"
                                        )
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        Text("Try selecting a different date")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("No sessions available")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text(
                                            "Check back later for new sessions"
                                        )
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                VStack(spacing: 16) {
                                    ForEach(filteredSessions) { session in
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
        allSessions = await viewModel.fetchSessionsByInstructor(
            instructorId: instructor.id)
        filterSessionsByDate()
    }

    private func filterSessionsByDate() {
        if isDateFilterActive, let selectedDate = selectedDate {
            let calendar = Calendar.current
            filteredSessions = allSessions.filter { session in
                calendar.isDate(session.date, inSameDayAs: selectedDate)
            }
        } else {
            //bu defult show all the sessions
            filteredSessions = allSessions
        }
    }

    private func formatSelectedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    //if the bio is empty
    private func getDefaultBio() -> String {
        return
            "\(instructor.firstName) was born and raised with a passion for wellness and fitness. With \(instructor.experience) years of experience in \(instructor.specialities.joined(separator: ", ")), \(instructor.firstName) brings expertise and dedication to every session."
    }

}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    let onDateSelected: () -> Void
    let onClearFilter: () -> Void
    let isFilterActive: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(CompactDatePickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .tint(Color(red: 0.4, green: 0.3, blue: 0.8))
                .padding(.vertical, 4)
                .padding(.horizontal, 20)

                VStack(spacing: 12) {
                    Button(action: {
                        onDateSelected()
                        dismiss()
                    }) {
                        Text("Apply Date Filter")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.4, green: 0.3, blue: 0.8))
                            .cornerRadius(12)
                    }

                    if isFilterActive {
                        Button(action: {
                            onClearFilter()
                            dismiss()
                        }) {
                            Text("Clear Filter - Show All Sessions")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(
                                    Color(red: 0.4, green: 0.3, blue: 0.8)
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    Color(red: 0.4, green: 0.3, blue: 0.8)
                                        .opacity(0.1)
                                )
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .navigationTitle("Filter Sessions")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(
                        (Color(red: 0.4, green: 0.3, blue: 0.8)))
                }
            }
        }
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
                studioName: "s1",
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
