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
        // Login-related errors
        case AuthErrorCode.invalidEmail.rawValue:
            return "Please enter a valid email address."
        case AuthErrorCode.wrongPassword.rawValue:
            return "The password you entered is incorrect."
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found with this email. Please sign up first."
        case AuthErrorCode.userDisabled.rawValue:
            return "This account has been disabled. Contact support."
        
        // Registration-related errors
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "An account with this email already exists. Please sign in instead."
        case AuthErrorCode.weakPassword.rawValue:
            return "Password is too weak. Please use at least 6 characters."
        case AuthErrorCode.operationNotAllowed.rawValue:
            return "Email/password accounts are not enabled. Contact support."
        case AuthErrorCode.invalidCredential.rawValue:
            return "The credentials provided are invalid. Please try again."
        
        // Network and general errors
        case AuthErrorCode.networkError.rawValue:
            return "Network connection failed. Please check your internet and try again."
        case AuthErrorCode.tooManyRequests.rawValue:
            return "Too many attempts. Please wait a moment before trying again."
        case AuthErrorCode.userTokenExpired.rawValue:
            return "Your session has expired. Please sign in again."
        case AuthErrorCode.requiresRecentLogin.rawValue:
            return "Please sign in again to complete this action."
        case AuthErrorCode.accountExistsWithDifferentCredential.rawValue:
            return "An account already exists with this email using a different sign-in method."
        
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
        formatter.dateFormat = "EEEE, MMMM d, yyyy" // e.g., Tuesday, January 14, 2025
        return formatter.string(from: Date())
    }
}
