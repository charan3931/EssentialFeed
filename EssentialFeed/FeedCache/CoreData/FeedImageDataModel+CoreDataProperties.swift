//
//  FeedImageDataModel+CoreDataProperties.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 06/08/23.
//
//

import Foundation
import CoreData


extension FeedImageDataModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedImageDataModel> {
        return NSFetchRequest<FeedImageDataModel>(entityName: "FeedImageDataModel")
    }

    @NSManaged public var id: UUID
    @NSManaged public var url: String
    @NSManaged public var desc: String?
    @NSManaged public var location: String?
    @NSManaged public var feed: FeedDataModel?

}

extension FeedImageDataModel : Identifiable {

}
