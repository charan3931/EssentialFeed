//
//  CoreDataStack.swift
//  EssentialFeed
//
//  Created by Sai Charan on 06/08/23.
//

import Foundation
import CoreData

public protocol CoreDataStack {
    init(modelName: String, bundle: Bundle)
    var managedContext: NSManagedObjectContext { get }
}
