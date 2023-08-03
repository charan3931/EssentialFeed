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
        store.deleteCache() { [weak self] error in
            guard let self else { return }
            if let error {
                completion(error)
            } else {
                cache(items, timestamp: timestamp, completion: completion)
            }
        }
    }

    private func cache(_ items: [FeedItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
        self.store.insert(items, timestamp: timestamp, completion: { [weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }
}
