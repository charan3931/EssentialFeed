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

    func test_retrieve_messagesStoreToRetrieve() {
        let (sut, store) = makeSUT()

        sut.retrieve() { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_retrieve_deliversErrorOnRetrievalError() {
        let (sut, store) = makeSUT()
        let expectedError = anyError()

        let exp = expectation(description: "wait for completion")
        sut.retrieve { error in
            XCTAssertEqual((error! as NSError).code, expectedError.code)
            XCTAssertEqual((error! as NSError).domain, expectedError.domain)
            exp.fulfill()
        }
        store.completeRetrieval(with: anyError())

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

    private func anyError() -> NSError {
        NSError(domain: "any Error", code: 0)
    }
}
