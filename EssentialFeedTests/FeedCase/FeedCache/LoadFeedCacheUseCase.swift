//
//  LoadFeedCacheUseCase.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 03/08/23.
//

import XCTest
import EssentialFeed

final class LoadFeedCacheUseCase: XCTestCase {

    func test_init_doesNotMessagesStoreOnCreation() {
        let (_, store) = makeSUT(currentDate: Date.init)

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_retrieve_messagesStoreToRetrieve() {
        let (sut, store) = makeSUT(currentDate: Date.init)

        sut.load() { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_retrieve_deliversErrorOnRetrievalError() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let expectedError = anyError()

        expect(sut, completeWith: .failure(expectedError), when: {
            store.completeRetrieval(with: anyError())
        })
    }

    func test_retrieve_deliversEmptyFeedImagesOnEmptyCache() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, completeWith: .success([]), when: {
            store.completeRetrievalSuccessfulWithEmptyFeed()
        })
    }

    func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let feed = uniqueFeedImages()
        let validTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)

        expect(sut, completeWith: .success(feed.models), when: {
            store.completeRetrievalSuccessful(with: feed.local, timestamp: validTimestamp)
        })
    }

    func test_load_deliversNoImagesOnTimestampExpired() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let expiredTimestamp = fixedCurrentDate.adding(days: -7)

        expect(sut, completeWith: .success([]), when: {
            store.completeRetrievalSuccessful(with: uniqueFeedImages().local, timestamp: expiredTimestamp)
        })
    }

    func test_load_deliversNoImagesOnMoreThanExpiredTime() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let expiredTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)

        expect(sut, completeWith: .success([]), when: {
            store.completeRetrievalSuccessful(with: uniqueFeedImages().local, timestamp: expiredTimestamp)
        })
    }

    func test_save_doesNotDeliverErrorOnLoadErrorAfterSUTInstanceDeallocated() {
        let store = FeedStoreSpy()
        let fixedCurrentDate = currentDate()
        var sut: LocalFeedLoader? = LocalFeedLoader(currentDate: { fixedCurrentDate }, store: store)

        var capturedResult = [LoadFeedResult]()
        sut?.load { result in
            capturedResult.append(result)
        }
        sut = nil
        store.completeRetrieval(with: anyError())

        XCTAssertTrue(capturedResult.isEmpty)
    }

    func test_save_doesNotDeliverFeedImagesOnSuccesfulLoadAfterSUTInstanceDeallocated() {
        let store = FeedStoreSpy()
        let fixedCurrentDate = currentDate()
        var sut: LocalFeedLoader? = LocalFeedLoader(currentDate: { fixedCurrentDate }, store: store)

        var capturedResult = [LoadFeedResult]()
        sut?.load { result in
            capturedResult.append(result)
        }
        sut = nil
        store.completeRetrievalSuccessful(with: uniqueFeedImages().local, timestamp: fixedCurrentDate)

        XCTAssertTrue(capturedResult.isEmpty)
    }


    //MARK: Helpers

    private func makeSUT(currentDate: @escaping () -> Date, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(currentDate: currentDate, store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func expect(_ sut: LocalFeedLoader,completeWith expectedResult: LoadFeedResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        sut.load() { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError,  file: file, line: line)
            default:
                XCTFail("expected \(expectedResult) but instead got \(receivedResult)",  file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
