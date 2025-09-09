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
    @State private var searchText = ""
    @State private var isSearchVisible = false
    @State private var isMapVisible = false

    private let filterOptions = ["All", "Yoga", "Pilates", "Meditations"]

    //computed
    var filteredInstructors: [Instructor] {
        var filtered = instructors

        //first filter by selected tab
        if selectedFilter != "All" {
            filtered = filtered.filter { instructor in
                instructor.specialities.contains { speciality in
                    speciality.lowercased() == selectedFilter.lowercased()
                }
            }
        }

        //filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { instructor in
                instructor.fullName.localizedCaseInsensitiveContains(searchText)
                    || instructor.studioName.localizedCaseInsensitiveContains(
                        searchText)
                    || instructor.specialities.contains { speciality in
                        speciality.localizedCaseInsensitiveContains(searchText)
                    }
            }
        }

        return filtered
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Spacer()

                            Text(
                                isMapVisible
                                    ? "Studios Map" : "Find Instructors"
                            )
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                            Spacer()

                            //search + map icons
                            //search + map icons
                            HStack(spacing: 16) {
                                if !isMapVisible {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.3))
                                        {
                                            isSearchVisible.toggle()
                                            if !isSearchVisible {
                                                searchText = ""  //clear search when hiding
                                            }
                                        }
                                    }) {
                                        Image(
                                            systemName: isSearchVisible
                                                ? "xmark" : "magnifyingglass"
                                        )
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                    }
                                }

                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isMapVisible.toggle()
                                        //clear search when switching to map
                                        if isMapVisible {
                                            isSearchVisible = false
                                            searchText = ""
                                        }
                                    }
                                }) {
                                    Image(
                                        systemName: isMapVisible
                                            ? "list.bullet" : "map"
                                    )
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                }
                            }

                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, isSearchVisible ? 8 : 32)

                        //search -only when not in map view
                        if isSearchVisible && !isMapVisible {
                            HStack {
                                TextField(
                                    "Search instructors, studios, or specialties...",
                                    text: $searchText
                                )
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(size: 16))

                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                            .transition(
                                .opacity.combined(with: .move(edge: .top)))
                        }

                        //filter tabs (only show when not in map view)
                        if !isMapVisible {
                            ScrollView(.horizontal, showsIndicators: false) {  //no horizontal scrollbar
                                HStack(spacing: 32) {
                                    ForEach(filterOptions, id: \.self) {
                                        filter in
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
                        }

                        //content based on view mode
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
                        } else if isMapVisible {
                            //map view - show all instructors on map
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
                                        .padding(.top, 32)

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
                                Text(
                                    searchText.isEmpty
                                        ? "No Results Found" : "No Match Found"
                                )
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                if !searchText.isEmpty {
                                    Text("No instructors match '\(searchText)'")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
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

    var body: some View {
        NavigationLink(
            destination: InstructorDetailsView(instructor: instructor)
        ) {
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
                                    instructor.specialities.prefix(2),
                                    id: \.self
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

                //fees only
                HStack {
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
        .buttonStyle(PlainButtonStyle())
    }
}

//get initials from name
//don't change the original Instructor struct, extended it by adding a new computed property-initials
extension Instructor {
    var initials: String {
        let names = fullName.components(separatedBy: " ")
        let initials = names.compactMap { $0.first }.map { String($0) }
        //joins array elements without spaces
        return initials.joined()
    }
}

struct FindInstructorsView_Previews: PreviewProvider {
    static var previews: some View {
        FindInstructorsView()
    }
}
