//
//  FeedImageDataModel+CoreDataClass.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 06/08/23.
//
//

import Foundation
import CoreData

@objc(FeedImageDataModel)
public class FeedImageDataModel: NSManagedObject {

    public class func toFeedImageDataModel(from feedImage: LocalFeedImage, context: NSManagedObjectContext) -> FeedImageDataModel {
        let dataModel = FeedImageDataModel(context: context)
        dataModel.id = feedImage.id
        dataModel.desc = feedImage.description
        dataModel.location = feedImage.location
        dataModel.url = feedImage.imageURL.absoluteString
        return dataModel
    }

    public var toLocalFeedImage: LocalFeedImage {
        return LocalFeedImage(id: id, description: desc, location: location, imageURL: URL(string: url)!)
    }
}
