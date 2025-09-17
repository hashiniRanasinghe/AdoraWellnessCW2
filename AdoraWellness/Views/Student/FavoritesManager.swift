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

    //the handler to keep a subscription alive
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadFavorites()

        //watcher for favorites changes -sets up a listener (subscription) to NotificationCenter
        NotificationCenter.default.publisher(for: .favoritesDidChange)
            .sink { [weak self] _ in
                self?.loadFavorites()
            }
            .store(in: &cancellables)
    }

    private func loadFavorites() {
        let favoriteIds = coreDataManager.fetchAllFavoriteIds()

        //'Set' wrapping to prevents duplicates n updates the favoriteIds property
        self.favoriteIds = Set(favoriteIds)
    }

    func toggleFavorite(_ lesson: Lesson) {
        //checks if the lesson is already a fav
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
        //fetch all favorite lesson ids
        let favoriteIds = getFavoriteIds()

        //loops through allLessons  to check lesson’s ID is in the list of favorite IDs
        let favoriteLessons = allLessons.filter {
            favoriteIds.contains($0.id ?? "")
        }

        // most recent first sorting
        return favoriteLessons.sorted { lesson1, lesson2 in
            //ensures favorites appear in the same order as stored
            guard let index1 = favoriteIds.firstIndex(of: lesson1.id ?? ""),
                let index2 = favoriteIds.firstIndex(of: lesson2.id ?? "")
            else {
                return false
            }
            return index1 < index2
        }
    }
}
