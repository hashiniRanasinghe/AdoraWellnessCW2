//
//  Session.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-16.
//

import Foundation

struct Session: Identifiable, Codable {
    let id: String
    let instructorId: String
    let title: String
    let description: String
    let startTime: String
    let endTime: String
    let durationMinutes: Int
    let price: Double
    let sessionType: String
    let date: Date
    let createdAt: Date
    let level: String
    let registeredStudents: [String]  //array of enrolled student IDs

    init(
        id: String, instructorId: String, title: String, description: String,
        startTime: String, endTime: String, durationMinutes: Int, price: Double,
        sessionType: String, date: Date, createdAt: Date, level: String,
        registeredStudents: [String] = []
    ) {
        self.id = id
        self.instructorId = instructorId
        self.title = title
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.durationMinutes = durationMinutes
        self.price = price
        self.sessionType = sessionType
        self.date = date
        self.createdAt = createdAt
        self.level = level
        self.registeredStudents = registeredStudents
    }
}
