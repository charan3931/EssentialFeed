//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 06/08/23.
//

import Foundation
import XCTest

final class CoreDataFeedStoreTests: XCTestCase, FailableFeedStoreSpec {

    func test_retrieve_deliversEmptyFeedImagesOnEmptyCache() {}

    func test_retrieveTwice_deliversEmptyFeedImagesOnEmptyCache() {}

    func test_retrieve_deliversFeedImagesOnNonEmptyCache() {}

    func test_retrieve_deliversErrorOnInvalidData() {}

    func test_retrieveTwice_deliversFeedImagesOnNonEmptyCache() {}

    func test_insert_deliversNoErrorOnEmptyCache() {}

    func test_insert_deliversNoErrorOnNonEmptyCache() {}

    func test_insert_overridesPreviousFeedWithNewFeed() {}

    func test_insert_deliversErrorOnInsertionError() {}

    func test_delete_hasNoSideEffectsOnEmptyCache() {}

    func test_delete_deliverNoErrorOnEmptyCache() {}

    func test_delete_deliverNoErrorOnNonEmptyCache() {}

    func test_delete_emptiesPreviouslyInsertFeedImagesCache() {}

    func test_delete_deliversErrorOnPermissionError() {}

    func test_sideEffects_runSeriallyToAvoidRaceConditions() {}
}
