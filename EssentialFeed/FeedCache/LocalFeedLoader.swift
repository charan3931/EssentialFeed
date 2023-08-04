//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Sai Charan on 03/08/23.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date

    public init(currentDate: @escaping () -> Date, store: FeedStore) {
        self.currentDate = currentDate
        self.store = store
    }

}

extension LocalFeedLoader {
    public func save(items: [FeedImage], completion: @escaping (Error?) -> Void) {
        store.deleteCache() { [weak self] error in
            guard let self else { return }
            if let error {
                completion(error)
            } else {
                cache(items, timestamp: currentDate(), completion: completion)
            }
        }
    }

    private func cache(_ items: [FeedImage], timestamp: Date, completion: @escaping (Error?) -> Void) {
        self.store.insert(items.toLocal(), timestamp: timestamp, completion: { [weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }
}
extension LocalFeedLoader {

    public func validateCache(completion: @escaping (Error?) -> Void) {
        store.retrieve() { [weak self] result in
            guard let self else { return }
            switch result {
            case .success((_, let timestamp)):
                if !isValid(timestamp) {
                    self.store.deleteCache(completion: { [weak self] error in
                        guard self != nil else { return }
                        completion(error)
                    })
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
}

extension LocalFeedLoader {
    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        store.retrieve(completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success((let feedImages, let timestamp)):
                completion(get(feedImages: feedImages, timestamp: timestamp))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }

    private func get(feedImages: [LocalFeedImage], timestamp: Date) -> LoadFeedResult {
        let feedImages = self.isValid(timestamp) ? feedImages.toModel() : []
        return .success(feedImages)
    }

    private func isValid(_ timestamp: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxAgeDays, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
    }

    private var maxAgeDays: Int { 7 }
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

