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
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(type(of: self)).store")
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

    func test_retrieve_deliversErrorOnInvalidData() {
        let sut = makeSUT()

        try! "invalid data".write(to: Self.storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrieve: .failure(anyError()))
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

    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let uniqueFeedImages = uniqueFeedImages().local
        let timestamp = currentDate()

        let error = expect(sut, toInsert: uniqueFeedImages, timestamp)
        XCTAssertNotNil(error, "expected an Error but instead got nil")
    }

    //MARK: Helpers
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? Self.storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: FeedStore.Result, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")

        sut.retrieve(completion: { receivedResult in
            switch (receivedResult, expectedResult)  {
            case let (.success(receivedLocalFeed), .success(expectedLocalFeed)):
                XCTAssertEqual(receivedLocalFeed, expectedLocalFeed, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("expected \(expectedResult) but instead got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
    }

    @discardableResult
    private func expect(_ sut: CodableFeedStore, toInsert uniqueFeedImages: [LocalFeedImage], _ timestamp: Date) -> Error? {
        let exp = expectation(description: "wait for completion")
        var insertionError: Error?
        sut.save(uniqueFeedImages, timestamp: timestamp) { error in
            insertionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
}
