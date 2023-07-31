//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Sai Charan on 31/07/23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from: URL, completion: @escaping (HTTPClientResult) -> Void)
}
