//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 06/08/23.
//

import Foundation
import XCTest
import EssentialFeed

final class CoreDataFeedStoreTests: XCTestCase, FailableFeedStoreSpec {

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

    func test_retrieve_deliversErrorOnInvalidData() {}

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

    func test_insert_overridesPreviousFeedWithNewFeed() {}

    func test_insert_deliversErrorOnInsertionError() {}

    func test_delete_hasNoSideEffectsOnEmptyCache() {}

    func test_delete_deliverNoErrorOnEmptyCache() {}

    func test_delete_deliverNoErrorOnNonEmptyCache() {}

    func test_delete_emptiesPreviouslyInsertFeedImagesCache() {}

    func test_delete_deliversErrorOnPermissionError() {}

    func test_sideEffects_runSeriallyToAvoidRaceConditions() {}

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let stack = InMemoryCoreDataStack(modelName: "CoreDataFeed", bundle: bundle)
        let sut = CoreDataFeedStore(coreDataStack: stack)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(stack, file: file, line: line)
        return sut
    }
}
