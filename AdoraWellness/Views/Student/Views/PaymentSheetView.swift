//
//  PaymentSheetView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-16.
//

import LocalAuthentication
import SwiftUI

struct PaymentSheetView: View {
    let session: Session
    let instructor: Instructor
    @Binding var isPresented: Bool
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var showingBiometricAlert = false
    @State private var paymentSuccessful = false
    @State private var isProcessing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    Text("Session Details")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Spacer()

                    //                    Button(action: {
                    //                    }) {
                    //                        Image(systemName: "heart.fill")
                    //                            .font(.title2)
                    //                            .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                    //                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 32)

                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        //session data
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(
                                    "\(session.title) • \(session.durationMinutes) min"
                                )
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.primary)

                                Spacer()
                            }

                            Text(
                                session.description.isEmpty
                                    ? Utils.getDefaultDescription()
                                    : session.description
                            )
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .lineLimit(nil)
                        }
                        .padding(.horizontal, 24)

                        //session sum
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Summary")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)

                            VStack(spacing: 20) {
                                SummaryRow(
                                    title: "Instructor",
                                    value: instructor.fullName)
                                SummaryRow(
                                    title: "Date",
                                    value: Utils.formatDate(session.date))
                                SummaryRow(
                                    title: "Time",
                                    value: Utils.formatTimeRange(
                                        startTime: session.startTime,
                                        endTime: session.endTime))

                                Divider()
                                    .background(Color(.systemGray4))
                            }
                            .padding(20)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)

                        //payment
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Payment Details")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)

                            VStack(spacing: 16) {
                                HStack {
                                    Text("Session Fee")
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary)

                                    Spacer()

                                    Text(
                                        "$\(String(format: "%.2f", session.price))"
                                    )
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                }
                                .padding(16)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)

                                //card section
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Credit card details")
                                        .font(
                                            .system(size: 16, weight: .medium)
                                        )
                                        .foregroundColor(.primary)

                                    //card feild
                                    HStack {
                                        TextField(
                                            "0000 0000 0000 0000",
                                            text: $cardNumber
                                        )
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .keyboardType(.numberPad)
                                        .tint(.gray)
                                        .onChange(of: cardNumber) {
                                            oldValue, newValue in
                                            cardNumber = formatCardNumber(
                                                newValue)
                                        }

                                        Spacer()

                                        //card type
                                        HStack(spacing: 8) {
                                            Image(systemName: "creditcard.fill")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 16))

                                        }
                                    }
                                    .padding(16)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)

                                    //exp and cvc
                                    HStack(spacing: 16) {
                                        HStack {
                                            TextField(
                                                "MM / YYYY", text: $expiryDate
                                            )
                                            .textFieldStyle(
                                                PlainTextFieldStyle()
                                            )
                                            .keyboardType(.numberPad)
                                            .tint(.gray)
                                            .onChange(of: expiryDate) {
                                                _, newValue in
                                                expiryDate = formatExpiryDate(
                                                    newValue)
                                            }

                                            Image(systemName: "calendar")
                                                .foregroundColor(.secondary)
                                                .font(.system(size: 16))
                                        }
                                        .padding(16)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)

                                        HStack {
                                            TextField("CVC", text: $cvv)
                                                .textFieldStyle(
                                                    PlainTextFieldStyle()
                                                )
                                                .keyboardType(.numberPad)
                                                .tint(.gray)
                                                .onChange(of: cvv) {
                                                    _, newValue in
                                                    if newValue.count > 3 {
                                                        cvv = String(
                                                            newValue.prefix(3))
                                                    }
                                                }

                                            Image(systemName: "shield.fill")
                                                .foregroundColor(.secondary)
                                                .font(.system(size: 16))
                                        }
                                        .padding(16)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(
                                    color: Color.black.opacity(0.05), radius: 4,
                                    x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal, 24)

                        Spacer(minLength: 120)
                    }
                }

                //pay btn
                VStack(spacing: 0) {
                    Button(action: {
                        handlePayment()
                    }) {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(
                                        CircularProgressViewStyle(tint: .white)
                                    )
                                    .scaleEffect(0.8)
                                Text("Processing...")
                            } else {
                                Text("Pay")
                            }
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.4, green: 0.3, blue: 0.8))
                        .cornerRadius(24)
                    }
                    .disabled(isProcessing || !isFormValid())
                    .opacity(isFormValid() && !isProcessing ? 1.0 : 0.6)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                }
            }
            .background(Color.white)
            .ignoresSafeArea(.all, edges: .bottom)
            //open success screen
            .fullScreenCover(
                isPresented: $paymentSuccessful
            ) {
                PaymentSuccessView(
                    session: session,
                    instructor: instructor,
                    isPresented: $isPresented
                )
            }
        }
        .navigationBarHidden(true)
        //        .alert("Payment Successful", isPresented: $paymentSuccessful) {
        //            Button("OK") {
        //                isPresented = false
        //            }
        //        } message: {
        //            Text("Your session has been booked successfully!")
        //        }
    }

    private func handlePayment() {
        guard isFormValid() else { return }

        isProcessing = true
        authenticateWithBiometrics()
    }

    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?

        //check for face id or touch id
        if context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics, error: &error)
        {
            let reason = "Authenticate to complete your session payment"

            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            ) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        //faceid or touch id scusscess
                        processPayment()
                    } else {
                        //faceid or touch id failed
                        isProcessing = false
                        //fallback - use pass code
                        authenticateWithPasscode()
                    }
                }
            }
        } else {
            // no faceid or touch id - use passcode
            print("no face id or touch id")
            authenticateWithPasscode()
        }
    }

    private func authenticateWithPasscode() {
        let context = LAContext()
        let reason = "Authenticate to complete your session payment"

        context.evaluatePolicy(
            .deviceOwnerAuthentication, localizedReason: reason
        ) { success, error in
            DispatchQueue.main.async {
                if success {
                    processPayment()
                } else {
                    isProcessing = false
                    //authentication faild
                    print(
                        "Authentication failed: \(error?.localizedDescription ?? "Unknown error")"
                    )
                }
            }
        }
    }

    private func processPayment() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            paymentSuccessful = true
        }
    }

    private func isFormValid() -> Bool {
        return !cardNumber.isEmpty && !expiryDate.isEmpty && !cvv.isEmpty
            && cardNumber.replacingOccurrences(of: " ", with: "").count >= 16
            && cvv.count == 3
    }

    private func formatCardNumber(_ number: String) -> String {
        let cleanNumber = number.replacingOccurrences(of: " ", with: "")
        let limitedNumber = String(cleanNumber.prefix(16))

        var formatted = ""
        for (index, character) in limitedNumber.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted += " "
            }
            formatted += String(character)
        }
        return formatted
    }

    private func formatExpiryDate(_ date: String) -> String {
        let cleanDate = date.replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: " ", with: "")
        let limitedDate = String(cleanDate.prefix(6))

        if limitedDate.count >= 3 {
            let month = String(limitedDate.prefix(2))
            let year = String(limitedDate.suffix(limitedDate.count - 2))
            return "\(month) / \(year)"
        }
        return limitedDate
    }
}

struct PaymentSheetView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentSheetView(
            session: Session(
                id: "1",
                instructorId: "1",
                title: "Morning Flow",
                description:
                    "Gentle, slow-paced with basic postures Vinyasa - Flow-style linking breath with movement Ashtanga - Athletic, fast-paced with set sequences Yin",
                startTime: "09:00",
                endTime: "10:00",
                durationMinutes: 60,
                price: 87.10,
                sessionType: "Online",
                date: Date(),
                createdAt: Date(),
                level: "1"
            ),
            instructor: Instructor(
                id: "1",
                firstName: "Adam",
                lastName: "Dalva",
                email: "adam@example.com",
                phoneNumber: "123-456-7890",
                dateOfBirth: Date(),
                address: "123 Main St",
                city: "New York",
                country: "United States",
                latitude: 40.7128,
                longitude: -74.0060,
                specialities: ["Yoga", "Pilates"],
                certifications: "Certified Yoga Instructor",
                experience: 5,
                hourlyRate: 35.0,
                bio: "Experienced yoga instructor with a passion for wellness.",
                isActive: true
            ),
            isPresented: .constant(true)
        )
    }
}
