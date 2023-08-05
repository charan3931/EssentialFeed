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
        try? FileManager.default.removeItem(at: storeURL)
    }

    override func tearDown() {
        super.setUp()
        try? FileManager.default.removeItem(at: storeURL)
    }

    var storeURL: URL {
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

        save(feedImages: uniqueFeedImages, timestamp: timestamp, to: sut)

        expect(sut, toRetrieve: .success(expectedLocalFeed))
    }

    func test_retrieve_deliversErrorOnInvalidData() {
        let sut = makeSUT()

        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrieve: .failure(anyError()))
    }

    func test_retrieveTwice_deliversFeedImagesOnNonEmptyCache() {
        let sut = makeSUT()
        let uniqueFeedImages = uniqueFeedImages().local
        let timestamp = currentDate()
        let expectedLocalFeed = LocalFeed(items: uniqueFeedImages, timestamp: timestamp)

        save(feedImages: uniqueFeedImages, timestamp: timestamp, to: sut)

        expect(sut, toRetrieve: .success(expectedLocalFeed))
        expect(sut, toRetrieve: .success(expectedLocalFeed))
    }

    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        let deliveredError = save(feedImages: uniqueFeedImages().local, timestamp: currentDate(), to: sut)

        XCTAssertNil(deliveredError)
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let uniqueFeedImages = uniqueFeedImages().local
        let timestamp = currentDate()

        save(feedImages: uniqueFeedImages, timestamp: timestamp, to: sut)
        let deliveredError = save(feedImages: uniqueFeedImages, timestamp: timestamp, to: sut)

        XCTAssertNil(deliveredError)
    }

    func test_insert_overridesPreviousFeedWithNewFeed() {
        let sut = makeSUT()
        let uniqueFeedImages1 = uniqueFeedImages().local
        let uniqueFeedImages2 = uniqueFeedImages().local
        let timestamp = currentDate()
        let expectedLocalFeed = LocalFeed(items: uniqueFeedImages2, timestamp: timestamp)

        save(feedImages: uniqueFeedImages1, timestamp: timestamp, to: sut)
        save(feedImages: uniqueFeedImages2, timestamp: timestamp, to: sut)

        expect(sut, toRetrieve: .success(expectedLocalFeed))
    }

    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let uniqueFeedImages = uniqueFeedImages().local
        let timestamp = currentDate()

        let error = save(feedImages: uniqueFeedImages, timestamp: timestamp, to: sut)

        XCTAssertNotNil(error, "expected an Error but instead got nil")
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        sut.deleteCache(completion: { deletionError in
            XCTAssertNil(deletionError, "Expected empty cache deletion to succeed but instead got \(deletionError.debugDescription)")
        })

        expect(sut, toRetrieve: .success(nil))
    }

    func test_delete_deliverNoErrorOnEmptyCache() {
        let sut = makeSUT()

        sut.deleteCache(completion: { deletionError in
            XCTAssertNil(deletionError, "Expected empty cache deletion to succeed but instead got \(deletionError.debugDescription)")
        })
    }

    func test_delete_deliverNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let uniqueFeedImages = uniqueFeedImages().local
        let timestamp = currentDate()

        save(feedImages: uniqueFeedImages, timestamp: timestamp, to: sut)
        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }

    func test_delete_emptiesPreviouslyInsertFeedImagesCache() {
        let sut = makeSUT()
        let uniqueFeedImages = uniqueFeedImages().local
        let timestamp = currentDate()

        save(feedImages: uniqueFeedImages, timestamp: timestamp, to: sut)
        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(nil))
    }

    func test_delete_deliversErrorOnPermissionError() {
        let sut = makeSUT(storeURL: FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!)

        let deletionError = deleteCache(from: sut)

        XCTAssertNotNil(deletionError, "Expected error while deletion but succeeded instead")
    }

    func test_sideEffects_runSeriallyToAvoidRaceConditions() {
        let sut = makeSUT()
        var completedOperationsInOrder = [XCTestExpectation]()

        let op1 = expectation(description: "Operation 1")
        sut.save(uniqueFeedImages().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.deleteCache { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Operation 3")
        sut.save(uniqueFeedImages().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }

        waitForExpectations(timeout: 5.0)
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3])
    }

    //MARK: Helpers
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? self.storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedStore.Result, file: StaticString = #filePath, line: UInt = #line) {
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
    private func save(feedImages uniqueFeedImages: [LocalFeedImage], timestamp: Date, to sut: FeedStore) -> Error? {
        let exp = expectation(description: "wait for completion")
        var insertionError: Error?
        sut.save(uniqueFeedImages, timestamp: timestamp) { error in
            insertionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }

    @discardableResult
    private func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "wait for completion")

        var deletionError: Error?
        sut.deleteCache { error in
            deletionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return deletionError
    }
}
