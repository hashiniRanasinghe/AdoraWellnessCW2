//
//  utilities.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-09.
//

import FirebaseAuth

struct Utils {
    static func userFriendlyErrorMessage(from error: Error) -> String {
        let nsError = error as NSError

        switch nsError.code {
        // login-related errors
        case AuthErrorCode.invalidEmail.rawValue:
            return "Please enter a valid email address."
        case AuthErrorCode.wrongPassword.rawValue:
            return "The password you entered is incorrect."
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found with this email. Please sign up first."
        case AuthErrorCode.userDisabled.rawValue:
            return "This account has been disabled. Contact support."

        // registration-related errors
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return
                "An account with this email already exists. Please sign in instead."
        case AuthErrorCode.weakPassword.rawValue:
            return "Password is too weak. Please use at least 6 characters."
        case AuthErrorCode.operationNotAllowed.rawValue:
            return "Email/password accounts are not enabled. Contact support."
        case AuthErrorCode.invalidCredential.rawValue:
            return "The credentials provided are invalid. Please try again."

        // network and general errors
        case AuthErrorCode.networkError.rawValue:
            return
                "Network connection failed. Please check your internet and try again."
        case AuthErrorCode.tooManyRequests.rawValue:
            return
                "Too many attempts. Please wait a moment before trying again."
        case AuthErrorCode.userTokenExpired.rawValue:
            return "Your session has expired. Please sign in again."
        case AuthErrorCode.requiresRecentLogin.rawValue:
            return "Please sign in again to complete this action."
        case AuthErrorCode.accountExistsWithDifferentCredential.rawValue:
            return
                "An account already exists with this email using a different sign-in method."

        default:
            return "Something went wrong. Please try again."
        }
    }
    static func greetingMessage() -> String {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 5..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        case 17..<22:
            return "Good evening"
        default:
            return "Good night"
        }
    }

    static func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"  //Tuesday, January 14, 2025
        return formatter.string(from: Date())
    }
    static func formatTimeRange(startTime: String, endTime: String) -> String {
        return "\(formatTime(startTime)) - \(formatTime(endTime))"
    }
    static func formatDate(_ date: Date, format: String? = nil) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format ?? "MMM d, yyyy"
        return formatter.string(from: date)
    }

    static func formatTime(_ time: String) -> String {
        let components = time.split(separator: ":")
        guard components.count >= 2,
            let hour = Int(components[0]),
            let minute = Int(components[1])
        else {
            return time
        }

        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)

        if minute == 0 {
            return "\(displayHour):00 \(period)"
        } else {
            return "\(displayHour):\(String(format: "%02d", minute)) \(period)"
        }
    }
    static func getDefaultDescription() -> String {
        return
            "Gentle, slow-paced with basic postures Vinyasa - Flow-style linking breath with movement Ashtanga - Athletic, fast-paced with set sequences Yin"
    }

    static func combineDateAndTime(date: Date, timeString: String) -> Date {
        let calendar = Calendar.current
        let timeComponents = timeString.split(separator: ":").compactMap {
            Int($0)
        }

        guard timeComponents.count >= 2 else { return date }

        var dateComponents = calendar.dateComponents(
            [.year, .month, .day], from: date)
        dateComponents.hour = timeComponents[0]
        dateComponents.minute = timeComponents[1]

        return calendar.date(from: dateComponents) ?? date
    }
}
