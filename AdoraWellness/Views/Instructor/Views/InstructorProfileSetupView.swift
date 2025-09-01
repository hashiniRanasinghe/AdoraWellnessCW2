//
//  InstructorProfileSetupView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-13.
//

import FirebaseAuth
import SwiftUI

struct InstructorProfileSetupView: View {
    @StateObject private var viewModel = InstructorViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToDashboard = false

    //basic info
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = ""
    @State private var dateOfBirth = Date()

    //physical info
    @State private var address: String = ""
    @State private var studioName: String = ""
    @State private var city: String = ""
    @State private var country: String = ""

    //professional info
    @State private var certifications: String = ""
    @State private var experience: Int = 0
    @State private var hourlyRate: String = ""
    @State private var selectedSpecialities: Set<Instructor.Speciality> = []
    @State private var bio: String = ""

    //experience and fees
    private let experienceOptions = Array(0...30)
    private let countries = [
        "Sri Lanka", "United States", "United Kingdom", "Canada", "Australia",
        "India", "Singapore",
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                headerSection
                    .padding(.top, 40)
                    .padding(.bottom, 32)

                VStack(spacing: 28) {
                    basicInfoSection
                    addressSection
                    professionalInfoSection
                    specialitiesSection
                    bioSection
                }
                .padding(.horizontal, 24)

                saveButton
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .padding(.bottom, 100)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToDashboard) {
            InstructorDashboardView()
                .environmentObject(authViewModel)
                .navigationBarBackButtonHidden(true)
        }
        .alert("Profile Setup", isPresented: $viewModel.showAlert) {
            Button("OK") {}
        } message: {
            Text(viewModel.alertMessage ?? "Something went wrong")
        }
        .onAppear {
            loadUserInfo()
        }
        .onChange(of: viewModel.isSuccess) {
            if viewModel.isSuccess {
                print("Instructor profile saved successfully")

                //account created flag
                authViewModel.showAccountCreatedScreen = false

                //dashboard nav
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    navigateToDashboard = true
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                }

                Text("Share your expertise\nwith our community")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    //match the font size with the screen size
                    .minimumScaleFactor(0.8)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)

            Text("Help us understand your professional background")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            //name
            HStack(spacing: 12) {
                InputView(
                    text: $firstName,
                    title: "First Name",
                    placeholder: "Enter first name"
                )

                InputView(
                    text: $lastName,
                    title: "Last Name",
                    placeholder: "Enter last name"
                )
            }

            //phone
            InputView(
                text: $phoneNumber,
                title: "Phone Number",
                placeholder: "e.g. 0772537892"
            )
            .keyboardType(.phonePad)

            //dob
            VStack(alignment: .leading, spacing: 12) {
                Text("Date of Birth")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                DatePicker(
                    "Select your date of birth",
                    selection: $dateOfBirth,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(CompactDatePickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .tint(Color(red: 0.4, green: 0.3, blue: 0.8))
                .padding(.vertical, 4)
            }
        }
    }

    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            InputView(
                text: $studioName,
                title: "Studio Name",
                placeholder: "Studio Name"
            )
            InputView(
                text: $address,
                title: "Address",
                placeholder: "e.g. 123 Main Street, Anytown"
            )

