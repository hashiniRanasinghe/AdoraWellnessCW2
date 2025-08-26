//
//  Instructor.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-13.
//

import CoreLocation
import FirebaseFirestore
import Foundation

struct Instructor: Identifiable, Codable {
    let id: String
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String
    var dateOfBirth: Date
    var address: String
    var studioName: String
    var city: String
    var country: String
    var latitude: Double?
    var longitude: Double?
    var specialities: [String]
    var certifications: String
    var experience: Int
    var hourlyRate: Double
    var bio: String
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    enum Speciality: String, CaseIterable, Codable {
        case pilates = "pilates"
        case yoga = "yoga"
        case meditations = "meditations"

        var displayName: String {
            switch self {
            case .pilates: return "Pilates"
            case .yoga: return "Yoga"
            case .meditations: return "Meditations"
            }
        }
    }

    var fullName: String {
        return "\(firstName) \(lastName)"
    }

    var fullAddress: String {
        return "\(address), \(city), \(country)"
    }

    //convert adress to mapkit coordinate
    var coordinate: CLLocationCoordinate2D? {
        guard let latitude = latitude, let longitude = longitude else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(
        id: String,
        firstName: String,
        lastName: String,
        email: String,
        phoneNumber: String = "",
        dateOfBirth: Date = Date(),
        address: String = "",
        studioName: String = "",
        city: String = "",
        country: String = "",
        latitude: Double? = nil,
        longitude: Double? = nil,
        specialities: [String] = [],
        certifications: String = "",
        experience: Int = 0,
        hourlyRate: Double = 0.0,
        bio: String = "",
        isActive: Bool = true
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.dateOfBirth = dateOfBirth
        self.address = address
        self.studioName = studioName
        self.city = city
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.specialities = specialities
        self.certifications = certifications
        self.experience = experience
        self.hourlyRate = hourlyRate
        self.bio = bio
        self.isActive = isActive
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
