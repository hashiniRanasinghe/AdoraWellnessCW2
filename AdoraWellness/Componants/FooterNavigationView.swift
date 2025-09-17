import SwiftUI

struct FooterNavigationView: View {
    let selectedTab: Int
    let userRole: UserType

    @State private var navigateToProfile = false
    @State private var navigateToDiscover = false
    @State private var navigateToPractice = false
    @State private var navigateToHome = false
    @State private var navigateToSchedule = false

    //0 as the default
    init(selectedTab: Int = 0, userRole: UserType) {
        self.selectedTab = selectedTab
        self.userRole = userRole
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    //home - common for both roles
                    footerButton(
                        systemName: selectedTab == 0 ? "house.fill" : "house",
                        title: "Home",
                        isSelected: selectedTab == 0
                    ) { if selectedTab != 0 { navigateToHome = true } }

                    //student
                    if userRole == .student {
                        footerButton(
                            systemName: selectedTab == 1
                                ? "doc.text.fill" : "doc.text",
                            title: "Discover",
                            isSelected: selectedTab == 1
                        ) { if selectedTab != 1 { navigateToDiscover = true } }

                        footerButton(
                            systemName: "figure.yoga",
                            title: "Practice",
                            isSelected: selectedTab == 2
                        ) { if selectedTab != 2 { navigateToPractice = true } }

                        footerButton(
                            systemName: selectedTab == 3
                                ? "person.fill" : "person",
                            title: "Profile",
                            isSelected: selectedTab == 3
                        ) { if selectedTab != 3 { navigateToProfile = true } }

                    }
                    //instructor
                    else if userRole == .instructor {
                        footerButton(
                            systemName: selectedTab == 1
                                ? "calendar.badge.clock" : "calendar",
                            title: "Schedule",
                            isSelected: selectedTab == 1
                        ) { if selectedTab != 1 { navigateToSchedule = true } }

                        footerButton(
                            systemName: selectedTab == 2
                                ? "person.fill" : "person",
                            title: "Profile",
                            isSelected: selectedTab == 2
                        ) { if selectedTab != 2 { navigateToProfile = true } }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
                .padding(.top, 15)
            }
            .background(Color(UIColor.systemBackground))  
            //nav
            .navigationDestination(isPresented: $navigateToHome) {
                if userRole == .student {
                    DashboardView()
                } else {
                    InstructorDashboardView()
                }
            }
            .navigationDestination(isPresented: $navigateToDiscover) {
                FindInstructorsView()
            }
            .navigationDestination(isPresented: $navigateToPractice) {
                LessonsView()
            }
            .navigationDestination(isPresented: $navigateToProfile) {
                UserProfileView()
            }
            .navigationDestination(isPresented: $navigateToSchedule) {
                InstructorScheduleView()
            }
        }
    }

    @ViewBuilder
    private func footerButton(
        systemName: String,
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 4) {
            Image(systemName: systemName)
                .font(.title2)
                .foregroundColor(
                    isSelected ? Color(red: 0.4, green: 0.3, blue: 0.8) : .gray)
            Text(title)
                .font(.caption)
                .foregroundColor(
                    isSelected ? Color(red: 0.4, green: 0.3, blue: 0.8) : .gray)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture { action() }  // run action when tapped
    }
}
