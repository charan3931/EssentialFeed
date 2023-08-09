//
//  ValidateCacheUseCase.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 04/08/23.
//

import XCTest
import EssentialFeed

final class ValidateCacheUseCase: XCTestCase {

    func test_init_doesNotMessagesStoreOnCreation() {
        let (_, store) = makeSUT(currentDate: Date.init)

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_validateCache_messagesStoreToRetrieve() {
        let (sut, store) = makeSUT(currentDate: Date.init)

        sut.validateCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetrievalSuccessful(with: [], timestamp: currentDate())
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validateCache_doesNotDeleteCacheOnValidCache() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let validTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)

        sut.validateCache()
        store.completeRetrievalSuccessful(with: uniqueFeedImages().local, timestamp: validTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])

    }

    func test_validateCache_deletesCacheOnTimestampExpired() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let expiredTimestamp = fixedCurrentDate.adding(days: -7)

        sut.validateCache()
        store.completeRetrievalSuccessful(with: uniqueFeedImages().local, timestamp: expiredTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deletion])
    }

    func test_validateCache_deletesCacheOnMoreThanExpiredTime() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let expiredTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)

        sut.validateCache()
        store.completeRetrievalSuccessful(with: uniqueFeedImages().local, timestamp: expiredTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deletion])
    }

    func test_validateCache_doesNotDeleteCacheOnExpiredTimestampAfterSUTInstanceDeallocated() {
        let store = FeedStoreSpy()
        let fixedCurrentDate = currentDate()
        var sut: LocalFeedLoader? = LocalFeedLoader(currentDate: { fixedCurrentDate }, store: store)
        let expiredTimestamp = fixedCurrentDate.adding(days: -7)

        sut?.validateCache()
        sut = nil
        store.completeRetrievalSuccessful(with: uniqueFeedImages().local, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    //MARK: Helpers
    private func makeSUT(currentDate: @escaping () -> Date, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(currentDate: currentDate, store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
}

