//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Sai Charan on 04/08/23.
//

import Foundation

class CodableFeedStore: FeedStore {
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
    private let storeURL: URL
    private let dispatchQueue = DispatchQueue(label: "CodableFeedStoreQueue", qos: .userInitiated, attributes: .concurrent)

    init(storeURL: URL) {
        self.storeURL = storeURL
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        dispatchQueue.async { [storeURL] in
            guard let data = try? Data(contentsOf: storeURL) else {
                completion(.success(nil))
                return
            }

            do {
                let cacheFeed = try JSONDecoder().decode(CacheFeed.self, from: data)
                completion(.success(LocalFeed(items: cacheFeed.localFeedImages, timestamp: cacheFeed.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func save(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping SaveCompletion) {
        dispatchQueue.async(flags: .barrier) { [storeURL] in
            let cacheFeed = CacheFeed(items: items.map { CacheFeedImage(from: $0) }, timestamp: timestamp)
            do {
                let encoded = try JSONEncoder().encode(cacheFeed)
                try encoded.write(to: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func deleteCache(completion: @escaping DeletionCompletion) {
        dispatchQueue.async(flags: .barrier) { [storeURL] in
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                completion((.success(())))
                return
            }

            do {
                try FileManager.default.removeItem(at: storeURL)
                completion((.success(())))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
