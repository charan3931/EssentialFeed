//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 30/07/23.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-AnyGivenURL.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load() { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURL() {
        let url = URL(string: "https://a-AnyGivenURL.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_DeliversErrorOnCLientError() {
        let url = URL(string: "https://a-AnyGivenURL.com")!
        let (sut, client) = makeSUT(url: url)

        expect(sut, toCompleteWithResult: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }

    func test_load_DeliversErrorOnNon200ResponseError() {
        let url = URL(string: "https://a-AnyGivenURL.com")!
        let (sut, client) = makeSUT(url: url)

        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
                client.complete(statusCode: statusCode, at: index)
            })
        }
    }

    func test_load_DeliversErrorOn200ResponseWithInvalidData() {
        let url = URL(string: "https://a-AnyGivenURL.com")!
        let (sut, client) = makeSUT(url: url)

        expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
            let invalidJSONData = Data("Invalid JSON Data".utf8)
            client.complete(statusCode: 200, data: invalidJSONData)
        })
    }

    func test_load_DeliversEmptyFeedItemsOn200ResponseWithEmptyJSON() {
        let url = URL(string: "https://a-AnyGivenURL.com")!
        let (sut, client) = makeSUT(url: url)

        expect(sut, toCompleteWithResult: .success([]), when: {
            let emptyListJSON = Data("{\"items\": []}".utf8)
            client.complete(statusCode: 200, data: emptyListJSON)
        })
    }

    //MARK: - helpers
    private func makeSUT(url: URL = URL(string: "https://a-AnyURL.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }

    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load() { capturedResults.append($0) }

        action()

        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }

    class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }

        func complete(statusCode: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: messages[index].url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
    }
}
