//
//  FeedDataModel+CoreDataProperties.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 06/08/23.
//
//

import Foundation
import CoreData


extension FeedDataModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedDataModel> {
        return NSFetchRequest<FeedDataModel>(entityName: "FeedDataModel")
    }

    @NSManaged public var timestamp: Date
    @NSManaged public var feedImages: NSOrderedSet

}

// MARK: Generated accessors for feedImages
extension FeedDataModel {

    @objc(insertObject:inFeedImagesAtIndex:)
    @NSManaged public func insertIntoFeedImages(_ value: FeedImageDataModel, at idx: Int)

    @objc(removeObjectFromFeedImagesAtIndex:)
    @NSManaged public func removeFromFeedImages(at idx: Int)

    @objc(insertFeedImages:atIndexes:)
    @NSManaged public func insertIntoFeedImages(_ values: [FeedImageDataModel], at indexes: NSIndexSet)

    @objc(removeFeedImagesAtIndexes:)
    @NSManaged public func removeFromFeedImages(at indexes: NSIndexSet)

    @objc(replaceObjectInFeedImagesAtIndex:withObject:)
    @NSManaged public func replaceFeedImages(at idx: Int, with value: FeedImageDataModel)

    @objc(replaceFeedImagesAtIndexes:withFeedImages:)
    @NSManaged public func replaceFeedImages(at indexes: NSIndexSet, with values: [FeedImageDataModel])

    @objc(addFeedImagesObject:)
    @NSManaged public func addToFeedImages(_ value: FeedImageDataModel)

    @objc(removeFeedImagesObject:)
    @NSManaged public func removeFromFeedImages(_ value: FeedImageDataModel)

    @objc(addFeedImages:)
    @NSManaged public func addToFeedImages(_ values: NSOrderedSet)

    @objc(removeFeedImages:)
    @NSManaged public func removeFromFeedImages(_ values: NSOrderedSet)

}

extension FeedDataModel : Identifiable {

}
