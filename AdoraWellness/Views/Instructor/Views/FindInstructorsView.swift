//
//  FindInstructorsView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-13.
//

import SwiftUI

struct FindInstructorsView: View {
    @StateObject private var viewModel = InstructorViewModel()
    @State private var instructors: [Instructor] = []
    @State private var selectedFilter = "All"

    private let filterOptions = ["All", "Yoga", "Pilates", "Meditation"]

    var filteredInstructors: [Instructor] {
        if selectedFilter == "All" {
            return instructors
        } else {
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
                            Button(action: {
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }

                            Spacer()

                            Text("Find Instructors")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Spacer()

                            Button(action: {
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 32)

                        //filter tabs
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 32) {
                                ForEach(filterOptions, id: \.self) { filter in
                                    Button(action: {
                                        selectedFilter = filter
                                    }) {
                                        VStack(spacing: 8) {
                                            Text(filter)
                                                .font(.headline)
                                                .fontWeight(.medium)
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

                        //instructors list
                        //instructors list
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

                FooterNavigationView(selectedTab: 1)
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
        VStack(alignment: .leading, spacing: 20) {

            HStack(spacing: 16) {
                //profile pic with initials
                Text(instructor.initials)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color(.systemGray3))
                    .clipShape(Circle())

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
                                //instructor.specialities, id: \.self
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
                Button(action: {
                }) {
                    Text("Book Now")
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
        // .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

//get initials from name
extension Instructor {
    var initials: String {
        let names = fullName.components(separatedBy: " ")
        let initials = names.compactMap { $0.first }.map { String($0) }
        return initials.joined()
    }
}

struct FindInstructorsView_Previews: PreviewProvider {
    static var previews: some View {
        FindInstructorsView()
    }
}
