//
//  URLSessionHTTPClient.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 01/08/23.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient: HTTPClient {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (EssentialFeed.HTTPClientResult) -> Void) {
        session.dataTask(with: URLRequest(url: url), completionHandler: { _,_, error  in
            if let error {
                completion(.failure(error))
            }
        }).resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_get_requestsWithCorrectURL() {
        URLProtocol.registerClass(URLProtocolStub.self)

        let sut = URLSessionHTTPClient()
        let url = URL(string: "https://any-url.com")!

        let exp = expectation(description: "wait for completion")
        sut.get(from: url, completion: { _ in
            exp.fulfill()
        })

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(URLProtocolStub.stub, [url])
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }

    class URLProtocolStub: URLProtocol {

        static var stub = [URL]()

        override class func canInit(with request: URLRequest) -> Bool {
            stub.append(request.url!)
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "any error", code: 0))
            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }

}


