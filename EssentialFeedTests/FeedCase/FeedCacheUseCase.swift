//
//  FeedCacheUseCase.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 02/08/23.
//

import XCTest

class LocalFeedLoader {

    let store: FeedStore

    init(store: FeedStore) {
        self.store = store
    }

    func save() {
        store.deleteCache()
    }
}

class FeedStore {
    var deletionCount = 0

    func deleteCache() {
        deletionCount += 1
    }
}

final class FeedCacheUseCase: XCTestCase {

    func test_init_doesNotDeleteCache() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)

        XCTAssertTrue(store.deletionCount == 0)
    }

    func test_save_deletesCache() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)

        sut.save()

        XCTAssertTrue(store.deletionCount == 1)
    }
}
