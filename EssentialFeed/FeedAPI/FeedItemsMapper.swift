//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Sai Charan on 31/07/23.
//

import Foundation

struct FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
    }

    private struct Item: Decodable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let image: URL

        var feedItem: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }

    static var OK_200 = 200

    static func getItem(from data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200, let items = try? JSONDecoder().decode(Root.self, from: data).items else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return items.map { $0.feedItem }
    }
}
