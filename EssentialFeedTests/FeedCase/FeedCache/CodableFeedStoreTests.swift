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
        try? FileManager.default.removeItem(at: storeURL)
    }

    override class func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: storeURL)
    }

    static var storeURL: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "image-feed.store")
    }

    func test_retrieve_deliversEmptyFeedImagesOnEmptyCache() {
        let sut = makeSUT()

        let exp = expectation(description: "wait for completion")
        sut.retrieve(completion: { result in
            switch result {
            case let .success(feedCache):
                XCTAssertNil(feedCache)
            default:
                XCTFail("expected success but instead got \(result)")
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieveTwice_deliversEmptyFeedImagesOnEmptyCache() {
        let sut = makeSUT()

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
        let sut = makeSUT()
        let uniqueFeedImages = uniqueFeedImages().local
        let timestamp = currentDate()
        let expectedLocalFeed = LocalFeed(items: uniqueFeedImages, timestamp: timestamp)

        let exp = expectation(description: "wait for completion")
        sut.save(uniqueFeedImages, timestamp: timestamp) { error in
            XCTAssertNil(error, "expected feed to be inserted successfully")

            sut.retrieve(completion: { result in
                switch result  {
                case let .success(receivedLocalFeed):
                    XCTAssertEqual(receivedLocalFeed, expectedLocalFeed)
                default:
                    XCTFail("expected \(expectedLocalFeed) but instead got \(result)")
                }
                exp.fulfill()
            })
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: Self.storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
