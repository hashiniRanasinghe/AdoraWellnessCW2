//
//  SessionDetailsView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-16.
//

import SwiftUI

struct SessionDetailsView: View {
    let session: Session
    let instructor: Instructor

    @State private var showPaymentSheet = false
    @Environment(\.dismiss) private var dismiss
    @State private var isFavorite = false

    var body: some View {
        
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        HStack {
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }

                            Spacer()

                            Text("Book Session")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Spacer()

                            //                            Button(action: {
                            //                                isFavorite.toggle()
                            //                            }) {
                            //                                Image(
                            //                                    systemName: isFavorite
                            //                                        ? "heart.fill" : "heart"
                            //                                )
                            //                                .font(.title2)
                            //                                .foregroundColor(
                            //                                    isFavorite
                            //                                        ? Color(red: 0.4, green: 0.3, blue: 0.8)
                            //                                        : .primary)
                            //                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)

                        //session title and detials
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

                        //summary
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
                                SummaryRow(
                                    title: "Session Type",
                                    value: session.sessionType)
                                SummaryRow(
                                    title: "Duration",
                                    value: "\(session.durationMinutes) minutes")
                                SummaryRow(
                                    title: "Level",
                                    value: (session.level))

                            }
                            .padding(20)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)

                        Spacer(minLength: 100)
                    }
                }

                //confirmation btn
                VStack(spacing: 0) {
                    Button(action: {
                        showPaymentSheet = true
                        
                    }) {
                        Text("Confirmation")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0.4, green: 0.3, blue: 0.8))
                            .cornerRadius(24)
                    }.padding(.horizontal, 24)
                        .padding(.bottom, 34)
                }
            }
            .background(Color.white)
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showPaymentSheet) {
            PaymentSheetView(
                session: session, instructor: instructor,
                isPresented: $showPaymentSheet)
        }
    }
}

struct SummaryRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

struct SessionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionDetailsView(
            session: Session(
                id: "1",
                instructorId: "1",
                title: "Morning Flow",
                description:
                    "Gentle, slow-paced with basic postures Vinyasa - Flow-style linking breath with movement Ashtanga - Athletic, fast-paced with set sequences Yin",
                startTime: "09:00",
                endTime: "10:00",
                durationMinutes: 60,
                price: 35.0,
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
            )
        )
    }
}
