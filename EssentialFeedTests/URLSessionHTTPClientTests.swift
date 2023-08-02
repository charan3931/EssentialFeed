//
//  URLSessionHTTPClient.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 01/08/23.
//

import XCTest
import EssentialFeed

final class URLSessionHTTPClientTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }

    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }

    func test_getFromURL_requestFromURL() {
        let sut = makeSUT()
        let url = anyURL()

        var receivedRequest: URLRequest?
        URLProtocolStub.observeRequest = { request in
            receivedRequest = request
        }

        let exp = expectation(description: "wait for completion")
        sut.get(from: url, completion: { _ in
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedRequest?.url, url)
        XCTAssertEqual(receivedRequest?.httpMethod, "GET")
    }

    func test_getFromURL_failsOnRequestError() {
        let sut = makeSUT()
        let url = anyURL()
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
    }

    //MARK: Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }

    class URLProtocolStub: URLProtocol {

        private static var stubs = [URL: Stub]()

        static var observeRequest: ((URLRequest) -> Void)?

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }

        static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
            stubs[url] = Stub(data: data, response: response, error: error)
        }

        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            stubs = [:]
            observeRequest = nil
            URLProtocol.unregisterClass(URLProtocolStub.self)
        }

        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            if let observeRequest = Self.observeRequest {
                client?.urlProtocolDidFinishLoading(self)
                observeRequest(request)
            }

            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }

            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            } else if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            } else if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
}


