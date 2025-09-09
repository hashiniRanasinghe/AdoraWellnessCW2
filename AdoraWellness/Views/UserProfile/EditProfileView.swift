//
//  EditProfileView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-09-09.
//

import FirebaseAuth
import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var studentViewModel = StudentViewModel()
    @StateObject private var instructorViewModel = InstructorViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
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

                    Text("Edit Profile")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.top, 20)

                    Spacer()

                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 32) {
                        //profile pic
                        VStack(spacing: 16) {
                            if let user = authViewModel.currentUser {
                                HStack {
                                    Spacer()
                                    AvatarView(
                                        initials: user.initials,
                                        size: 100
                                    )
                                    Spacer()
                                }
                            }
                        }
                        .padding(.top, 20)

                        //fields
                        VStack(spacing: 24) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)

                                TextField("Enter your name", text: $name)
                                    .font(.system(size: 16))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                Color(.systemGray4),
                                                lineWidth: 1)
                                    )
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)

                                TextField("Enter your email", text: $email)
                                    .font(.system(size: 16))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                Color(.systemGray4),
                                                lineWidth: 1)
                                    )
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Phone Number")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)

                                HStack {
                                    Image(systemName: "phone")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 16))

                                    TextField(
                                        "Enter your phone number",
                                        text: $phoneNumber
                                    )
                                    .font(.system(size: 16))
                                    .keyboardType(.phonePad)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color(.systemGray4), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 24)

                        Spacer()
                    }
                }

                //save btn
                VStack(spacing: 0) {
                    Button(action: {
                        Task {
                            await saveChanges()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Text("Save Changes")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            formIsValid && !isLoading
                                ? Color(red: 0.4, green: 0.3, blue: 0.8)
                                : Color.gray
                        )
                        .cornerRadius(28)
                    }
                    .disabled(!formIsValid || isLoading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                }
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
            .onAppear {
                loadCurrentUserData()
            }
            .alert(
                "Profile Updated",
                isPresented: .constant(
                    studentViewModel.isSuccess || instructorViewModel.isSuccess)
            ) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your profile has been updated successfully.")
            }
            .alert(
                "Error",
                isPresented: .constant(
                    studentViewModel.showAlert || instructorViewModel.showAlert)
            ) {
                Button("OK") {}
            } message: {
                Text(
                    studentViewModel.alertMessage ?? instructorViewModel
                        .alertMessage ?? "Something went wrong")
            }
        }
    }

    private var formIsValid: Bool {
        return !name.isEmpty && !email.isEmpty && !phoneNumber.isEmpty
    }

    private func loadCurrentUserData() {
        guard let user = authViewModel.currentUser else { return }

        name = user.fullname
        email = user.email

        //load additional data based on user type
        Task {
            if user.userType == .student {
                await studentViewModel.fetchStudentProfile()
                if let student = studentViewModel.currentStudent {
                    phoneNumber = student.phoneNumber
                }
            } else if user.userType == .instructor {
                await instructorViewModel.fetchInstructorProfile()
                if let instructor = instructorViewModel.currentInstructor {
                    phoneNumber = instructor.phoneNumber
                }
            }
        }
    }

    private func saveChanges() async {
        guard let currentUser = Auth.auth().currentUser,
            let user = authViewModel.currentUser
        else { return }

        isLoading = true

        //update user info through AuthViewModel
        do {
            try await authViewModel.updateUserInfo(name: name, email: email)
        } catch {
            print("Failed to update user info: \(error)")
        }

        //update profile based on user type
        if user.userType == .student {
            await updateStudentProfile()
        } else if user.userType == .instructor {
            await updateInstructorProfile()
        }

        isLoading = false
    }

    private func updateStudentProfile() async {
        guard let currentUser = Auth.auth().currentUser,
            let existingStudent = studentViewModel.currentStudent
        else { return }

        let nameParts = name.components(separatedBy: " ")
        let firstName = nameParts.first ?? name
        let lastName =
            nameParts.count > 1
            ? nameParts.dropFirst().joined(separator: " ") : ""

        let updatedStudent = Student(
            id: currentUser.uid,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            dateOfBirth: existingStudent.dateOfBirth,
            gender: existingStudent.gender,
            weight: existingStudent.weight,
            height: existingStudent.height,
            fitnessLevel: existingStudent.fitnessLevel,
            healthConditions: existingStudent.healthConditions,
            fitnessGoals: existingStudent.fitnessGoals,
            emergencyContactName: existingStudent.emergencyContactName,
            emergencyContactPhone: existingStudent.emergencyContactPhone,
            profileImageURL: existingStudent.profileImageURL,
            membershipStartDate: existingStudent.membershipStartDate,
            isActive: existingStudent.isActive
        )

        await studentViewModel.updateStudentProfile(updatedStudent)
    }

    private func updateInstructorProfile() async {
        guard let currentUser = Auth.auth().currentUser,
            let existingInstructor = instructorViewModel.currentInstructor
        else { return }

        let nameParts = name.components(separatedBy: " ")
        let firstName = nameParts.first ?? name
        let lastName =
            nameParts.count > 1
            ? nameParts.dropFirst().joined(separator: " ") : ""

        let updatedInstructor = Instructor(
            id: currentUser.uid,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            dateOfBirth: existingInstructor.dateOfBirth,
            address: existingInstructor.address,
            studioName: existingInstructor.studioName,
            city: existingInstructor.city,
            country: existingInstructor.country,
            latitude: existingInstructor.latitude,
            longitude: existingInstructor.longitude,
            specialities: existingInstructor.specialities,
            certifications: existingInstructor.certifications,
            experience: existingInstructor.experience,
            hourlyRate: existingInstructor.hourlyRate,
            bio: existingInstructor.bio,
            isActive: existingInstructor.isActive
        )

        await instructorViewModel.updateInstructorProfile(updatedInstructor)
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthViewModel())
}
