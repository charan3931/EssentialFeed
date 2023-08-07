//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Sai Charan on 03/08/23.
//

import Foundation

public protocol FeedStore {
    typealias RetrievalResult = Swift.Result<LocalFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    typealias SaveResult = Swift.Result<Void, Error>
    typealias SaveCompletion = (SaveResult) -> Void

    typealias DeletionResult = Swift.Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void

    func deleteCache(completion: @escaping DeletionCompletion)
    func save(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping SaveCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
