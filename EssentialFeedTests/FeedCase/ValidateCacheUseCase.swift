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

        sut.validateCache() { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validateCache_deliversErrorOnRetrievalError() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let expectedError = anyError()

        expect(sut, completeWithError: expectedError, when: {
            store.completeRetrieval(with: expectedError)
        })
    }

    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache() { _ in }
        store.completeRetrievalSuccessful(with: [], timestamp: currentDate())
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validateCache_doesNotDeleteCacheOnValidCache() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let validTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)

        sut.validateCache() { _ in }
        store.completeRetrievalSuccessful(with: uniqueImageFeed().local, timestamp: validTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])

    }

    func test_validateCache_deletesCacheOnTimestampExpired() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let expiredTimestamp = fixedCurrentDate.adding(days: -7)

        sut.validateCache() { _ in }
        store.completeRetrievalSuccessful(with: uniqueImageFeed().local, timestamp: expiredTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deletion])
    }

    func test_validateCache_deletesCacheOnMoreThanExpiredTime() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let expiredTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)

        sut.validateCache() { _ in }
        store.completeRetrievalSuccessful(with: uniqueImageFeed().local, timestamp: expiredTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deletion])
    }

    //MARK: Helpers
    private func makeSUT(currentDate: @escaping () -> Date, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(currentDate: currentDate, store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    func expect(_ sut: LocalFeedLoader, completeWithError expectedError: NSError, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for ccompletion")
        sut.validateCache { receivedError in
            XCTAssertEqual((receivedError! as NSError).code, expectedError.code, file: file, line: line)
            XCTAssertEqual((receivedError! as NSError).domain, expectedError.domain, file: file, line: line)
            exp.fulfill()
        }
        action()

        wait(for: [exp], timeout: 1.0)
    }

    private func anyError() -> NSError {
        NSError(domain: "any Error", code: 0)
    }

    private func currentDate() -> Date {
        Date()
    }
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }

    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }

    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let models = [uniqueImage(), uniqueImage()]
        let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
        return (models, local)
    }
}

private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}

