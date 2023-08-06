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

    func test_insert_overridesPreviousFeedWithNewFeed() {
        let sut = makeSUT()
        assert_insert_overridesPreviousFeedWithNewFeed(on: sut)
    }

    func test_insert_deliversErrorOnInsertionError() {}

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

    func test_delete_deliversErrorOnPermissionError() {}

    func test_sideEffects_runSeriallyToAvoidRaceConditions() {
        let sut = makeSUT()
        assert_sideEffects_runSeriallyToAvoidRaceConditions(on: sut)
    }

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let stack = InMemoryCoreDataStack(modelName: "CoreDataFeed", bundle: bundle)
        let sut = CoreDataFeedStore(coreDataStack: stack)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(stack, file: file, line: line)
        return sut
    }
}
