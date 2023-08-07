//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Sai Charan on 31/07/23.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func get(from: URL, completion: @escaping (Result) -> Void)
}
