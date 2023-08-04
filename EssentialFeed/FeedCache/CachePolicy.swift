//
//  CachePolicy.swift
//  EssentialFeed
//
//  Created by Sai Charan on 04/08/23.
//

import Foundation

struct CachePolicy {
    static var maxAgeDays: Int { 7 }

    private init() {}

    static func isValid(currentDate: () -> Date, timestamp: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxAgeDays, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
    }
}
