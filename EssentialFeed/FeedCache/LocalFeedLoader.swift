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

    public func save(items: [FeedImage], timestamp: Date, completion: @escaping (Error?) -> Void) {
        store.deleteCache() { [weak self] error in
            guard let self else { return }
            if let error {
                completion(error)
            } else {
                cache(items, timestamp: timestamp, completion: completion)
            }
        }
    }

    private func cache(_ items: [FeedImage], timestamp: Date, completion: @escaping (Error?) -> Void) {
        self.store.insert(items.toLocal(), timestamp: timestamp, completion: { [weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }

    public func retrieve(completion: @escaping (LoadFeedResult) -> Void) {
        store.retrieve(completion: { result in
            switch result {

            case .success(let feedImages):
                completion(.success(feedImages.toModel()))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}


private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModel() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
}

