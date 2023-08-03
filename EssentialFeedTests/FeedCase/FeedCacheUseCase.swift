//
//  FeedCacheUseCase.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 02/08/23.
//

import XCTest
import EssentialFeed

final class FeedCacheUseCase: XCTestCase {

    func test_init_doesNotDeleteCache() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_doesNotInsertDataOnDeletionError() {
        let (sut, store) = makeSUT()
        let timestamp = Date()

        sut.save(items: [uniqueItem(), uniqueItem()], timestamp: timestamp, completion: { _ in })
        store.completeDeletion(with: anyError())

        XCTAssertEqual(store.receivedMessages, [.deletion])
    }

    func test_save_insertFeedItemsWithTimeStampOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let timestamp = Date()

        sut.save(items: items, timestamp: timestamp, completion: { _ in })
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.receivedMessages, [.deletion, .insertion(items, timestamp)])
    }

    func test_save_deliveryErrorOnDeletionError() {
        let (sut, store) = makeSUT()
        let expectedError = anyError()

        expect(sut: sut, completeWithError: expectedError, when: {
            store.completeDeletion(with: expectedError)
        })
    }

    func test_save_deliveryErrorOnInsertionError() {
        let (sut, store) = makeSUT()
        let expectedError = anyError()

        expect(sut: sut, completeWithError: expectedError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: expectedError)
        })
    }

    func test_save_deliversNoErrorOnSuccessfulInsertion() {
        let (sut, store) = makeSUT()
        let timestamp = Date()

        let exp = expectation(description: "wait for ccompletion")
        sut.save(items: [uniqueItem(), uniqueItem()], timestamp: timestamp) { receivedError in
            XCTAssertNil(receivedError)
            exp.fulfill()
        }
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()
        wait(for: [exp], timeout: 1.0)
    }

    //MARK: Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    func expect(sut: LocalFeedLoader, completeWithError expectedError: NSError, when action: () -> Void) {
        let timestamp = Date()

        let exp = expectation(description: "wait for ccompletion")
        sut.save(items: [uniqueItem(), uniqueItem()], timestamp: timestamp) { receivedError in
            XCTAssertEqual((receivedError! as NSError).code, expectedError.code)
            XCTAssertEqual((receivedError! as NSError).domain, expectedError.domain)
            exp.fulfill()
        }
        action()

        wait(for: [exp], timeout: 1.0)
    }

    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }

    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }

    private func anyError() -> NSError {
        NSError(domain: "any Error", code: 0)
    }

    private class FeedStoreSpy: FeedStore {
        var receivedMessages = [ReceivedMessage]()
        var deletionCompletion: DeletionCompletion?
        var insertionCompletion: DeletionCompletion?

        enum ReceivedMessage: Equatable {
            case deletion
            case insertion([FeedItem], Date)
        }

        func deleteCache(completion: @escaping DeletionCompletion) {
            deletionCompletion = completion
            receivedMessages.append(.deletion)
        }

        func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletion = completion
            receivedMessages.append(.insertion(items, timestamp))
        }

        func completeDeletion(with error: NSError) {
            deletionCompletion?(error)
        }

        func completeDeletionSuccessfully() {
            deletionCompletion?(nil)
        }

        func completeInsertion(with error: NSError) {
            insertionCompletion?(error)
        }

        func completeInsertionSuccessfully() {
            insertionCompletion?(nil)
        }
    }
}
