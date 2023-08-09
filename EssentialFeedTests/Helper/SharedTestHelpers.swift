//
//  Helpers.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 04/08/23.
//

import Foundation

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyError() -> NSError {
    NSError(domain: "any Error", code: 0)
}

func currentDate() -> Date { Date() }