            HStack(spacing: 12) {
                InputView(
                    text: $city,
                    title: "City",
                    placeholder: "City"
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text("Country")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)

                    Menu {
                        ForEach(countries, id: \.self) { countryOption in
                            Button(countryOption) {
                                country = countryOption
                            }
                        }
                    } label: {
                        //looks when closed
                        HStack {
                            Text(country.isEmpty ? "Country" : country)
                                .foregroundColor(
                                    country.isEmpty ? .secondary : .primary
                                )
                                .font(.system(size: 16))
                            Spacer()
                           // chevron icon
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    private var professionalInfoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            InputView(
                text: $certifications,
                title: "Certifications/Reg No.",
                placeholder: "e.g. RYT-200, RYT-500"
            )

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Years of Experience")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)

                    Menu {
                        ForEach(experienceOptions, id: \.self) { years in
                            Button("\(years) \(years == 1 ? "year" : "years")")
                            {
                                experience = years
                            }
                        }
                    } label: {
                        HStack {
                            Text(
                                "\(experience) \(experience == 1 ? "year" : "years")"
                            )
                            .foregroundColor(.primary)
                            .font(.system(size: 16))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                }

                InputView(
                    text: $hourlyRate,
                    title: "Hourly Rate ($)",
                    placeholder: "0"
                )
                .keyboardType(.decimalPad)
            }
        }
    }

    private var specialitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Specialities")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)

            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: 12), count: 3),
                spacing: 12
            ) {
                ForEach(Instructor.Speciality.allCases, id: \.self) {
                    speciality in
                    Button(action: {
                        if selectedSpecialities.contains(speciality) {
                            selectedSpecialities.remove(speciality)
                        } else {
                            selectedSpecialities.insert(speciality)
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(
                                systemName: selectedSpecialities.contains(
                                    speciality)
                                    ? "checkmark.circle.fill" : "circle"
                            )
                            .foregroundColor(
                                selectedSpecialities.contains(speciality)
                                    ? Color(red: 0.4, green: 0.3, blue: 0.8)
                                    : .gray
                            )
                            .font(.system(size: 16))

                            Text(speciality.displayName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    selectedSpecialities.contains(speciality)
                                        ? Color(red: 0.4, green: 0.3, blue: 0.8)
                                            .opacity(0.1)
                                        : Color(.systemGray6)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    selectedSpecialities.contains(speciality)
                                        ? Color(red: 0.4, green: 0.3, blue: 0.8)
                                        : Color(.systemGray4),
                                    lineWidth: 1
                                )
                        )
                    }
                }
            }
        }
    }

    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bio")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)

            TextEditor(text: $bio)
                .font(.system(size: 16))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .frame(minHeight: 120)
                .tint(Color(.systemGray2))

            if bio.isEmpty {
                HStack {
                    Text(
                        "Tell us about your yoga journey and teaching philosophy..."
                    )
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, -108)
                .allowsHitTesting(false)
            }
        }
    }

    private var saveButton: some View {
        Button(action: {
            Task {
                await saveProfile()
            }
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else {
                    Text("Confirmation")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                formIsValid && !viewModel.isLoading
                    ? Color(red: 0.4, green: 0.3, blue: 0.8)
                    : Color.gray
            )
            .cornerRadius(28)
        }
        .disabled(!formIsValid || viewModel.isLoading)
    }

    private var formIsValid: Bool {
        return !firstName.isEmpty && !lastName.isEmpty && !phoneNumber.isEmpty
            && !address.isEmpty && !city.isEmpty && !country.isEmpty
            && !selectedSpecialities.isEmpty
    }

    private func loadUserInfo() {
        guard let user = authViewModel.currentUser else {
            print("No current user found")
            return
        }

        let nameParts = user.fullname.components(separatedBy: " ")
        if nameParts.count >= 2 {
            firstName = nameParts[0]
            lastName = nameParts[1...].joined(separator: " ")
        } else {
            firstName = user.fullname
        }
    }

    private func saveProfile() async {
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user")
            return
        }

        let specialitiesArray = selectedSpecialities.map { $0.rawValue }

        let instructor = Instructor(
            id: currentUser.uid,
            firstName: firstName,
            lastName: lastName,
            email: currentUser.email ?? "",
            phoneNumber: phoneNumber,
            dateOfBirth: dateOfBirth,
            address: address,
            studioName: studioName,
            city: city,
            country: country,
            specialities: specialitiesArray,
            certifications: certifications,
            experience: experience,
            hourlyRate: Double(hourlyRate) ?? 0.0,
            bio: bio
        )

        await viewModel.saveInstructorProfile(instructor)
    }
}

struct InstructorProfileSetupView_Preview: PreviewProvider {
    static var previews: some View {
        InstructorProfileSetupView()
            .environmentObject(AuthViewModel())
    }
}
