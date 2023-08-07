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
    @NSManaged var timestamp: Date
    @NSManaged var feedImages: NSOrderedSet

    @nonobjc class func fetchRequest() -> NSFetchRequest<FeedDataModel> {
        return NSFetchRequest<FeedDataModel>(entityName: "FeedDataModel")
    }
}

extension FeedDataModel {
    class func save(feedImages: [LocalFeedImage], timeStamp: Date, in context: NSManagedObjectContext) {
        let feedDataModel = FeedDataModel(context: context)

        let feedImageDataModels = feedImages.map { FeedImageDataModel.toFeedImageDataModel(from: $0, context: context) }
        feedDataModel.feedImages = NSOrderedSet(array: feedImageDataModels)
        feedDataModel.timestamp = timeStamp
    }

    var toLocalFeed: LocalFeed? {
        if let feedImages = feedImages.array as? [FeedImageDataModel] {
            return LocalFeed(items: feedImages.map { $0.toLocalFeedImage }, timestamp: timestamp)
        }
        return nil
    }
}

