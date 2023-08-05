//
//  CodableFeedStore.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 04/08/23.
//

import XCTest
@testable import EssentialFeed

final class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpec {

    override func setUp() {
        super.setUp()
        try? FileManager.default.removeItem(at: storeURL)
    }

    override func tearDown() {
        super.setUp()
        try? FileManager.default.removeItem(at: storeURL)
    }

    var storeURL: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(type(of: self)).store")
    }

    func test_retrieve_deliversEmptyFeedImagesOnEmptyCache() {
        let sut = makeSUT()

        assert_retrieve_deliversEmptyFeedImagesOnEmptyCache(sut: sut)
    }

    func test_retrieveTwice_deliversEmptyFeedImagesOnEmptyCache() {
        let sut = makeSUT()
        assert_retrieveTwice_deliversEmptyFeedImagesOnEmptyCache(sut: sut)
    }

    func test_retrieve_deliversFeedImagesOnNonEmptyCache() {
        let sut = makeSUT()
        assert_retrieve_deliversFeedImagesOnNonEmptyCache(sut: sut)
    }

    func test_retrieve_deliversErrorOnInvalidData() {
        let sut = makeSUT()
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        assert_retrieve_deliversErrorOnInvalidData(sut: sut)
    }

    func test_retrieveTwice_deliversFeedImagesOnNonEmptyCache() {
        let sut = makeSUT()
        assert_retrieveTwice_deliversFeedImagesOnNonEmptyCache(sut: sut)
    }

    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        assert_insert_deliversNoErrorOnEmptyCache(sut: sut)
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        assert_insert_deliversNoErrorOnNonEmptyCache(sut: sut)
    }

    func test_insert_overridesPreviousFeedWithNewFeed() {
        let sut = makeSUT()
        assert_insert_overridesPreviousFeedWithNewFeed(sut: sut)
    }

    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        assert_insert_deliversErrorOnInsertionError(sut: sut)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        assert_delete_hasNoSideEffectsOnEmptyCache(sut: sut)
    }

    func test_delete_deliverNoErrorOnEmptyCache() {
        let sut = makeSUT()
        assert_delete_deliverNoErrorOnEmptyCache(sut: sut)
    }

    func test_delete_deliverNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        assert_delete_deliverNoErrorOnNonEmptyCache(sut: sut)
    }

    func test_delete_emptiesPreviouslyInsertFeedImagesCache() {
        let sut = makeSUT()
        assert_delete_emptiesPreviouslyInsertFeedImagesCache(sut: sut)
    }

    func test_delete_deliversErrorOnPermissionError() {
        let sut = makeSUT(storeURL: FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!)
        assert_delete_deliversErrorOnPermissionError(sut: sut)
    }

    func test_sideEffects_runSeriallyToAvoidRaceConditions() {
        let sut = makeSUT()
        assert_sideEffects_runSeriallyToAvoidRaceConditions(sut: sut)
    }

    //MARK: Helpers
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? self.storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
