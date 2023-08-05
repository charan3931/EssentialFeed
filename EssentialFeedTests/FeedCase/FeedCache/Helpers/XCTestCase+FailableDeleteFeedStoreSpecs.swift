//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 06/08/23.
//

import Foundation
import EssentialFeed
import XCTest

extension FailableDeleteFeedStoreSpecs {
    func assert_delete_deliversErrorOnPermissionError(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)

        XCTAssertNotNil(deletionError, "Expected error while deletion but succeeded instead")
    }
}
