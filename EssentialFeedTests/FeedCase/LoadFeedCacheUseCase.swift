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
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    //MARK: Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private class FeedStoreSpy: FeedStore {
        var receivedMessages = [ReceivedMessage]()
        var deletionCompletion: DeletionCompletion?
        var insertionCompletion: DeletionCompletion?

        enum ReceivedMessage: Equatable {
            case deletion
            case insertion([LocalFeedImage], Date)
        }

        func deleteCache(completion: @escaping DeletionCompletion) {
            deletionCompletion = completion
            receivedMessages.append(.deletion)
        }

        func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
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
