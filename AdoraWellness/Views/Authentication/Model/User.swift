//
//  User.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-08.
//

import Foundation

enum UserType: String, Codable {
    case student
    case instructor
}

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    let userType: UserType

    //computed user initials
    var initials: String {

        let formatter = PersonNameComponentsFormatter()  //built-in helper to understands names
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}

extension User {
    static var MOCK_USER = User(
        id: UUID().uuidString,
        fullname: "testuser",
        email: "test@gmail.com",
        userType: UserType(rawValue: "student") ?? .student
    )
}
