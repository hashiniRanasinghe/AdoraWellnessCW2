//
//  FavoritesView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-17.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var favoritesManager = FavoritesManager()
    @StateObject private var viewModel = LessonsViewModel()
    @State private var allLessons: [Lesson] = []
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss

    var favoriteLessons: [Lesson] {
        return favoritesManager.getFavorites(from: allLessons)
    }

    var body: some View {

        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                }

                Spacer()

                Text("Favourites")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()

                //                    Button(action: {
                //                        //search
                //                    }) {
                //                        Image(systemName: "magnifyingglass")
                //                            .font(.title2)
                //                            .foregroundColor(.primary)
                //                    }

                //                    Button(action: {
                //                    }) {
                //                        Image(systemName: "heart.fill")
                //                            .font(.title2)
                //                            .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.8))
                //                    }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 32)

            //content
            ScrollView {
                VStack(spacing: 16) {
                    if isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading favorites...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else if favoriteLessons.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "heart.slash")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("No Favourite Lessons")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text(
                                "Add lessons to favourites to see them here"
                            )
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else {
                        ForEach(favoriteLessons) { lesson in
                            FavoriteLessonCard(lesson: lesson)
                                .environmentObject(favoritesManager)
                                .padding(.horizontal, 24)
                        }
                    }
                }
                .padding(.bottom, 100)
            }

            Spacer()
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .task {
            await loadLessons()
        }
    }

    private func loadLessons() async {
        isLoading = true
        allLessons = await viewModel.fetchAllLessons()
        isLoading = false
    }
}

struct FavoriteLessonCard: View {
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

                    Button(action: {
                        favoritesManager.toggleFavorite(lesson)
                    }) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 20))
                            .foregroundColor(
                                Color(red: 0.4, green: 0.3, blue: 0.8))
                    }
                }
            }

            //action btns
            HStack(spacing: 12) {
                Button(action: {
                    print("Starting lesson: \(lesson.title) on own")
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

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
