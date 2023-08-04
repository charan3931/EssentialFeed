//
//  CodableFeedStore.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 04/08/23.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    private struct CacheFeed: Codable {
        public let items: [CacheFeedImage]
        public let timestamp: Date

        var localFeedImages: [LocalFeedImage] {
            items.map { $0.localFeedImage }
        }
    }

    fileprivate struct CacheFeedImage: Equatable, Codable {
        let id: UUID
        let description: String?
        let location: String?
        let imageURL: URL

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
        guard let encoded = try? JSONEncoder().encode(CacheFeed(items: items.toCacheFeedImages(), timestamp: timestamp)), (try? encoded.write(to: storeURL)) != nil else {
            completion(nil)
            return
        }
        completion(nil)
    }
}

private extension Array where Element == LocalFeedImage {
    func toCacheFeedImages() -> [CodableFeedStore.CacheFeedImage] {
        map { CodableFeedStore.CacheFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
}

final class CodableFeedStoreTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }

    func test_retrieve_deliversEmptyFeedImagesOnEmptyCache() {
        let sut = CodableFeedStore()
        let expectedResult = FeedStore.Result.success(nil)

        let exp = expectation(description: "wait for completion")
        sut.retrieve(completion: { result in
            switch result {
            case let .success(feedCache):
                XCTAssertNil(feedCache)
            default:
                XCTFail("expected \(expectedResult) but instead got \(result)")
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieveTwice_deliversEmptyFeedImagesOnEmptyCache() {
        let sut = CodableFeedStore()

        let exp = expectation(description: "wait for completion")
        sut.retrieve(completion: { firstResult in
            sut.retrieve(completion: { secondResult in
                switch (firstResult, secondResult)  {
                case let (.success(firstFeedCache), .success(secondFeedCache)):
                    XCTAssertEqual(firstFeedCache, secondFeedCache)
                default:
                    XCTFail("expected empty cache on retrieval twice but instead got  \(firstResult) and \(secondResult)")
                }
                exp.fulfill()
            })
        })
        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieveAfterInsertingIntoEmptyCache_deliversInsertedFeedImages() {
        let sut = CodableFeedStore()
        let uniqueFeedImages = uniqueFeedImages().local
        let timestamp = currentDate()
        let expectedFeedCache = LocalCacheFeed(items: uniqueFeedImages, timestamp: timestamp)

        let exp = expectation(description: "wait for completion")
        sut.save(uniqueFeedImages, timestamp: timestamp) { error in
            XCTAssertNil(error, "expected feed to be inserted successfully")

            sut.retrieve(completion: { result in
                switch result  {
                case let .success(receivedFeedCache):
                    XCTAssertEqual(receivedFeedCache, expectedFeedCache)
                default:
                    XCTFail("expected \(expectedFeedCache) but instead got \(result)")
                }
                exp.fulfill()
            })
        }
        wait(for: [exp], timeout: 1.0)
    }
}
