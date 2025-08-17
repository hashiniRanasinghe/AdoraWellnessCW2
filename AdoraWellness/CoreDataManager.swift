//
//  CoreDataManager.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-17.
//

import CoreData
import Foundation

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error.localizedDescription)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func save() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }

    func addToFavorites(lessonId: String) {
        print(" CoreData - attempting to add favorite: \(lessonId)")
        // check if already exists
        if isFavorite(lessonId: lessonId) {
            return
        }

        let favoriteLesson = FavoriteLesson(context: context)
        favoriteLesson.lessonId = lessonId
        favoriteLesson.dateAdded = Date()

        save()

        //notification for UI updates
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }

    func removeFromFavorites(lessonId: String) {
        let request: NSFetchRequest<FavoriteLesson> =
            FavoriteLesson.fetchRequest()
        request.predicate = NSPredicate(format: "lessonId == %@", lessonId)

        do {
            let favorites = try context.fetch(request)
            for favorite in favorites {
                context.delete(favorite)
            }
            save()

            // notification for UI updates
            NotificationCenter.default.post(
                name: .favoritesDidChange, object: nil)
        } catch {
            print("Failed to remove from \(error.localizedDescription)")
        }
    }

    func isFavorite(lessonId: String) -> Bool {
        let request: NSFetchRequest<FavoriteLesson> =
            FavoriteLesson.fetchRequest()
        request.predicate = NSPredicate(format: "lessonId == %@", lessonId)
        request.fetchLimit = 1

        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("Failed to check status: \(error.localizedDescription)")
            return false
        }
    }

    func fetchAllFavoriteIds() -> [String] {
        let request: NSFetchRequest<FavoriteLesson> =
            FavoriteLesson.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \FavoriteLesson.dateAdded, ascending: false)
        ]

        do {
            let favorites = try context.fetch(request)
            return favorites.map { $0.lessonId ?? "" }
        } catch {
            print("Failed to fetch: \(error.localizedDescription)")
            return []
        }
    }
}

extension Notification.Name {
    static let favoritesDidChange = Notification.Name("favoritesDidChange")
}
