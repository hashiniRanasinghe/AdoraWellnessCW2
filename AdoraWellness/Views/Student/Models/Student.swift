//
//  Student.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-10.
//

import FirebaseFirestore
import Foundation

struct Student: Identifiable, Codable {
    let id: String
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String
    var dateOfBirth: Date
    var gender: Gender
    var weight: Double  // in kg
    var height: Double  // in cm
    var fitnessLevel: FitnessLevel
    var healthConditions: String
    var fitnessGoals: [String]
    var emergencyContactName: String
    var emergencyContactPhone: String
    var profileImageURL: String?
    var membershipStartDate: Date
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    enum Gender: String, CaseIterable, Codable {
        case male = "male"
        case female = "female"
        case preferNotToSay = "prefer_not_to_say"

        var displayName: String {
            switch self {
            case .male: return "Male"
            case .female: return "Female"
            case .preferNotToSay: return "Prefer not to say"
            }
        }
    }

    enum FitnessLevel: String, CaseIterable, Codable {
        case beginner = "beginner"
        case intermediate = "intermediate"
        case advanced = "advanced"
        case expert = "expert"

        var displayName: String {
            switch self {
            case .beginner: return "Beginner"
            case .intermediate: return "Intermediate"
            case .advanced: return "Advanced"
            case .expert: return "Expert"
            }
        }
    }

    var fullName: String {
        return "\(firstName) \(lastName)"
    }

    var age: Int {
        let calendar = Calendar.current
        let now = Date()
        //calculates the difference between two dates in years
        let ageComponents = calendar.dateComponents(
            [.year], from: dateOfBirth, to: now)
        return ageComponents.year ?? 0
    }

    init(
        id: String,
        firstName: String,
        lastName: String,
        email: String,
        phoneNumber: String = "",
        dateOfBirth: Date = Date(),
        gender: Gender = .preferNotToSay,
        weight: Double = 0,
        height: Double = 0,
        fitnessLevel: FitnessLevel = .beginner,
        healthConditions: String = "",
        fitnessGoals: [String] = [],
        emergencyContactName: String = "",
        emergencyContactPhone: String = "",
        profileImageURL: String? = nil,
        membershipStartDate: Date = Date(),
        isActive: Bool = true
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.weight = weight
        self.height = height
        self.fitnessLevel = fitnessLevel
        self.healthConditions = healthConditions
        self.fitnessGoals = fitnessGoals
        self.emergencyContactName = emergencyContactName
        self.emergencyContactPhone = emergencyContactPhone
        self.profileImageURL = profileImageURL
        self.membershipStartDate = membershipStartDate
        self.isActive = isActive
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
