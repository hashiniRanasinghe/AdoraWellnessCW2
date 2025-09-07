//
//  AddSessionView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-23.
//

import FirebaseFirestore
import SwiftUI

struct AddSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var sessionViewModel = SessionViewModel()
    @State private var showSuccessView = false
    @State private var title = ""
    @State private var description = ""
    @State private var selectedDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var price = ""
    @State private var selectedSessionType = "Online"
    @State private var selectedLevel = "Beginner"

    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    private let sessionTypes = ["Online", "In-Person", "Hybrid"]
    private let levels = ["Beginner", "Intermediate", "Advanced"]

    //calculate duration
    private var durationMinutes: Int {
        let duration = endTime.timeIntervalSince(startTime)
        return max(Int(duration / 60), 0)  //convert sec to mins, min 0
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                headerSection
                    .padding(.top, 40)
                    .padding(.bottom, 32)

                VStack(spacing: 28) {
                    sessionInfoSection
                    scheduleSection
                    sessionDetailsSection
                }
                .padding(.horizontal, 24)

                saveButton
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .padding(.bottom, 100)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .alert("Session Status", isPresented: $showAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(isPresented: $showSuccessView) {
            SessionSuccessView(
                sessionTitle: title,
                sessionDate: selectedDate,
                startTime: formatTime(startTime),
                endTime: formatTime(endTime),
                sessionType: selectedSessionType,
                level: selectedLevel,
                price: Double(price) ?? 0.0,
                isPresented: $showSuccessView
            )
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                }

                Text("Create a new\nsession")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)

            Text("Set up your wellness session for students")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private var sessionInfoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            InputView(
                text: $title,
                title: "Session Title",
                placeholder: "Enter session title"
            )

            VStack(alignment: .leading, spacing: 12) {
                Text("Description")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .frame(minHeight: 100)

                    TextEditor(text: $description)
                        .font(.system(size: 16))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.clear)
                        .frame(minHeight: 100)
                        .tint(.gray)

                    if description.isEmpty {
                        Text("Enter session description...")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            //makes the placeholder see-through to touches for doesn’t block user interaction
                            .allowsHitTesting(false)
                    }
                }
            }
        }
    }

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Date")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                DatePicker(
                    "Session Date",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(CompactDatePickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .tint(Color(red: 0.4, green: 0.3, blue: 0.8))
                .padding(.vertical, 4)
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Start Time")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)

                    DatePicker(
                        "Start",
                        selection: $startTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(CompactDatePickerStyle())
                    .tint(Color(red: 0.4, green: 0.3, blue: 0.8))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("End Time")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)

                    DatePicker(
                        "End",
                        selection: $endTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(CompactDatePickerStyle())
                    .tint(Color(red: 0.4, green: 0.3, blue: 0.8))
                }
            }

            //duration
            HStack {
                Text("Duration:")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                Text("\(durationMinutes) minutes")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }

    private var sessionDetailsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Session Type")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                HStack(spacing: 8) {
                    ForEach(sessionTypes, id: \.self) { type in
                        Button(action: {
                            selectedSessionType = type
                        }) {
                            Text(type)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(
                                    selectedSessionType == type
                                        ? .white : .primary
                                )
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    selectedSessionType == type
                                        ? Color(red: 0.4, green: 0.3, blue: 0.8)
                                        : Color(.systemGray6)
                                )
                                .cornerRadius(20)
                        }
                    }
                    Spacer()
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Difficulty Level")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                HStack(spacing: 8) {
                    ForEach(levels, id: \.self) { level in
                        Button(action: {
                            selectedLevel = level
                        }) {
                            Text(level)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(
                                    selectedLevel == level ? .white : .primary
                                )
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    selectedLevel == level
                                        ? Color(red: 0.4, green: 0.3, blue: 0.8)
                                        : Color(.systemGray6)
                                )
                                .cornerRadius(20)
                        }
                    }
                    Spacer()
                }
            }

            InputView(
                text: $price,
                title: "Price ($)",
                placeholder: "0.00"
            )
            .keyboardType(.decimalPad)
        }
    }

    private var saveButton: some View {
        Button(action: {
            Task {
                await saveSession()
            }
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else {
                    Text("Create Session")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                isFormValid && !isLoading
                    ? Color(red: 0.4, green: 0.3, blue: 0.8)
                    : Color.gray
            )
            .cornerRadius(28)
        }
        .disabled(!isFormValid || isLoading)
    }

    //Form validation
    private var isFormValid: Bool {
        !title.isEmpty && !description.isEmpty && !price.isEmpty
            && Double(price) != nil && endTime > startTime
            && selectedDate >= Calendar.current.startOfDay(for: Date())
    }
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    //save session to db
    private func saveSession() async {
        guard let instructorId = authViewModel.currentUser?.id else {
            alertMessage = "Error: Unable to identify instructor"
            showAlert = true
            return
        }

        guard let sessionPrice = Double(price) else {
            alertMessage = "Please enter a valid price"
            showAlert = true
            return
        }

        isLoading = true

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        let startTimeString = timeFormatter.string(from: startTime)
        let endTimeString = timeFormatter.string(from: endTime)

        //create data dictionary for firestore
        let sessionData: [String: Any] = [
            "instructorId": instructorId,
            "title": title,
            "description": description,
            "startTime": startTimeString,
            "endTime": endTimeString,
            "durationMinutes": durationMinutes,
            "price": sessionPrice,
            "sessionType": selectedSessionType,
            "date": Timestamp(date: selectedDate),  //firebase timestamp
            "createdAt": Timestamp(date: Date()),
            "level": selectedLevel,
            "registeredStudents": [],
        ]

        do {
            let db = Firestore.firestore()
            _ = try await db.collection("sessions").addDocument(
                data: sessionData)

            isLoading = false
            showSuccessView = true
        } catch {
            alertMessage = "Failed to create session. Please try again."
            showAlert = true
            print("Error saving session: \(error.localizedDescription)")
            isLoading = false
        }
    }
}

struct AddSessionView_Previews: PreviewProvider {
    static var previews: some View {
        AddSessionView()
            .environmentObject(AuthViewModel())
    }
}
