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
    var deletionCompletion: DeletionCompletion?
    var insertionCompletion: DeletionCompletion?

    enum ReceivedMessage: Equatable {
        case deletion
        case insertion([LocalFeedImage], Date)
    }

    func deleteCache(completion: @escaping DeletionCompletion) {
        deletionCompletion = completion
        receivedMessages.append(.deletion)
    }

    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletion = completion
        receivedMessages.append(.insertion(items, timestamp))
    }

    func completeDeletion(with error: NSError) {
        deletionCompletion?(error)
    }

    func completeDeletionSuccessfully() {
        deletionCompletion?(nil)
    }

    func completeInsertion(with error: NSError) {
        insertionCompletion?(error)
    }

    func completeInsertionSuccessfully() {
        insertionCompletion?(nil)
    }
}
