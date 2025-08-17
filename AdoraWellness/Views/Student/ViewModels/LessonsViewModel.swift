//
//  LessonsViewModel.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-17.
//

import Firebase
import FirebaseFirestore
import Foundation

@MainActor
class LessonsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lessons: [Lesson] = []

    private let db = Firestore.firestore()

    //fetch all sessions
    func fetchAllLessons() async -> [Lesson] {
        isLoading = true
        errorMessage = nil

        do {
            let snapshot = try await db.collection("lessons")
                .getDocuments()

            let fetchedLessons = snapshot.documents.compactMap { document in
                try? document.data(as: Lesson.self)
            }

            lessons = fetchedLessons
            isLoading = false

            return fetchedLessons

        } catch {
            errorMessage =
                "Failed to load lessons: \(error.localizedDescription)"
            isLoading = false

            //if no lessions then returm the sample data
            return Lesson.sampleLessons
        }
    }

}
