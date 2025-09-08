//
//  FindInstructorsView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-13.
//
//

import SwiftUI

struct FindInstructorsView: View {
    @StateObject private var viewModel = InstructorViewModel()
    @State private var instructors: [Instructor] = []
    @State private var selectedFilter = "All"

    private let filterOptions = ["All", "Yoga", "Pilates", "Map"]

    //computed
    var filteredInstructors: [Instructor] {
        if selectedFilter == "All" {
            return instructors
        } else if selectedFilter == "Map" {
            return instructors  //return all for map view
        } else {
            //filter by specialty - case-insensitive matching
            return instructors.filter { instructor in
                instructor.specialities.contains { speciality in
                    speciality.lowercased() == selectedFilter.lowercased()
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            //                            Button(action: {
                            //                            }) {
                            //                                Image(systemName: "arrow.left")
                            //                                    .font(.title2)
                            //                                    .foregroundColor(.primary)
                            //                            }

                            Spacer()

                            Text(
                                selectedFilter == "Map"
                                    ? "Studios Map" : "Find Instructors"
                            )
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                            Spacer()
                            //search
                            //                            Button(action: {
                            //                            }) {
                            //                                Image(systemName: "magnifyingglass")
                            //                                    .font(.title2)
                            //                                    .foregroundColor(.primary)
                            //                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 32)

                        //filter tabs
                        ScrollView(.horizontal, showsIndicators: false) {  //no orizontal scrollbar
                            HStack(spacing: 32) {
                                ForEach(filterOptions, id: \.self) { filter in
                                    Button(action: {
                                        selectedFilter = filter
                                    }) {
                                        VStack(spacing: 8) {
                                            HStack(spacing: 4) {
                                                Text(filter)
                                                    .font(.headline)
                                                    .fontWeight(.medium)
                                            }
                                            .foregroundColor(
                                                selectedFilter == filter
                                                    ? .primary : .secondary
                                            )

                                            Rectangle()
                                                .fill(
                                                    selectedFilter == filter
                                                        ? Color(
                                                            red: 0.4,
                                                            green: 0.3,
                                                            blue: 0.8)
                                                        : Color.clear
                                                )
                                                .frame(height: 2)
                                                .frame(
                                                    width: filter.count > 6
                                                        ? 80 : 60)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 32)

                        //content based on selected filter
                        if viewModel.isLoading {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("Loading instructors...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        } else if selectedFilter == "Map" {
                            //map view
                            VStack {
                                if instructors.isEmpty {
                                    VStack(spacing: 16) {
                                        Text("No Studios Available")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        Text(
                                            "No instructor studios found to display on the map"
                                        )
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 100)
                                } else {
                                    StudiosMapView(instructors: instructors)
                                        .frame(height: 500)
                                        .cornerRadius(12)
                                        .padding(.horizontal, 24)

                                    //studios summary
                                    let studiosCount = Set(
                                        instructors.compactMap { instructor in
                                            instructor.latitude != nil
                                                && instructor.longitude != nil
                                                && !instructor.studioName
                                                    .isEmpty
                                                ? instructor.studioName : nil
                                        }
                                    ).count

                                    VStack(spacing: 8) {
                                        Text(
                                            "\(studiosCount) \(studiosCount == 1 ? "Studio" : "Studios") Found"
                                        )
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)

                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.top, 16)
                                    .padding(.bottom, 50)
                                }
                            }
                        } else if filteredInstructors.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "person.slash")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)
                                Text("No Results Found")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(filteredInstructors) { instructor in
                                    InstructorListCard(instructor: instructor)
                                        .padding(.horizontal, 24)
                                }
                            }
                            .padding(.bottom, 100)
                        }
                    }
                }

                FooterNavigationView(selectedTab: 1, userRole: .student)

            }
            .background(Color.white)
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .navigationBarHidden(true)
        .task {
            await loadInstructors()
        }
    }

    private func loadInstructors() async {
        instructors = await viewModel.fetchAllInstructors()
    }
}

struct InstructorListCard: View {
    let instructor: Instructor
    @State private var navigateToDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 16) {
                //avatar pic with initials
                AvatarView(initials: instructor.initials, size: 60)

                VStack(alignment: .leading, spacing: 4) {
                    Text(instructor.fullName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)

                    Text("Certified Yoga Instructor")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    HStack(spacing: 16) {
                        Text(
                            "\(instructor.experience) \(instructor.experience == 1 ? "year" : "years")"
                        )
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                        //specialities
                        HStack(spacing: 8) {
                            ForEach(
                                instructor.specialities.prefix(2), id: \.self
                            ) { speciality in
                                HStack(spacing: 2) {
                                    Circle()
                                        .fill(Color.secondary)
                                        .frame(width: 4, height: 4)
                                    Text(speciality.capitalized)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }

                Spacer()
            }

            //book now and fees
            HStack {
                NavigationLink(
                    destination: InstructorDetailsView(instructor: instructor)
                ) {
                    Text("More Details..")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color(red: 0.4, green: 0.3, blue: 0.8))
                        .cornerRadius(20)
                }

                Spacer()

                Text(
                    "From $\(String(format: "%.0f", instructor.hourlyRate))/session"
                )
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

//get initials from name
//don't change the original Instructor struct, extended it by adding a new computed property-initials
extension Instructor {
    var initials: String {
        let names = fullName.components(separatedBy: " ")
        let initials = names.compactMap { $0.first }.map { String($0) }
        //joins array elements without spaces.
        return initials.joined()
    }
}

struct FindInstructorsView_Previews: PreviewProvider {
    static var previews: some View {
        FindInstructorsView()
    }
}
