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
        "All", "Yoga", "Pilates", "Meditation",
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
                        }
                    }
                }

                FooterNavigationView(selectedTab: 2, userRole: .student)

            }
            .background(Color(UIColor.systemBackground))
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
    @State private var showVideoPlayer = false

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

                //lesson info
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    //level
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(
                                Color(red: 0.4, green: 0.3, blue: 0.8)
                            ).font(.caption)

                        Text(lesson.level)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                }

                Spacer()

                //duration & fav btn
                VStack(alignment: .trailing, spacing: 8) {
                    Text("\(lesson.duration) min")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)

                    Button(action: {
                        favoritesManager.toggleFavorite(lesson)
                    }) {
                        Image(
                            systemName: favoritesManager.isFavorite(lesson)
                                ? "heart.fill" : "heart"
                        )
                        .font(.system(size: 20))
                        .foregroundColor(
                            favoritesManager.isFavorite(lesson)
                                ? Color(red: 0.4, green: 0.3, blue: 0.8)
                                : .secondary
                        )
                    }
                }
            }

            //level
            //            HStack {
            //                Spacer()
            //                HStack(spacing: 6) {
            //                    Image(systemName: "star.fill")
            //                        .font(.system(size: 14))
            //                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
            //
            //                    Text(lesson.level)
            //                        .font(.system(size: 14, weight: .medium))
            //                        .foregroundColor(.primary)
            //                }
            //            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onTapGesture {
            showVideoPlayer = true
        }
        .sheet(isPresented: $showVideoPlayer) {
            VideoPlayerView(lesson: lesson)
        }
    }
}

struct LessonsView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsView()
    }
}
