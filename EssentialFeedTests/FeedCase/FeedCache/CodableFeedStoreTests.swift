//
//  CodableFeedStore.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 04/08/23.
//

import XCTest
@testable import EssentialFeed 

final class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        try? FileManager.default.removeItem(at: Self.storeURL)
    }

    override func tearDown() {
        super.setUp()
        try? FileManager.default.removeItem(at: Self.storeURL)
    }

    static var storeURL: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "image-feed.store")
    }

    func test_retrieve_deliversEmptyFeedImagesOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieve: .success(nil))
    }

    func test_retrieveTwice_deliversEmptyFeedImagesOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieve: .success(nil))
        expect(sut, toRetrieve: .success(nil))
    }

    func test_retrieve_deliversFeedImagesOnNonEmptyCache() {
        let sut = makeSUT()
        let uniqueFeedImages = uniqueFeedImages().local
        let timestamp = currentDate()
        let expectedLocalFeed = LocalFeed(items: uniqueFeedImages, timestamp: timestamp)

        expect(sut, toInsert: uniqueFeedImages, timestamp)
        expect(sut, toRetrieve: .success(expectedLocalFeed))
    }

    func test_retrieveTwice_deliversFeedImagesOnNonEmptyCache() {
        let sut = makeSUT()
        let uniqueFeedImages = uniqueFeedImages().local
        let timestamp = currentDate()
        let expectedLocalFeed = LocalFeed(items: uniqueFeedImages, timestamp: timestamp)

        expect(sut, toInsert: uniqueFeedImages, timestamp)
        expect(sut, toRetrieve: .success(expectedLocalFeed))
        expect(sut, toRetrieve: .success(expectedLocalFeed))
    }

    func test_insert_overridesPreviousFeedWithNewFeed() {
        let sut = makeSUT()
        let uniqueFeedImages1 = uniqueFeedImages().local
        let uniqueFeedImages2 = uniqueFeedImages().local
        let timestamp = currentDate()
        let expectedLocalFeed = LocalFeed(items: uniqueFeedImages2, timestamp: timestamp)

        expect(sut, toInsert: uniqueFeedImages1, timestamp)
        expect(sut, toInsert: uniqueFeedImages2, timestamp)
        expect(sut, toRetrieve: .success(expectedLocalFeed))
    }

    //MARK: Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: Self.storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: FeedStore.Result, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")

        sut.retrieve(completion: { receivedResult in
            switch (receivedResult, expectedResult)  {
            case let (.success(receivedLocalFeed), .success(expectedLocalFeed)):
                XCTAssertEqual(receivedLocalFeed, expectedLocalFeed, file: file, line: line)
            default:
                XCTFail("expected \(expectedResult) but instead got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
    }

    private func expect(_ sut: CodableFeedStore, toInsert uniqueFeedImages: [LocalFeedImage], _ timestamp: Date) {
        let exp = expectation(description: "wait for completion")
        sut.save(uniqueFeedImages, timestamp: timestamp) { error in
            XCTAssertNil(error, "expected feed to be inserted successfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
