//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Sai Charan on 06/08/23.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
    private let coreDataStack: CoreDataStack
    private var context: NSManagedObjectContext {
        coreDataStack.managedContext
    }

    public init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    public func deleteCache(completion: @escaping DeletionCompletion) {
        do {
            try delete()
        } catch {
            completion(error)
        }
        completion(nil)
    }

    private func delete() throws {
        let fetchedObjects = try context.fetch(FeedDataModel.fetchRequest())
        fetchedObjects.forEach { context.delete($0) }
        try context.save()
    }

    public func save(_ items: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping SaveCompletion) {
        do {
            FeedDataModel.save(feedImages: items, timeStamp: timestamp, in: context)
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        do {
            let asyncFetchRequest = asyncFetchRequest(completion: completion)
            try context.execute(asyncFetchRequest)
        } catch {
            completion(.failure(error))
        }
    }

    private func asyncFetchRequest(completion: @escaping RetrievalCompletion) -> NSAsynchronousFetchRequest<FeedDataModel> {
        let fetchRequest = FeedDataModel.fetchRequest()

        return NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { result in
            let localFeed = result.finalResult?.first?.toLocalFeed
            completion(.success(localFeed))
        }
    }
}

