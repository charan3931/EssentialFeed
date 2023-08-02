//
//  FeedCacheUseCase.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 02/08/23.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {

    let store: FeedStore

    init(store: FeedStore) {
        self.store = store
    }

    func save(items: [FeedItem]) {
        store.deleteCache() { [unowned self] error in
            if error == nil {
                self.store.insert(items)
            }
        }
    }
}

class FeedStore {
    var deletionCount = 0
    var insertionCount = 0
    private var error: Error?

    func deleteCache(completion: @escaping (Error?) -> Void) {
        if error != nil { return }
        deletionCount += 1
        completion(nil)
    }

    func insert(_ items: [FeedItem]) {
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

        sut.save(items: [uniqueItem(), uniqueItem()])

        XCTAssertTrue(store.deletionCount == 1)
    }

    func test_save_doesNotDeleteCacheOnDeletionError() {
        let (sut, store) = makeSUT()
        store.complete(with: NSError(domain: "any Error", code: 0))

        sut.save(items: [uniqueItem(), uniqueItem()])

        XCTAssertTrue(store.deletionCount == 0)
    }

    func test_save_doesNotInsertDataOnDeletionError() {
        let (sut, store) = makeSUT()
        store.complete(with: NSError(domain: "any Error", code: 0))

        sut.save(items: [uniqueItem(), uniqueItem()])

        XCTAssertTrue(store.insertionCount == 0)
    }

    func test_save_doesNotInsertOnInsertionError() {
        let (sut, store) = makeSUT()
        store.complete(with: NSError(domain: "any Error", code: 0))

        sut.save(items: [uniqueItem(), uniqueItem()])

        XCTAssertTrue(store.insertionCount == 0)
    }

    func test_save_insertSuccessOnNoError() {
        let (sut, store) = makeSUT()

        sut.save(items: [uniqueItem(), uniqueItem()])

        XCTAssertTrue(store.insertionCount == 1)
    }

    func test_save_insertFeedItemsOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()

        sut.save(items: [uniqueItem(), uniqueItem()])

        XCTAssertTrue(store.insertionCount == 1)
    }

    //MARK: Helpers

    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }

    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
}
