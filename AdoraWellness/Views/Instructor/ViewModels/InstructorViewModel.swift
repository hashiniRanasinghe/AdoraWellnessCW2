//
//  InstructorViewModel.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-13.
//

import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
class InstructorViewModel: ObservableObject {
    @Published var currentInstructor: Instructor?
    @Published var alertMessage: String?
    @Published var showAlert = false
    @Published var isLoading = false
    @Published var isSuccess = false

    private let db = Firestore.firestore()
    //CLGeocoder from CoreLocation convert human-readable address to geographical coordinates -latitude & longitude
    private let geocoder = CLGeocoder()

    //save instructor data to db
    func saveInstructorProfile(_ instructor: Instructor) async {
        guard let currentUser = Auth.auth().currentUser else {
            alertMessage = "No authenticated user found"
            showAlert = true
            return
        }

        isLoading = true

        do {
            //copy of the instructor
            var updatedInstructor = instructor

            updatedInstructor.updatedAt = Date()

            //geocode adress to mapkit coordinate
            if !instructor.address.isEmpty && !instructor.city.isEmpty
                && !instructor.country.isEmpty
            {
                let coordinates = await geocodeAddress(instructor.fullAddress)
                updatedInstructor.latitude = coordinates?.latitude
                updatedInstructor.longitude = coordinates?.longitude
            }

            //make dictionary for firestore
            let instructorData: [String: Any] = [
                "id": updatedInstructor.id,
                "firstName": updatedInstructor.firstName,
                "lastName": updatedInstructor.lastName,
                "email": updatedInstructor.email,
                "phoneNumber": updatedInstructor.phoneNumber,
                "dateOfBirth": Timestamp(date: updatedInstructor.dateOfBirth),
                "address": updatedInstructor.address,
                "studioName": updatedInstructor.studioName,
                "city": updatedInstructor.city,
                "country": updatedInstructor.country,
                "latitude": updatedInstructor.latitude ?? 0.0,
                "longitude": updatedInstructor.longitude ?? 0.0,
                "specialities": updatedInstructor.specialities,
                "certifications": updatedInstructor.certifications,
                "experience": updatedInstructor.experience,
                "hourlyRate": updatedInstructor.hourlyRate,
                "bio": updatedInstructor.bio,
                "isActive": updatedInstructor.isActive,
                "createdAt": Timestamp(date: updatedInstructor.createdAt),
                "updatedAt": Timestamp(date: updatedInstructor.updatedAt),
            ]

            try await db.collection("instructors")
                .document(currentUser.uid)
                .setData(instructorData)

            currentInstructor = updatedInstructor
            isSuccess = true

        } catch {
            print(
                "failed to save instructor profile: \(error.localizedDescription)"
            )
            alertMessage = "Failed to save profile. Please try again."
            showAlert = true
        }

        isLoading = false
    }

    //fetch instructor data from db
    func fetchInstructorProfile() async {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }

        isLoading = true

        do {
            let document = try await db.collection("instructors")
                .document(currentUser.uid)
                .getDocument()

            if document.exists, let data = document.data() {
                currentInstructor = try parseInstructorData(data)
            } else {
                print("No instructor profile found")
                currentInstructor = nil
            }

        } catch {
            print(
                "Failed to fetch instructor profile: \(error.localizedDescription)"
            )
            alertMessage = "Failed to load profile. Please try again."
            showAlert = true
        }

        isLoading = false
    }

    //update
    func updateInstructorProfile(_ instructor: Instructor) async {
        await saveInstructorProfile(instructor)
    }

    //delete
    func deleteInstructorProfile() async {
        guard let currentUser = Auth.auth().currentUser else {
            alertMessage = "No authenticated user found"
            showAlert = true
            return
        }

        isLoading = true

        do {
            try await db.collection("instructors")
                .document(currentUser.uid)
                .delete()

            currentInstructor = nil
            print("Instructor profile deleted successfully")

        } catch {
            print(
                "Failed to delete instructor profile: \(error.localizedDescription)"
            )
            alertMessage = "Failed to delete profile. Please try again."
            showAlert = true
        }

        isLoading = false
    }

    //fetch all instructors
    func fetchAllInstructors() async -> [Instructor] {
        do {
            let querySnapshot = try await db.collection("instructors")
                .whereField("isActive", isEqualTo: true)
                .getDocuments()

            var instructors: [Instructor] = []

            for document in querySnapshot.documents {
                if let instructor = try? parseInstructorData(document.data()) {
                    instructors.append(instructor)
                }
            }

            return instructors

        } catch {
            print(
                "Failed to fetch instructors: \(error.localizedDescription)"
            )
            return []
        }
    }

    //returns coordinates latitude & longitude
    private func geocodeAddress(_ address: String) async
        -> CLLocationCoordinate2D?
    {
        do {
            //search results maybe multiple matches
            let placemarks = try await geocoder.geocodeAddressString(address)
            //take the first match
            guard let location = placemarks.first?.location else {
                print("No location found for address: \(address)")
                return nil
            }

            print(
                "geocoded address successfully: \(location.coordinate)")
            return location.coordinate

        } catch {
            print(
                "error - Failed to geocode address: \(error.localizedDescription)"
            )
            return nil
        }
    }

    private func parseInstructorData(_ data: [String: Any]) throws
        -> Instructor?
    {
        //check required data
        guard
            let id = data["id"] as? String,
            let firstName = data["firstName"] as? String,
            let lastName = data["lastName"] as? String,
            let email = data["email"] as? String
        else {
            print("Invalid instructor data")
            return nil
        }

        let phoneNumber = data["phoneNumber"] as? String ?? ""
        let address = data["address"] as? String ?? ""
        let studioName = data["studioName"] as? String ?? ""
        let city = data["city"] as? String ?? ""
        let country = data["country"] as? String ?? ""
        let latitude = data["latitude"] as? Double
        let longitude = data["longitude"] as? Double
        let specialities = data["specialities"] as? [String] ?? []
        let certifications = data["certifications"] as? String ?? ""
        let experience = data["experience"] as? Int ?? 0
        let hourlyRate = data["hourlyRate"] as? Double ?? 0.0
        let bio = data["bio"] as? String ?? ""
        let isActive = data["isActive"] as? Bool ?? true

        let dateOfBirth: Date
        if let timestamp = data["dateOfBirth"] as? Timestamp {
            //converts firestore’s timestamp into swift’s date
            dateOfBirth = timestamp.dateValue()
        } else {
            dateOfBirth = Date()
        }

        var instructor = Instructor(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            dateOfBirth: dateOfBirth,
            address: address,
            studioName: studioName,
            city: city,
            country: country,
            latitude: latitude,
            longitude: longitude,
            specialities: specialities,
            certifications: certifications,
            experience: experience,
            hourlyRate: hourlyRate,
            bio: bio,
            isActive: isActive
        )

        if let createdAtTimestamp = data["createdAt"] as? Timestamp {
            instructor.createdAt = createdAtTimestamp.dateValue()
        }

        if let updatedAtTimestamp = data["updatedAt"] as? Timestamp {
            instructor.updatedAt = updatedAtTimestamp.dateValue()
        }

        return instructor
    }
}
