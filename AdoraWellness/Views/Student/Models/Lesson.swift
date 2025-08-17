//
//  Lesson.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-17.
//

import Firebase
import FirebaseFirestore
import Foundation

struct Lesson: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let subtitle: String
    let duration: Int  // in minutes
    let category: String  // Yoga, Pilates, Meditation
    let level: String  // Beginner, Intermediate, Advanced, All Levels
    let videoURL: String
    let thumbnailURL: String?
    let description: String
    let iconName: String
    let instructorId: String?
    let tags: [String]
    let equipment: [String]
    let calories: Int
    let difficulty: Int  // 1-5
    let isActive: Bool
    let viewCount: Int
    let favoriteCount: Int
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?

    //handleing firestore field names
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case duration
        case category
        case level
        case videoURL
        case thumbnailURL
        case description
        case iconName
        case instructorId
        case tags
        case equipment
        case calories
        case difficulty
        case isActive
        case viewCount
        case favoriteCount
        case createdAt
        case updatedAt
    }

    //initialize with default values
    init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String,
        duration: Int,
        category: String,
        level: String,
        videoURL: String = "",
        thumbnailURL: String? = nil,
        description: String,
        instructorId: String? = nil,
        tags: [String] = [],
        equipment: [String] = [],
        calories: Int = 0,
        difficulty: Int = 1,
        isActive: Bool = true,
        viewCount: Int = 0,
        favoriteCount: Int = 0,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {

        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
        self.category = category
        self.level = level
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
        self.description = description
        self.iconName = Self.iconForCategory(category)
        self.instructorId = instructorId
        self.tags = tags
        self.equipment = equipment
        self.calories = calories
        self.difficulty = difficulty
        self.isActive = isActive
        self.viewCount = viewCount
        self.favoriteCount = favoriteCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    //icon based on the category
    static func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "yoga":
            return "figure.mind.and.body"
        case "pilates":
            return "figure.core.training"
        case "meditation":
            return "brain.head.profile"
        case "cardio":
            return "heart.fill"
        case "strength":
            return "figure.strengthtraining.traditional"
        case "flexibility":
            return "figure.flexibility"
        case "balance":
            return "figure.walk"
        default:
            return "figure.mind.and.body"
        }
    }

    //fotmat duration
    var formattedDuration: String {
        if duration < 60 {
            return "\(duration) min"
        } else {
            let hours = duration / 60
            let minutes = duration % 60
            if minutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(minutes)m"
            }
        }
    }
}

//sample data
extension Lesson {
    static var sampleLessons: [Lesson] {
        [
            Lesson(
                id: "1",
                title: "Test data",
                subtitle: "Test data",
                duration: 20,
                category: "Test data",
                level: "Test data",
                description: "Test data",
                tags: ["Test data", "Test data", "Test data"],
                equipment: ["Test data"],
                calories: 80,
                difficulty: 2
            )
        ]
    }
}
