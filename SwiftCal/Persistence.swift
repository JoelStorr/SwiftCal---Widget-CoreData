//
//  Persistence.swift
//  SwiftCal
//
//  Created by Joel Storr on 20.10.23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let databaseName = "SwiftCal.sqlite"

    // Has the old url for unshared App storage
    var oldStoreURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent(databaseName)
    }

    // Creates the URL to the new shared Memory Space
    var sharedStoreURL: URL {
        let container = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.joelstorr.SwiftCal"
        )!
        return container.appendingPathComponent(databaseName)
    }

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let startDate = Calendar.current.dateInterval(of: .month, for: .now)!.start

        for dayOffset in 0..<30 {
            let newDay = Day(context: viewContext)
            newDay.date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)
            newDay.didStudy = Bool.random()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SwiftCal")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")

            // Only want to run this if there is no old file store
        } else if !FileManager.default.fileExists(atPath: oldStoreURL.path) {
            // Accesses the Store URL when we actually run the App
            print("👴 Old store does not exist. Using new shared URL")
            container.persistentStoreDescriptions.first!.url = sharedStoreURL
        }
        print("🕸️ container URL = \(container.persistentStoreDescriptions.first!.url!)")

        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        // Call the migrate function
        migrateStore(for: container)
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func migrateStore(for container: NSPersistentContainer) {
        print("➡️ Went into migrate store function")
        let coordinator = container.persistentStoreCoordinator

        // Check if a persistence Store exists
        guard let oldStore = coordinator.persistentStore(for: oldStoreURL) else { return }
        print("🛡️ old store no longer exist")

        do {
            // Migrate old store to the new shared Store
            _ = try coordinator.migratePersistentStore(oldStore, to: sharedStoreURL, type: .sqlite)
            print("🏁 Mirgateion successfullt")
        } catch {
            fatalError("⭕️ Unable to migrate to shared store")
        }

        // Delete the old store
        do {
            try FileManager.default.removeItem(at: oldStoreURL)
            print("🗑️ Old store deleted")
        } catch {
            print("⭕️ Unable to delete old store")
        }
    }
}
