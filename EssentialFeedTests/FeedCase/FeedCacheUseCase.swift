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
        store.insert()
    }
}

class FeedStore {
    var deletionCount = 0
    var insertionCount = 0
    private var error: Error?

    func deleteCache() {
        if error != nil { return }
        deletionCount += 1
    }

    func insert() {
        if error != nil { return }
        insertionCount += 1
    }

    func complete(with error: NSError) {
        self.error = error
    }
}

final class FeedCacheUseCase: XCTestCase {

    func test_init_doesNotDeleteCache() {
        let (_, store) = makeSUT()

        XCTAssertTrue(store.deletionCount == 0)
    }

    func test_save_deletesCache() {
        let (sut, store) = makeSUT()

        sut.save()

        XCTAssertTrue(store.deletionCount == 1)
    }

    func test_save_doesNotDeleteCacheOnDeletionError() {
        let (sut, store) = makeSUT()
        store.complete(with: NSError(domain: "any Error", code: 0))

        sut.save()

        XCTAssertTrue(store.deletionCount == 0)
    }

    func test_save_doesNotInsertDataOnDeletionError() {
        let (sut, store) = makeSUT()
        store.complete(with: NSError(domain: "any Error", code: 0))

        sut.save()

        XCTAssertTrue(store.insertionCount == 0)
    }

    func test_save_doesNotInsertOnInsertionError() {
        let (sut, store) = makeSUT()
        store.complete(with: NSError(domain: "any Error", code: 0))

        sut.save()

        XCTAssertTrue(store.insertionCount == 0)
    }

    //MARK: Helpers

    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
}
