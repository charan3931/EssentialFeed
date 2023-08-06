//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 06/08/23.
//

import Foundation
import EssentialFeed
import XCTest

extension FailableInsertFeedStoreSpecs {
    func assert_insert_deliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let uniqueFeedImages = uniqueFeedImages().local
        let timestamp = currentDate()

        let error = save(feedImages: uniqueFeedImages, timestamp: timestamp, to: sut)

        XCTAssertNotNil(error, "expected an Error but instead got nil")
    }
}
