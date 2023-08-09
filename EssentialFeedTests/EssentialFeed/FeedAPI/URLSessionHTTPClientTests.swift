//
//  URLSessionHTTPClient.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 01/08/23.
//

import XCTest
import EssentialFeed

final class URLSessionHTTPClientTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }

    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }

    func test_getFromURL_requestFromURL() {
        let sut = makeSUT()
        let url = anyURL()

        var receivedRequest: URLRequest?
        URLProtocolStub.observeRequests(observer: { request in
            receivedRequest = request
        })

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
        URLProtocolStub.stub(data: nil, response: nil, error: expectedError)

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

        private static var stubs: Stub?

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
            let requestObserver: ((URLRequest) -> Void)?
        }

        private static var _stub: Stub?
        private static var stub: Stub? {
            get { return queue.sync { _stub } }
            set { queue.sync { _stub = newValue } }
        }

        private static let queue = DispatchQueue(label: "URLProtocolStub.queue")

        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error, requestObserver: nil)
        }

        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
        }

        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            stubs = nil
            URLProtocol.unregisterClass(URLProtocolStub.self)
        }

        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {

            guard let stub = URLProtocolStub.stub else { return }

            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            } else if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            } else if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }

            stub.requestObserver?(request)
        }

        override func stopLoading() {}
    }
}


