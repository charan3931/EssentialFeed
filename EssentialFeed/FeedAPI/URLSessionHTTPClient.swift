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

    private struct UnwantedError: Swift.Error {}

    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: URLRequest(url: url), completionHandler: { data, response, error  in
            if let receivedError = error {
                completion(.failure(receivedError))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnwantedError()))
            }
        }).resume()
    }
}
