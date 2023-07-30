//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Sai Charan on 30/07/23.
//

import Foundation

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient

    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }

    public func load() {
        client.get(from: url)
    }
}

public protocol HTTPClient {
    func get(from: URL)
}
