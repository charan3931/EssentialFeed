//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Sai Charan on 30/07/23.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    typealias Error = Swift.Error
    func load(completion: @escaping(LoadFeedResult) -> Void)
}
