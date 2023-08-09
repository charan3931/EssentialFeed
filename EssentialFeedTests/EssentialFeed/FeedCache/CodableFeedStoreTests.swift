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

    private var storeURL: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(type(of: self)).store")
    }

    func test_retrieve_deliversEmptyFeedImagesOnEmptyCache() {
        let sut = makeSUT()

        assert_retrieve_deliversEmptyFeedImagesOnEmptyCache(on: sut)
    }

    func test_retrieveTwice_deliversEmptyFeedImagesOnEmptyCache() {
        let sut = makeSUT()
        assert_retrieveTwice_deliversEmptyFeedImagesOnEmptyCache(on: sut)
    }

    func test_retrieve_deliversFeedImagesOnNonEmptyCache() {
        let sut = makeSUT()
        assert_retrieve_deliversFeedImagesOnNonEmptyCache(on: sut)
    }

    func test_retrieve_deliversErrorOnInvalidData() {
        let sut = makeSUT()
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        assert_retrieve_deliversErrorOnInvalidData(on: sut)
    }

    func test_retrieveTwice_deliversFeedImagesOnNonEmptyCache() {
        let sut = makeSUT()
        assert_retrieveTwice_deliversFeedImagesOnNonEmptyCache(on: sut)
    }

    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        assert_insert_deliversNoErrorOnEmptyCache(on: sut)
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        assert_insert_deliversNoErrorOnNonEmptyCache(on: sut)
    }

    func test_insert_overridesPreviousFeedWithNewFeed() {
        let sut = makeSUT()
        assert_insert_overridesPreviousFeedWithNewFeed(on: sut)
    }

    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        assert_insert_deliversErrorOnInsertionError(on: sut)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        assert_delete_hasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_delete_deliverNoErrorOnEmptyCache() {
        let sut = makeSUT()
        assert_delete_deliverNoErrorOnEmptyCache(on: sut)
    }

    func test_delete_deliverNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        assert_delete_deliverNoErrorOnNonEmptyCache(on: sut)
    }

    func test_delete_emptiesPreviouslyInsertFeedImagesCache() {
        let sut = makeSUT()
        assert_delete_emptiesPreviouslyInsertFeedImagesCache(on: sut)
    }

    func test_delete_deliversErrorOnPermissionError() {
        let sut = makeSUT(storeURL: FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!)
        assert_delete_deliversErrorOnPermissionError(on: sut)
    }

    func test_sideEffects_runSeriallyToAvoidRaceConditions() {
        let sut = makeSUT()
        assert_sideEffects_runSeriallyToAvoidRaceConditions(on: sut)
    }

    //MARK: Helpers
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? self.storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
