//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Sai Charan on 03/08/23.
//

import Foundation

public protocol FeedStore {
    typealias DeleteCompletion = (Error?) -> Void
    typealias SaveCompletion = (Error?) -> Void
    typealias LoadCompletion = (Result) -> Void

    typealias Result = Swift.Result<([LocalFeedImage], timestamp: Date), Error>

    func deleteCache(completion: @escaping DeleteCompletion)
    func save(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping SaveCompletion)
    func load(completion: @escaping LoadCompletion)
}

public struct LocalFeedImage: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL

    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
