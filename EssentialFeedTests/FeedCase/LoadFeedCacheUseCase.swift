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
}
