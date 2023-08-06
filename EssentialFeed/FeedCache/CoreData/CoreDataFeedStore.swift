//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Sai Charan on 06/08/23.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {

    private let coreDataStack: CoreDataStack

    public init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    public func deleteCache(completion: @escaping DeletionCompletion) {
        completion(nil)
    }

    public func save(_ items: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping SaveCompletion) {
        _ = FeedDataModel.toFeedDataModel(feedImages: items, timeStamp: timestamp, context: coreDataStack.managedContext)
        coreDataStack.saveContext()
        completion(nil)
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        do {
            let asyncFetchRequest = asyncFetchRequest(completion: completion)
            try coreDataStack.managedContext.execute(asyncFetchRequest)
        } catch {
            completion(.failure(error))
        }
    }

    private func asyncFetchRequest(completion: @escaping RetrievalCompletion) -> NSAsynchronousFetchRequest<FeedDataModel> {
        let fetchRequest = FeedDataModel.fetchRequest()

        return NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { result in
            guard let feedDataModel = result.finalResult else {
                return completion(.success(nil))
            }
            completion(.success(feedDataModel.first?.toLocalFeed))
        }
    }
}

