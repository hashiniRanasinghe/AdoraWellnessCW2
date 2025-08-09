//
//  User.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-08.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    let userType: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
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
        fullname: "Kobe Bryant",
        email: "test@gmail.com",
        userType: "student" 
    )
}
