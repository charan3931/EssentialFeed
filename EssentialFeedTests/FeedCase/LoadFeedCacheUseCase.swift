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

        expect(sut, completeWith: .failure(expectedError), when: {
            store.completeRetrieval(with: anyError())
        })
    }

    func test_retrieve_deliversEmptyFeedImagesOnEmptyCache() {
        let (sut, store) = makeSUT()

        expect(sut, completeWith: .success([]), when: {
            store.completeRetrievalSuccessful(with: [])
        })
    }

    //MARK: Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func expect(_ sut: LocalFeedLoader, completeWith expectedResult: LoadFeedResult, when action: () -> Void) {
        let exp = expectation(description: "wait for completion")
        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError)
            default:
                XCTFail("expected \(expectedResult) but instead got \(receivedResult)")
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }

    private func anyError() -> NSError {
        NSError(domain: "any Error", code: 0)
    }
}
