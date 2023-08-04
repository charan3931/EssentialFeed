//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Sai Charan on 04/08/23.
//

import Foundation

class CodableFeedStore {
    fileprivate struct CacheFeed: Codable {
        let items: [CacheFeedImage]
        let timestamp: Date

        var localFeedImages: [LocalFeedImage] {
            items.map { $0.localFeedImage }
        }
    }

    fileprivate struct CacheFeedImage: Equatable, Codable {
        let id: UUID
        let description: String?
        let location: String?
        let imageURL: URL

        init(from localFeedImage: LocalFeedImage) {
            id = localFeedImage.id
            description = localFeedImage.description
            location = localFeedImage.location
            imageURL = localFeedImage.imageURL
        }

        var localFeedImage: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, imageURL: imageURL)
        }
    }
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "image-feed.store")

    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        if let data = try? Data(contentsOf: storeURL), let localCacheFeed = try? JSONDecoder().decode(CacheFeed.self, from: data) {
            completion(.success(LocalCacheFeed(items: localCacheFeed.localFeedImages, timestamp: localCacheFeed.timestamp)))
        } else {
            completion(.success(nil))
        }
    }

    func save(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.SaveCompletion) {
        let cacheFeed = CacheFeed(items: items.map { CacheFeedImage(from: $0) }, timestamp: timestamp)
        guard let encoded = try? JSONEncoder().encode(cacheFeed), (try? encoded.write(to: storeURL)) != nil else {
            completion(nil)
            return
        }
        completion(nil)
    }
}
