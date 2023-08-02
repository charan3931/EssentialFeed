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
    private var error: Error?

    func deleteCache() {
        if let error { return }
        deletionCount += 1
    }

    func complete(with error: NSError) {
        self.error = error
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

    func test_save_doesNotDeleteCacheOnDeletionError() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        store.complete(with: NSError(domain: "any Error", code: 0))

        sut.save()

        XCTAssertTrue(store.deletionCount == 0)
    }
}
