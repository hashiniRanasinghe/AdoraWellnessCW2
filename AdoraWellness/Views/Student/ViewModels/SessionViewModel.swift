//
//  SessionViewModel.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-16.
//

import FirebaseFirestore
import Foundation

@MainActor
class SessionViewModel: ObservableObject {
    @Published var sessions: [Session] = []
    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var showAlert = false

    private let db = Firestore.firestore()

    // fetch sessions by instructor
    func fetchSessionsByInstructor(instructorId: String) async -> [Session] {
        isLoading = true

        do {
            let querySnapshot = try await db.collection("sessions")
                .whereField("instructorId", isEqualTo: instructorId)
                .getDocuments()

            var sessions: [Session] = []

            for document in querySnapshot.documents {
                if let session = try? parseSessionData(
                    document.data(), documentId: document.documentID)
                {

                    sessions.append(session)

                }
            }

            // sort the sessions in memory instead of in the query
            sessions.sort { $0.date < $1.date }

            isLoading = false
            return sessions

        } catch {
            print(
                "error - Failed to fetch sessions: \(error.localizedDescription)"
            )
            alertMessage = "Failed to load sessions. Please try again."
            showAlert = true
            isLoading = false
            return []
        }
    }
    // check if student is already registered for a session
    func isStudentRegistered(sessionId: String, studentId: String) async -> Bool
    {
        do {
            let document = try await db.collection("sessions").document(
                sessionId
            ).getDocument()

            if let data = document.data(),
                let registeredStudents = data["registeredStudents"] as? [String]
            {
                return registeredStudents.contains(studentId)
            }

            return false

        } catch {
            print(
                "error - Failed to check student registration: \(error.localizedDescription)"
            )
            return false
        }
    }
    // register student for a session
    func registerStudentForSession(sessionId: String, studentId: String) async
        -> Bool
    {
        do {
            let sessionRef = db.collection("sessions").document(sessionId)

            // FieldValue.arrayUnion to add the student ID to the registeredStudents array
            //create the array if it doesn't exist, or add to it
            try await sessionRef.updateData([
                "registeredStudents": FieldValue.arrayUnion([studentId])
            ])

            print(
                "successfully registered student \(studentId) for session \(sessionId)"
            )
            return true

        } catch {
            print(
                "error - Failed to register student: \(error.localizedDescription)"
            )
            alertMessage = "Failed to book session. Please try again."
            showAlert = true
            return false
        }
    }

    // parse session data from db
    private func parseSessionData(_ data: [String: Any], documentId: String)
        throws -> Session
    {
        guard
            let instructorId = data["instructorId"] as? String,
            let title = data["title"] as? String,
            let startTime = data["startTime"] as? String,
            let endTime = data["endTime"] as? String,
            let durationMinutes = data["durationMinutes"] as? Int,
            let price = data["price"] as? Double
        else {
            throw NSError(
                domain: "SessionViewModel",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid session data"]
            )
        }

        let description = data["description"] as? String ?? ""
        let sessionType = data["sessionType"] as? String ?? "Online"
        let level = data["level"] as? String ?? "Beginner"

        let date: Date
        if let timestamp = data["date"] as? Timestamp {
            date = timestamp.dateValue()
        } else {
            date = Date()
        }

        let createdAt: Date
        if let timestamp = data["createdAt"] as? Timestamp {
            createdAt = timestamp.dateValue()
        } else {
            createdAt = Date()
        }
        let registeredStudents = data["registeredStudents"] as? [String] ?? []

        return Session(
            id: documentId,
            instructorId: instructorId,
            title: title,
            description: description,
            startTime: startTime,
            endTime: endTime,
            durationMinutes: durationMinutes,
            price: price,
            sessionType: sessionType,
            date: date,
            createdAt: createdAt,
            level: level,
            registeredStudents: registeredStudents
        )
    }

    // fetch all sessions from database
    func fetchAllSessions() async -> [Session] {
        isLoading = true

        do {
            let querySnapshot = try await db.collection("sessions")
                .getDocuments()

            var sessions: [Session] = []

            for document in querySnapshot.documents {
                if let session = try? parseSessionData(
                    document.data(), documentId: document.documentID)
                {
                    sessions.append(session)
                }
            }

            //sort sessions by date
            sessions.sort { $0.date < $1.date }

            isLoading = false
            return sessions

        } catch {
            print(
                "error - Failed to fetch all sessions: \(error.localizedDescription)"
            )
            alertMessage = "Failed to load sessions. Please try again."
            showAlert = true
            isLoading = false
            return []
        }
    }
}
