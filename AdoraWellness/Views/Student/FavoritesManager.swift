//
//  FavoritesManager.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-17.
//

import Combine
import SwiftUI

class FavoritesManager: ObservableObject {
    @Published var favoriteIds: Set<String> = []
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadFavorites()

        //listen for favorites changes
        NotificationCenter.default.publisher(for: .favoritesDidChange)
            .sink { [weak self] _ in
                self?.loadFavorites()
            }
            .store(in: &cancellables)
    }

    private func loadFavorites() {
        let favoriteIds = coreDataManager.fetchAllFavoriteIds()
        self.favoriteIds = Set(favoriteIds)
    }

    func toggleFavorite(_ lesson: Lesson) {
        if isFavorite(lesson) {
            coreDataManager.removeFromFavorites(lessonId: lesson.id ?? "")
        } else {
            coreDataManager.addToFavorites(lessonId: lesson.id ?? "")
        }
    }

    func isFavorite(_ lesson: Lesson) -> Bool {
        return favoriteIds.contains(lesson.id ?? "")
    }

    func getFavoriteIds() -> [String] {
        return coreDataManager.fetchAllFavoriteIds()
    }

    //filter fav lessons from main lessons array
    func getFavorites(from allLessons: [Lesson]) -> [Lesson] {
        let favoriteIds = getFavoriteIds()
        let favoriteLessons = allLessons.filter {
            favoriteIds.contains($0.id ?? "")
        }

        // most recent first sorting
        return favoriteLessons.sorted { lesson1, lesson2 in
            guard let index1 = favoriteIds.firstIndex(of: lesson1.id ?? ""),
                let index2 = favoriteIds.firstIndex(of: lesson2.id ?? "")
            else {
                return false
            }
            return index1 < index2
        }
    }
}
