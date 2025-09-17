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

    lazy var persistentContainer: NSPersistentContainer = {  //main object that manages Core Data stack
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { _, error in  //ignore(_) the store description,only use error
            if let error = error {
                fatalError("Core Data error: \(error.localizedDescription)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {  //read, write, and delete objects in core data
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
        //make a new FavoriteLesson object inside core data context
        let favoriteLesson = FavoriteLesson(context: context)
        favoriteLesson.lessonId = lessonId
        favoriteLesson.dateAdded = Date()

        save()

        //notification for UI updates - the system’s “messenger” for sending events across the app
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }

    func removeFromFavorites(lessonId: String) {
        //creates a request to fetch FavoriteLesson objects
        let request: NSFetchRequest<FavoriteLesson> =
            FavoriteLesson.fetchRequest()

        //condition (SELECT * FROM FavoriteLesson WHERE lessonId = '123')
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
        //only need to check existence -stops searching after finding 1 match
        request.fetchLimit = 1

        do {
            //count of the objects match this request
            let count = try context.count(for: request)
            // if count > 0 - lesson exists in favorites -> true
            return count > 0
        } catch {
            print("Failed to check status: \(error.localizedDescription)")
            return false
        }
    }

    func fetchAllFavoriteIds() -> [String] {
        //creates Core Data request for the FavoriteLesson entity
        let request: NSFetchRequest<FavoriteLesson> =
            FavoriteLesson.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \FavoriteLesson.dateAdded, ascending: false)
            //fetch all FavoriteLesson objects sorted by dateAdded -most recent first
        ]

        do {
            //run the query n get lessonId string from each object if it’s nil, replace it with an empty string
            let favorites = try context.fetch(request)
            return favorites.map { $0.lessonId ?? "" }
        } catch {
            print("Failed to fetch: \(error.localizedDescription)")
            return []
        }
    }
}

//adds a custom notification name instead of using raw string
extension Notification.Name {
    static let favoritesDidChange = Notification.Name("favoritesDidChange")
}
