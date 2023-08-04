//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Sai Charan on 03/08/23.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias SaveCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (Result) -> Void

    typealias Result = Swift.Result<LocalCacheFeed?, Error>

    func deleteCache(completion: @escaping DeletionCompletion)
    func save(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping SaveCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
