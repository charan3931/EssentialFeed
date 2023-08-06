//
//  InMemoryCoreDataStack.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 06/08/23.
//

import Foundation
import CoreData
import EssentialFeed

class InMemoryCoreDataStack: CoreDataStack {

    private let modelName: String
    private let bundle: Bundle

    required init(modelName: String, bundle: Bundle) {
        self.modelName = modelName
        self.bundle = bundle
    }

    lazy var persistentContainer: NSPersistentContainer = {


        guard let model = bundle.url(forResource: modelName, withExtension: "momd").flatMap( { NSManagedObjectModel(contentsOf: $0) }) else {
                fatalError("Error initializing mom from: \(bundle)")
        }


        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType

        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory CoreData store: \(error)")
            }
        }

        return container
    }()

    var managedContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
