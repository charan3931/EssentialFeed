//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Sai Charan on 03/08/23.
//

import Foundation

public class LocalFeedLoader {

    private let store: FeedStore

    public init(store: FeedStore) {
        self.store = store
    }

    public func save(items: [FeedItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
        store.deleteCache() { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: timestamp, completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCache(completion: @escaping DeletionCompletion)
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
