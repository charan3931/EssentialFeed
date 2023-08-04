//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 03/08/23.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    var receivedMessages = [ReceivedMessage]()
    var deletionCompletion: DeleteCompletion!
    var insertionCompletion: SaveCompletion!
    var retrievalCompletion: LoadCompletion!

    enum ReceivedMessage: Equatable {
        case deletion
        case insertion([LocalFeedImage], Date)
        case retrieve
    }

    func deleteCache(completion: @escaping DeleteCompletion) {
        deletionCompletion = completion
        receivedMessages.append(.deletion)
    }

    func save(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping SaveCompletion) {
        insertionCompletion = completion
        receivedMessages.append(.insertion(items, timestamp))
    }

    func completeDeletion(with error: NSError) {
        deletionCompletion(error)
    }

    func completeDeletionSuccessfully() {
        deletionCompletion(nil)
    }

    func completeInsertion(with error: NSError) {
        insertionCompletion(error)
    }

    func completeInsertionSuccessfully() {
        insertionCompletion(nil)
    }

    func load(completion: @escaping LoadCompletion) {
        retrievalCompletion = completion
        receivedMessages.append(.retrieve)
    }

    func completeRetrieval(with error: NSError) {
        retrievalCompletion(.failure(error))
    }

    func completeRetrievalSuccessful(with images: [LocalFeedImage], timestamp: Date) {
        retrievalCompletion(.success((images, timestamp: timestamp)))
    }
}
