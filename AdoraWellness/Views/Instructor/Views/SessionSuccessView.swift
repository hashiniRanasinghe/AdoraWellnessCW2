//
//  SessionSuccessView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-23.
//

import EventKit
import EventKitUI
import SwiftUI
import UserNotifications

struct SessionSuccessView: View {
    let sessionTitle: String
    let sessionDate: Date
    let startTime: String
    let endTime: String
    let sessionType: String
    let level: String
    let price: Double
    @Binding var isPresented: Bool

    @State var isEventAdded: Bool = false
    @State var isCalenderAdded: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    //img
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .frame(height: 150)

                            if let logoImage = UIImage(
                                named: "instrutorsuc.jpg")
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
                        Text("Success!")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)

                        Text(
                            "Your yoga session has been successfully created and is now available for students to book"
                        )
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 32)

                    }

                    //session details
                    VStack(spacing: 12) {
                        sessionDetailRow(title: "Session", value: sessionTitle)
                        sessionDetailRow(
                            title: "Date", value: Utils.formatDate(sessionDate))
                        sessionDetailRow(
                            title: "Time", value: "\(startTime) - \(endTime)")
                        sessionDetailRow(title: "Type", value: sessionType)
                        sessionDetailRow(
                            title: "Price",
                            value: "$\(String(format: "%.2f", price))")
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    //back to home btn
                    VStack {
                        HStack {
                            NavigationLink(
                                destination: InstructorDashboardView()
                            ) {
                                HStack {
                                    Image(systemName: "arrow.left")
                                        .font(.title2)
                                    Text("Back to Dashboard")
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
                        Button("Add to My Calendar") {
                            addToCalendar()
                        }
                        .primaryButtonStyle(enabled: !isCalenderAdded)
                        .frame(maxWidth: 350)
                        .disabled(isEventAdded)

                        Button("Set Reminder") {
                            addToReminders()
                        }
                        .secondaryButtonStyle(enabled: !isEventAdded)
                        .frame(maxWidth: 350)
                        .disabled(isEventAdded)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                }
                .background(Color.white)
                .ignoresSafeArea(.all, edges: .bottom)
            }
        }
    }

    private func sessionDetailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
    }

    private func addToCalendar() {
        let eventStore = EKEventStore()

        //request access to calendar
        eventStore.requestWriteOnlyAccessToEvents { granted, error in
            guard granted else {
                print("Calendar access denied")
                return
            }

            let event = EKEvent(eventStore: eventStore)
            event.title = "Teach: \(sessionTitle)"

            //convert date and time
            let sessionStartDateTime = Utils.combineDateAndTime(
                date: sessionDate, timeString: startTime)
            let sessionEndDateTime = Utils.combineDateAndTime(
                date: sessionDate, timeString: endTime)

            event.startDate = sessionStartDateTime
            event.endDate = sessionEndDateTime
            event.notes = "Yoga session - \(sessionType) | Level: \(level)"
            event.calendar = eventStore.defaultCalendarForNewEvents

            do {
                try eventStore.save(event, span: .thisEvent)
                print("Session event saved to calendar")
                isCalenderAdded = true

                //local notification
                let content = UNMutableNotificationContent()
                content.title = "Added to Calendar"
                content.body = "Your teaching session was successfully saved!"
                content.sound = .default

                //delay to ensure it triggers
                let trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(
                    identifier: UUID().uuidString,
                    content: content,
                    trigger: trigger)

                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Failed to show notification: \(error)")
                    } else {
                        print("Notification scheduled")
                    }
                }

            } catch {
                print("Failed to save event: \(error)")
            }
        }
    }

    private func addToReminders() {
        let eventStore = EKEventStore()

        eventStore.requestFullAccessToReminders { granted, error in
            guard granted else {
                print("Reminders access denied")
                return
            }

            let reminder = EKReminder(eventStore: eventStore)
            reminder.title = "Teaching Session: \(sessionTitle)"
            reminder.notes =
                "Prepare for yoga session - \(sessionType) | Level: \(level)"

            let sessionDateTime = Utils.combineDateAndTime(
                date: sessionDate, timeString: startTime)
            let calendar = Calendar.current

            var dateComponents = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute, .timeZone],
                from: sessionDateTime
            )

            if dateComponents.timeZone == nil {
                dateComponents.timeZone = TimeZone.current
            }

            reminder.dueDateComponents = dateComponents
            reminder.priority = 5
            reminder.calendar = eventStore.defaultCalendarForNewReminders()

            //set reminder 30mins before session
            let alarm = EKAlarm(relativeOffset: -30 * 60)  // 30mins before
            reminder.addAlarm(alarm)

            do {
                try eventStore.save(reminder, commit: true)
                print("reminder saved")
                isEventAdded = true
            } catch {
                print("failed to save reminder: \(error)")
            }
        }
    }
}

struct SessionSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        SessionSuccessView(
            sessionTitle: "Morning Vinyasa Flow",
            sessionDate: Date(),
            startTime: "09:00",
            endTime: "10:00",
            sessionType: "Online",
            level: "Intermediate",
            price: 45.00,
            isPresented: .constant(true)
        )
    }
}
