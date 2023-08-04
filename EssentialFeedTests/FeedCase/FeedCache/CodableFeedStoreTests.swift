//
//  CodableFeedStore.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 04/08/23.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.success(nil))
    }
}

final class CodableFeedStoreTests: XCTestCase {

    func test_retrieve_deliversEmptyFeedImagesOnEmptyCache() {
        let sut = CodableFeedStore()
        let expectedResult = FeedStore.Result.success(nil)

        let exp = expectation(description: "wait for completion")
        sut.retrieve(completion: { result in
            switch result {
            case let .success(feedCache):
                XCTAssertNil(feedCache)
            default:
                XCTFail("expected \(expectedResult) but instead got \(result)")
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieveTwice_deliversEmptyFeedImagesOnEmptyCache() {
        let sut = CodableFeedStore()
        let expectedResult = FeedStore.Result.success(nil)

        let exp = expectation(description: "wait for completion")
        sut.retrieve(completion: { firstResult in
            sut.retrieve(completion: { secondResult in
                switch (firstResult, secondResult)  {
                case let (.success(firstFeedCache), .success(secondFeedCache)):
                    XCTAssertEqual(firstFeedCache, secondFeedCache)
                default:
                    XCTFail("expected empty cache on retrieval twice but instead got  \(firstResult) and \(secondResult)")
                }
                exp.fulfill()
            })
        })
        wait(for: [exp], timeout: 1.0)
    }
}
