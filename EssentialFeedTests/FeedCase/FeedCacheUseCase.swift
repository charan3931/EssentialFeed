//
//  FeedCacheUseCase.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 02/08/23.
//

import XCTest

class LocalFeedLoader {

}

class FeedStore {
    var deletionCount = 0
}

final class FeedCacheUseCase: XCTestCase {

    func test_init_doesNotDeleteCache() {
        let sut = LocalFeedLoader()
        let store = FeedStore()

        XCTAssertTrue(store.deletionCount == 0)
    }
}
