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
            if let receivedError = error {
                completion(.failure(receivedError))
            }
        }).resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_failsOnRequestError() {
        URLProtocol.registerClass(URLProtocolStub.self)

        let sut = URLSessionHTTPClient()
        let url = URL(string: "https://any-url.com")!
        let expectedError = NSError(domain: "any error", code: 0)
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: expectedError)

        let exp = expectation(description: "wait for completion")
        sut.get(from: url, completion: { result in
            switch result {
            case .failure(let receivedError as NSError):
                XCTAssertEqual(receivedError.domain, expectedError.domain)
                XCTAssertEqual(receivedError.code, expectedError.code)
            default:
                XCTFail("expected error \(expectedError) but got \(result)")
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }

    //MARK: Helpers

    class URLProtocolStub: URLProtocol {

        private static var stubs = [URL: Stub]()

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }

        static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
            stubs[url] = Stub(data: data, response: response, error: error)
        }

        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }

            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
}


