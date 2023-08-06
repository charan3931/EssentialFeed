//
//  CoreDataStack.swift
//  EssentialFeed
//
//  Created by Sai Charan on 06/08/23.
//

import Foundation
import CoreData

public protocol CoreDataStack {
    init(modelName: String)
    var managedContext: NSManagedObjectContext { get }
    func saveContext ()
}

extension CoreDataStack {
    public func saveContext () {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
