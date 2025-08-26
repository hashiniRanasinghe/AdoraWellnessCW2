//
//  StudentViewModel.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-10.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
class StudentViewModel: ObservableObject {
    @Published var currentStudent: Student?
    @Published var alertMessage: String?
    @Published var showAlert = false
    @Published var isLoading = false
    @Published var isSuccess = false

    private let db = Firestore.firestore()

    //add student data to db
    func saveStudentProfile(_ student: Student) async {
        guard let currentUser = Auth.auth().currentUser else {
            alertMessage = "No authenticated user found"
            showAlert = true
            return
        }

        isLoading = true

        do {
            var updatedStudent = student
            updatedStudent.updatedAt = Date()

            let studentData: [String: Any] = [
                "id": updatedStudent.id,
                "firstName": updatedStudent.firstName,
                "lastName": updatedStudent.lastName,
                "email": updatedStudent.email,
                "phoneNumber": updatedStudent.phoneNumber,
                "dateOfBirth": Timestamp(date: updatedStudent.dateOfBirth),
                "gender": updatedStudent.gender.rawValue,
                "weight": updatedStudent.weight,
                "height": updatedStudent.height,
                "fitnessLevel": updatedStudent.fitnessLevel.rawValue,
                "healthConditions": updatedStudent.healthConditions,
                "fitnessGoals": updatedStudent.fitnessGoals,
                "emergencyContactName": updatedStudent.emergencyContactName,
                "emergencyContactPhone": updatedStudent.emergencyContactPhone,
                "profileImageURL": updatedStudent.profileImageURL ?? "",
                "membershipStartDate": Timestamp(
                    date: updatedStudent.membershipStartDate),
                "isActive": updatedStudent.isActive,
                "createdAt": Timestamp(date: updatedStudent.createdAt),
                "updatedAt": Timestamp(date: updatedStudent.updatedAt),
            ]

            try await db.collection("students")
                .document(currentUser.uid)
                .setData(studentData)

            currentStudent = updatedStudent
            isSuccess = true

        } catch {
            print(
                "error - Failed to save student profile: \(error.localizedDescription)"
            )
            alertMessage = "Failed to save profile. Please try again."
            showAlert = true
        }

        isLoading = false
    }

    //fetch the student data
    func fetchStudentProfile() async {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }

        isLoading = true

        do {
            let document = try await db.collection("students")
                .document(currentUser.uid)
                .getDocument()

            if document.exists, let data = document.data() {
                currentStudent = try parseStudentData(data)
            } else {
                currentStudent = nil
            }

        } catch {
            print(
                "error - Failed to fetch student profile: \(error.localizedDescription)"
            )
            alertMessage = "Failed to load profile. Please try again."
            showAlert = true
        }

        isLoading = false
    }

    //fetch student by ID for instructor views
    func fetchStudentById(studentId: String) async -> Student? {
        do {
            let document = try await db.collection("students")
                .document(studentId)
                .getDocument()

            if document.exists, let data = document.data() {
                return try parseStudentData(data)
            } else {
                print("error: Student with ID \(studentId) not found")
                return nil
            }

        } catch {
            print(
                "error - Failed to fetch student by ID: \(error.localizedDescription)"
            )
            return nil
        }
    }

    //fetch multiple students by IDs
    func fetchStudentsByIds(studentIds: [String]) async -> [Student] {
        var students: [Student] = []

        for studentId in studentIds {
            if let student = await fetchStudentById(studentId: studentId) {
                students.append(student)
            }
        }

        return students
    }

    //update student
    func updateStudentProfile(_ student: Student) async {
        await saveStudentProfile(student)
    }

    //delete
    func deleteStudentProfile() async {
        guard let currentUser = Auth.auth().currentUser else {
            alertMessage = "No authenticated user found"
            showAlert = true
            return
        }

        isLoading = true

        do {
            try await db.collection("students")
                .document(currentUser.uid)
                .delete()

            currentStudent = nil
            print("Student profile deleted successfully")

        } catch {
            print(
                "error - Failed to delete student profile: \(error.localizedDescription)"
            )
            alertMessage = "Failed to delete profile. Please try again."
            showAlert = true
        }

        isLoading = false
    }

    private func parseStudentData(_ data: [String: Any]) throws -> Student {
        guard
            let id = data["id"] as? String,
            let firstName = data["firstName"] as? String,
            let lastName = data["lastName"] as? String,
            let email = data["email"] as? String
        else {
            throw NSError(
                domain: "StudentViewModel", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid student data"])
        }

        let phoneNumber = data["phoneNumber"] as? String ?? ""

        let dateOfBirth: Date
        if let timestamp = data["dateOfBirth"] as? Timestamp {
            dateOfBirth = timestamp.dateValue()
        } else {
            dateOfBirth = Date()
        }

        let genderString =
            data["gender"] as? String ?? Student.Gender.preferNotToSay.rawValue
        let gender = Student.Gender(rawValue: genderString) ?? .preferNotToSay

        let weight = data["weight"] as? Double ?? 0
        let height = data["height"] as? Double ?? 0

        let fitnessLevelString =
            data["fitnessLevel"] as? String
            ?? Student.FitnessLevel.beginner.rawValue
        let fitnessLevel =
            Student.FitnessLevel(rawValue: fitnessLevelString) ?? .beginner

        let healthConditions = data["healthConditions"] as? String ?? ""
        let fitnessGoals = data["fitnessGoals"] as? [String] ?? []
        let emergencyContactName = data["emergencyContactName"] as? String ?? ""
        let emergencyContactPhone =
            data["emergencyContactPhone"] as? String ?? ""
        let profileImageURL = data["profileImageURL"] as? String

        let membershipStartDate: Date
        if let timestamp = data["membershipStartDate"] as? Timestamp {
            membershipStartDate = timestamp.dateValue()
        } else {
            membershipStartDate = Date()
        }

        let isActive = data["isActive"] as? Bool ?? true

        var student = Student(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            dateOfBirth: dateOfBirth,
            gender: gender,
            weight: weight,
            height: height,
            fitnessLevel: fitnessLevel,
            healthConditions: healthConditions,
            fitnessGoals: fitnessGoals,
            emergencyContactName: emergencyContactName,
            emergencyContactPhone: emergencyContactPhone,
            profileImageURL: profileImageURL,
            membershipStartDate: membershipStartDate,
            isActive: isActive
        )

        if let createdAtTimestamp = data["createdAt"] as? Timestamp {
            student.createdAt = createdAtTimestamp.dateValue()
        }

        if let updatedAtTimestamp = data["updatedAt"] as? Timestamp {
            student.updatedAt = updatedAtTimestamp.dateValue()
        }

        return student
    }
}
