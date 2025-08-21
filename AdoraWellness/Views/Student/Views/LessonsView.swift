//
//  LessonsView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-17.
//

import SwiftUI

struct LessonsView: View {
    @StateObject private var viewModel = LessonsViewModel()
    @StateObject private var favoritesManager = FavoritesManager()
    @State private var lessons: [Lesson] = []
    @State private var selectedFilter = "All"

    private let filterOptions = [
        "All", "Yoga", "Pilates", "Meditation", "Beginner",
    ]

    var filteredLessons: [Lesson] {
        if selectedFilter == "All" {
            return lessons
        } else {
            return lessons.filter { lesson in
                lesson.category.lowercased() == selectedFilter.lowercased()
                    || lesson.level.lowercased() == selectedFilter.lowercased()
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Spacer()

                            Text("Lessons")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Spacer()

                            // nav to fav list
                            NavigationLink(destination: FavoritesView()) {
                                Image(systemName: "heart.fill")
                                    .font(.title2)
                                    .foregroundColor(
                                        Color(red: 0.4, green: 0.3, blue: 0.8))
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

                        //lessons
                        if viewModel.isLoading {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("Loading lessons...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        } else if filteredLessons.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "play.slash")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)
                                Text("No Lessons Found")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(filteredLessons) { lesson in
                                    LessonCard(lesson: lesson)
                                        .environmentObject(favoritesManager)
                                        .padding(.horizontal, 24)
                                }
                            }
                            .padding(.bottom, 100)
                        }
                    }
                }

                FooterNavigationView(selectedTab: 2, userRole: .student)

            }
            .background(Color.white)
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .navigationBarHidden(true)
        .task {
            await loadLessons()
        }
    }

    private func loadLessons() async {
        lessons = await viewModel.fetchAllLessons()
    }
}

struct LessonCard: View {
    let lesson: Lesson
    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 16) {
                //icon
                Image(systemName: lesson.iconName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                    .frame(width: 60, height: 60)
                    .background(
                        Color(red: 0.4, green: 0.3, blue: 0.8).opacity(0.1)
                    )
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(lesson.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text("\(lesson.duration) min")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)

                }
            }

            //action btns
            HStack(spacing: 12) {
                Button(action: {
                    //                    print("Starting lesson: \(lesson.title) on own")
                }) {
                    Text("Start on Own")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color(red: 0.4, green: 0.3, blue: 0.8))
                        .cornerRadius(20)
                }

                Button(action: {
                    print("Starting lesson: \(lesson.title) with guidance")
                }) {
                    Text("Start with Guidance")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            Color(red: 0.4, green: 0.3, blue: 0.8).opacity(0.1)
                        )
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    Color(red: 0.4, green: 0.3, blue: 0.8),
                                    lineWidth: 1)
                        )
                }

                Spacer()
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
struct LessonsView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsView()
    }
}
