//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Sai Charan on 30/07/23.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable {}

protocol FeedLoader {
    typealias Error = Swift.Error
    func load(completion: @escaping(LoadFeedResult<Error>) -> Void)
}
