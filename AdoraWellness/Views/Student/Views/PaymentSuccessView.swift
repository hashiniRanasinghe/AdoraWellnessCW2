//
//  PaymentSuccessView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-16.
//

import EventKit
import EventKitUI
import SwiftUI

struct PaymentSuccessView: View {
    let session: Session
    let instructor: Instructor
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                //img
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .frame(height: 150)

                        if let logoImage = UIImage(
                            named: "Mollitiam.jpeg")
                        {
                            Image(uiImage: logoImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 350, height: 350)
                                .clipped()
                                .cornerRadius(20)
                        }
                    }

                    .padding(.horizontal, 40)
                }

                Spacer()

                //message
                VStack(spacing: 16) {
                    Text("Congratulation!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)

                    Text(
                        "Your yoga session has been successfully booked - You'll receive a confirmation email shortly"
                    )
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 32)
                }
                //back to home btn
                VStack {
                    HStack {
                        NavigationLink(destination: DashboardView()) {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .font(.title2)
                                Text("Back to Home")
                                    .font(.headline)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)

                    Spacer()
                }

                //buttons
                VStack(spacing: 16) {
                    Spacer()
                    Button("Add to Reminder") {
                        isPresented = false
                    }
                    .primaryButtonStyle()
                    .frame(maxWidth: 350)

                    Button("Add to Calendar") {
                        addToCalendar()
                    }
                    .secondaryButtonStyle()
                    .frame(maxWidth: 350)

                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }

            .background(Color.white)
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }

    private func addToCalendar() {
        let eventStore = EKEventStore()

        // request access
        eventStore.requestWriteOnlyAccessToEvents { granted, error in
            guard granted else { return }

            let event = EKEvent(eventStore: eventStore)
            event.title = session.title
            event.startDate = session.date
            event.endDate = Calendar.current.date(
                byAdding: .minute, value: session.durationMinutes,
                to: session.date)
            event.notes =
                "Yoga session with \(instructor.firstName) \(instructor.lastName)"
            event.calendar = eventStore.defaultCalendarForNewEvents

            do {
                try eventStore.save(event, span: .thisEvent)
                print("Event saved to calendar!")
            } catch {
                print("Failed to save event: \(error)")
            }
        }
    }
}

struct PaymentSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentSuccessView(
            session: Session(
                id: "session_001",
                instructorId: "instructor_001",
                title: "Morning Vinyasa Flow",
                description:
                    "An energizing 60-minute vinyasa flow perfect for starting your day. Suitable for intermediate practitioners.",
                startTime: "09:00",
                endTime: "10:00",
                durationMinutes: 60,
                price: 45.00,
                sessionType: "Online",
                date: Calendar.current.date(
                    byAdding: .day, value: 1, to: Date()) ?? Date(),
                createdAt: Date(),
                level: "Intermediate"
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
