//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 06/08/23.
//

import Foundation
import EssentialFeed

extension FailableRetrieveFeedStoreSpecs {
    func assert_retrieve_deliversErrorOnInvalidData(sut: FeedStore,file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .failure(anyError()))
    }
}
