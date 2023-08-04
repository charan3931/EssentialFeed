//
//  CodableFeedStore.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 04/08/23.
//

import XCTest
@testable import EssentialFeed 

final class CodableFeedStoreTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }

    override class func tearDown() {
        super.tearDown()
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
