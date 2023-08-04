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

        sut.retrieve() { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_retrieve_deliversErrorOnRetrievalError() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let expectedError = anyError()

        expect(sut, with: currentDate(), completeWith: .failure(expectedError), when: {
            store.completeRetrieval(with: anyError())
        })
    }

    func test_retrieve_deliversEmptyFeedImagesOnEmptyCache() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, with: currentDate(), completeWith: .success([]), when: {
            store.completeRetrievalSuccessful(with: [], timestamp: currentDate())
        })
    }

    func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let feed = uniqueImageFeed()
        let validTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)

        expect(sut, with: fixedCurrentDate, completeWith: .success(feed.models), when: {
            store.completeRetrievalSuccessful(with: feed.local, timestamp: validTimestamp)
        })
    }

    func test_load_deliversNoImagesOnTimestampExpired() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let feed = uniqueImageFeed()
        let expiredTimestamp = fixedCurrentDate.adding(days: -7)

        expect(sut, with: fixedCurrentDate, completeWith: .success([]), when: {
            store.completeRetrievalSuccessful(with: feed.local, timestamp: expiredTimestamp)
        })
    }

    func test_load_deliversNoImagesOnMoreThanExpiredTime() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let feed = uniqueImageFeed()
        let expiredTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)

        expect(sut, with: fixedCurrentDate, completeWith: .success([]), when: {
            store.completeRetrievalSuccessful(with: feed.local, timestamp: expiredTimestamp)
        })
    }

    //MARK: Helpers

    private func makeSUT(currentDate: @escaping () -> Date, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(currentDate: currentDate, store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func expect(_ sut: LocalFeedLoader, with currentDate: Date,completeWith expectedResult: LoadFeedResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        sut.retrieve() { receivedResult in
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

    private func anyError() -> NSError {
        NSError(domain: "any Error", code: 0)
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

    private func currentDate() -> Date {
        Date()
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
