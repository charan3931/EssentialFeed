//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 06/08/23.
//

import EssentialFeed
import XCTest

extension FeedStoreSpecs {
    func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedStore.Result, file: StaticString = #filePath, line: UInt = #line) {
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
    func save(feedImages uniqueFeedImages: [LocalFeedImage], timestamp: Date, to sut: FeedStore) -> Error? {
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
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "wait for completion")

        var deletionError: Error?
        sut.deleteCache { error in
            deletionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return deletionError
    }

    func assert_retrieve_deliversEmptyFeedImagesOnEmptyCache(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .success(nil))
    }

    func assert_retrieveTwice_deliversEmptyFeedImagesOnEmptyCache(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .success(nil))
        expect(sut, toRetrieve: .success(nil))
    }

    func assert_retrieve_deliversFeedImagesOnNonEmptyCache(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let uniqueFeedImages = uniqueFeedImages().local
        let timestamp = currentDate()
        let expectedLocalFeed = LocalFeed(items: uniqueFeedImages, timestamp: timestamp)

        save(feedImages: uniqueFeedImages, timestamp: timestamp, to: sut)

        expect(sut, toRetrieve: .success(expectedLocalFeed))
    }

    func assert_retrieveTwice_deliversFeedImagesOnNonEmptyCache(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let uniqueFeedImages = uniqueFeedImages().local
        let timestamp = currentDate()
        let expectedLocalFeed = LocalFeed(items: uniqueFeedImages, timestamp: timestamp)

        save(feedImages: uniqueFeedImages, timestamp: timestamp, to: sut)

        expect(sut, toRetrieve: .success(expectedLocalFeed))
        expect(sut, toRetrieve: .success(expectedLocalFeed))
    }

    func assert_insert_deliversNoErrorOnEmptyCache(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deliveredError = save(feedImages: uniqueFeedImages().local, timestamp: currentDate(), to: sut)

        XCTAssertNil(deliveredError)
    }

    func assert_insert_deliversNoErrorOnNonEmptyCache(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let uniqueFeedImages = uniqueFeedImages().local
        let timestamp = currentDate()

        save(feedImages: uniqueFeedImages, timestamp: timestamp, to: sut)
        let deliveredError = save(feedImages: uniqueFeedImages, timestamp: timestamp, to: sut)

        XCTAssertNil(deliveredError)
    }

    func assert_insert_overridesPreviousFeedWithNewFeed(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let uniqueFeedImages1 = uniqueFeedImages().local
        let uniqueFeedImages2 = uniqueFeedImages().local
        let timestamp = currentDate()
        let expectedLocalFeed = LocalFeed(items: uniqueFeedImages2, timestamp: timestamp)

        save(feedImages: uniqueFeedImages1, timestamp: timestamp, to: sut)
        save(feedImages: uniqueFeedImages2, timestamp: timestamp, to: sut)

        expect(sut, toRetrieve: .success(expectedLocalFeed))
    }

    func assert_delete_hasNoSideEffectsOnEmptyCache(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        sut.deleteCache(completion: { deletionError in
            XCTAssertNil(deletionError, "Expected empty cache deletion to succeed but instead got \(deletionError.debugDescription)")
        })

        expect(sut, toRetrieve: .success(nil))
    }

    func assert_delete_deliverNoErrorOnEmptyCache(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        sut.deleteCache(completion: { deletionError in
            XCTAssertNil(deletionError, "Expected empty cache deletion to succeed but instead got \(deletionError.debugDescription)")
        })
    }

    func assert_delete_deliverNoErrorOnNonEmptyCache(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let uniqueFeedImages = uniqueFeedImages().local
        let timestamp = currentDate()

        save(feedImages: uniqueFeedImages, timestamp: timestamp, to: sut)
        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }

    func assert_delete_emptiesPreviouslyInsertFeedImagesCache(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let uniqueFeedImages = uniqueFeedImages().local
        let timestamp = currentDate()

        save(feedImages: uniqueFeedImages, timestamp: timestamp, to: sut)
        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(nil))
    }

    func assert_sideEffects_runSeriallyToAvoidRaceConditions(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
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
}
