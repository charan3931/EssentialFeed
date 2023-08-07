//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Sai Charan on 03/08/23.
//

import Foundation

public final class LocalFeedLoader: FeedLoader {
    private let store: FeedStore
    let currentDate: () -> Date

    public init(currentDate: @escaping () -> Date, store: FeedStore) {
        self.currentDate = currentDate
        self.store = store
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Result<Void, Error>

    public func save(items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCache() { [weak self] deletionResult in
            guard let self else { return }

            switch deletionResult {
            case .success:
                cache(items, timestamp: currentDate(), completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func cache(_ items: [FeedImage], timestamp: Date, completion: @escaping (SaveResult) -> Void) {
        self.store.save(items.toLocal(), timestamp: timestamp, completion: { [weak self] saveResult in
            guard self != nil else { return }
            completion(saveResult)
        })
    }
}
extension LocalFeedLoader {

    public func validateCache() {
        store.retrieve() { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(.some(localCacheFeed)) where !CachePolicy.isValid(currentDate: currentDate, timestamp: localCacheFeed.timestamp):
                self.store.deleteCache { _ in }
            case .failure:
                self.store.deleteCache { _ in }
            case .success:
                break
            }
        }
    }
}

extension LocalFeedLoader {
    public typealias LoadResult = FeedLoader.Result

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve(completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(localCacheFeed):
                completion(getFeedImages(from: localCacheFeed))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }

    private func getFeedImages(from localCacheFeed: LocalFeed?) -> LoadResult {
        if let localCacheFeed, CachePolicy.isValid(currentDate: currentDate, timestamp: localCacheFeed.timestamp) {
            return .success(localCacheFeed.items.toModel())
        }
        return .success([])
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

