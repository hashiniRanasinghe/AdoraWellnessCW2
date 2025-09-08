//
//  PaymentSuccessView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-16.
//

import EventKit
import EventKitUI
import SwiftUI
import UserNotifications

struct PaymentSuccessView: View {
    //params
    let session: Session
    let instructor: Instructor
    @Binding var isPresented: Bool
    //variables
    @State var isEventAdded: Bool = false
    @State var isCalenderAdded: Bool = false

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
                                //makes the image flexible for stretch/shrink it to fit frames
                                .resizable()
                                //fills the frame completely, but may crop some parts of the image
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 350, height: 350)
                                //trims any overflow outside that square frame
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
                    Button("Add to Calendar") {
                        addToCalendar()
                    }
                    .disabled(isEventAdded)
                    .primaryButtonStyle(enabled: !isCalenderAdded)
                    .frame(maxWidth: 350)

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

    private func addToCalendar() {
        let eventStore = EKEventStore()  //gate to the user’s Calendars app

        //request access
        eventStore.requestWriteOnlyAccessToEvents {
            granted,
            error in
            guard granted else { return }

            let event = EKEvent(eventStore: eventStore)  //representing a single calendar event
            event.title = session.title
            event.startDate = session.date
            event.endDate = Calendar.current.date(
                byAdding: .minute, value: session.durationMinutes,
                to: session.date)
            event.notes =
                "Yoga session with \(instructor.firstName) \(instructor.lastName)"
            //user’s default calendar amoung Work, Home, iCloud
            event.calendar = eventStore.defaultCalendarForNewEvents

            do {
                try eventStore.save(event, span: .thisEvent)
                print("Event saved - calendar date: \(session.date)")

                //local notification
                let content = UNMutableNotificationContent()
                content.title = "Added to Calendar"
                content.body = "Your yoga session was successfully saved!"
                content.sound = .default
                isCalenderAdded = true

                // trigger after 5s
                let trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(
                    identifier: UUID().uuidString,  //uniqueness of this notifi
                    content: content,
                    trigger: trigger)

                UNUserNotificationCenter.current().add(request)  //sending it to the system to show at the right time
                { error in
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

        // request access
        eventStore.requestFullAccessToReminders { granted, error in
            //checks if permission was actually given
            guard granted else {
                print("Reminders access denied")
                return
            }

            let reminder = EKReminder(eventStore: eventStore)  //single reminder object
            reminder.title = "Yoga Session: \(session.title)"
            reminder.notes =
                "Yoga session with \(instructor.firstName) \(instructor.lastName)"

            //user current calender to compute dateComponents
            let calendar = Calendar.current

            //converts session.date into year, month, day, hour, minute with timezone
            var dateComponents = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute, .timeZone],
                from: session.date
            )

            if dateComponents.timeZone == nil {
                dateComponents.timeZone = TimeZone.current
            }

            reminder.dueDateComponents = dateComponents

            //set priority  5 = medium
            reminder.priority = 5

            //use default reminders list
            reminder.calendar = eventStore.defaultCalendarForNewReminders()

            //alarm 15 mins before
            let alarm = EKAlarm(relativeOffset: -15 * 60)  // 15 mins
            reminder.addAlarm(alarm)

            do {
                try eventStore.save(reminder, commit: true)
                print("Reminder saved for: \(session.date)")
                isEventAdded = true

            } catch {
                print("Failed to save reminder: \(error)")
            }
        }
    }

}
