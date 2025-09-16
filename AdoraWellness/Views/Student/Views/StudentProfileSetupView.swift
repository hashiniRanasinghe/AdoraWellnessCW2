import FirebaseAuth
import SwiftUI

struct StudentProfileSetupView: View {
    @StateObject private var viewModel = StudentViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToDashboard = false

    //basic info
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = ""
    @State private var dateOfBirth = Date()
    @State private var selectedGender = Student.Gender.preferNotToSay

    //physical info
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var selectedFitnessLevel = Student.FitnessLevel.beginner

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                headerSection
                    .padding(.top, 40)
                    .padding(.bottom, 32)

                VStack(spacing: 28) {
                    basicInfoSection
                    physicalInfoSection
                    fitnessLevelSection
                }
                .padding(.horizontal, 24)

                saveButton
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .padding(.bottom, 100)
            }
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToDashboard) {
            DashboardView()
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

                //acc created flag
                authViewModel.showAccountCreatedScreen = false

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

                Text("Let's start\nunderstanding you")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)

            Text("Help us personalize your fitness journey")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            //name fields
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

            //phone no
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

            //gender
            VStack(alignment: .leading, spacing: 16) {
                Text("Gender")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                VStack(spacing: 12) {
                    ForEach(Student.Gender.allCases, id: \.self) { gender in
                        Button(action: {
                            selectedGender = gender
                        }) {
                            HStack(spacing: 12) {
                                Image(
                                    systemName: selectedGender == gender
                                        ? "checkmark.circle.fill" : "circle"
                                )
                                .foregroundColor(
                                    selectedGender == gender
                                        ? Color(red: 0.4, green: 0.3, blue: 0.8)
                                        : .gray
                                )
                                .font(.system(size: 20))

                                Text(gender.displayName)
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)
                                    .frame(
                                        maxWidth: .infinity, alignment: .leading
                                    )

                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        selectedGender == gender
                                            ? Color(
                                                red: 0.4, green: 0.3, blue: 0.8
                                            ).opacity(0.1) : Color(.systemGray6)
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        selectedGender == gender
                                            ? Color(
                                                red: 0.4, green: 0.3, blue: 0.8)
                                            : Color(.systemGray4), lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
    }

    private var physicalInfoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 16) {
                //weight
                VStack(alignment: .leading, spacing: 12) {
                    Text("Weight (kg)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)

                    TextField("50", text: $weight)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 16))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .tint(.gray)
                }

                //height
                VStack(alignment: .leading, spacing: 12) {
                    Text("Height (cm)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)

                    TextField("168", text: $height)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 16))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .tint(.gray)
                }
            }
        }
    }

    private var fitnessLevelSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fitness Level")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)

            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: 12), count: 2),
                spacing: 12
            ) {
                ForEach(Student.FitnessLevel.allCases, id: \.self) { level in
                    Button(action: {
                        selectedFitnessLevel = level
                    }) {
                        VStack(spacing: 8) {
                            Image(
                                systemName: selectedFitnessLevel == level
                                    ? "checkmark.circle.fill" : "circle"
                            )
                            .foregroundColor(
                                selectedFitnessLevel == level
                                    ? Color(red: 0.4, green: 0.3, blue: 0.8)
                                    : .gray
                            )
                            .font(.system(size: 20))

                            Text(level.displayName)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    selectedFitnessLevel == level
                                        ? Color(red: 0.4, green: 0.3, blue: 0.8)
                                            .opacity(0.1) : Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    selectedFitnessLevel == level
                                        ? Color(red: 0.4, green: 0.3, blue: 0.8)
                                        : Color(.systemGray4), lineWidth: 1)
                        )
                    }
                }
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
                    Text("Save Profile")
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

        let student = Student(
            id: currentUser.uid,
            firstName: firstName,
            lastName: lastName,
            email: currentUser.email ?? "",
            phoneNumber: phoneNumber,
            dateOfBirth: dateOfBirth,
            gender: selectedGender,
            weight: Double(weight) ?? 0,
            height: Double(height) ?? 0,
            fitnessLevel: selectedFitnessLevel
        )

        await viewModel.saveStudentProfile(student)
    }
}

struct StudentProfileSetupView_Preview: PreviewProvider {
    static var previews: some View {
        StudentProfileSetupView()
            .environmentObject(AuthViewModel())
    }
}
