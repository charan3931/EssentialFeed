//
//  Feedcache+helpers.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 04/08/23.
//

import Foundation
import EssentialFeed


private func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyURL())
}

func uniqueFeedImages() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    return (models, local)
}

extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
