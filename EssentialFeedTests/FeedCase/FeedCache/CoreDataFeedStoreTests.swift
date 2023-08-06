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

        assert_retrieve_deliversEmptyFeedImagesOnEmptyCache(sut: sut)
    }

    func test_retrieveTwice_deliversEmptyFeedImagesOnEmptyCache() {
        let sut = makeSUT()

        assert_retrieveTwice_deliversEmptyFeedImagesOnEmptyCache(sut: sut)
    }

    func test_retrieve_deliversFeedImagesOnNonEmptyCache() {}

    func test_retrieve_deliversErrorOnInvalidData() {}

    func test_retrieveTwice_deliversFeedImagesOnNonEmptyCache() {}

    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        assert_insert_deliversNoErrorOnEmptyCache(sut: sut)
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {}

    func test_insert_overridesPreviousFeedWithNewFeed() {}

    func test_insert_deliversErrorOnInsertionError() {}

    func test_delete_hasNoSideEffectsOnEmptyCache() {}

    func test_delete_deliverNoErrorOnEmptyCache() {}

    func test_delete_deliverNoErrorOnNonEmptyCache() {}

    func test_delete_emptiesPreviouslyInsertFeedImagesCache() {}

    func test_delete_deliversErrorOnPermissionError() {}

    func test_sideEffects_runSeriallyToAvoidRaceConditions() {}

    private func makeSUT() -> FeedStore {
        return CoreDataFeedStore(coreDataStack: InMemoryCoreDataStack(modelName: "CoreDataFeed"))
    }
}
