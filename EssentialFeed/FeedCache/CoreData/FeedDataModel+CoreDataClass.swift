//
//  FeedDataModel+CoreDataClass.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 06/08/23.
//
//

import Foundation
import CoreData

@objc(FeedDataModel)
public class FeedDataModel: NSManagedObject {

    public class func toFeedDataModel(feedImages: [LocalFeedImage], timeStamp: Date, context: NSManagedObjectContext) -> FeedDataModel {
        let feedImageDataModels = feedImages.map { FeedImageDataModel.toFeedImageDataModel(from: $0, context: context) }
        let feedDataModel = FeedDataModel(context: context)
        feedDataModel.feedImages = NSOrderedSet(array: feedImageDataModels)
        feedDataModel.timestamp = timeStamp
        return feedDataModel
    }

    public var toLocalFeed: LocalFeed? {
        if let feedImages = feedImages.array as? [FeedImageDataModel] {
            return LocalFeed(items: feedImages.map { $0.toLocalFeedImage }, timestamp: timestamp)
        }
        return nil
    }
}
