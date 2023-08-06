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
    @NSManaged public var timestamp: Date
    @NSManaged public var feedImages: NSOrderedSet

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedDataModel> {
        return NSFetchRequest<FeedDataModel>(entityName: "FeedDataModel")
    }
}

extension FeedDataModel {
    public class func save(feedImages: [LocalFeedImage], timeStamp: Date, in context: NSManagedObjectContext) {
        let feedImageDataModels = feedImages.map { FeedImageDataModel.toFeedImageDataModel(from: $0, context: context) }
        let feedDataModel = FeedDataModel(context: context)
        feedDataModel.feedImages = NSOrderedSet(array: feedImageDataModels)
        feedDataModel.timestamp = timeStamp
    }

    public var toLocalFeed: LocalFeed? {
        if let feedImages = feedImages.array as? [FeedImageDataModel] {
            return LocalFeed(items: feedImages.map { $0.toLocalFeedImage }, timestamp: timestamp)
        }
        return nil
    }
}

