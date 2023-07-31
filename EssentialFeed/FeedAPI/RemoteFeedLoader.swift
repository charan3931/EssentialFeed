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

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }

    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {

            case .success(let data, let response):
                do {
                    let items = try FeedItemsMapper.getItem(from: data, response: response)
                        completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure(_):
                completion(.failure(.connectivity))
            }
        }
    }
}

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
