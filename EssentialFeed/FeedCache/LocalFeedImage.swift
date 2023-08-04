//
//  LocalFeedImage.swift
//  EssentialFeed
//
//  Created by Sai Charan on 04/08/23.
//

import Foundation

public struct LocalFeedImage: Equatable, Codable {
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

public struct LocalCacheFeed: Equatable {
    public let items: [LocalFeedImage]
    public let timestamp: Date

    public init(items: [LocalFeedImage], timestamp: Date) {
        self.items = items
        self.timestamp = timestamp
    }
}
