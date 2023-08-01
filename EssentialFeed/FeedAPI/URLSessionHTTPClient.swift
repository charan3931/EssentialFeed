//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Sai Charan on 01/08/23.
//

public class URLSessionHTTPClient: HTTPClient {

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func get(from url: URL, completion: @escaping (EssentialFeed.HTTPClientResult) -> Void) {
        session.dataTask(with: URLRequest(url: url), completionHandler: { data, response, error  in
            if let receivedError = error {
                completion(.failure(receivedError))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            }
        }).resume()
    }
}
