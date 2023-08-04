//
//  SaveFeedCacheUseCase.swift
//  EssentialFeedTests
//
//  Created by Sai Charan on 02/08/23.
//

import XCTest
import EssentialFeed

final class SaveFeedCacheUseCase: XCTestCase {

    func test_init_doesNotDeleteCache() {
        let (_, store) = makeSUT(currentDate: Date.init)

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_doesNotInsertDataOnDeletionError() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.save(items: uniqueFeedImages().models, completion: { _ in })
        store.completeDeletion(with: anyError())

        XCTAssertEqual(store.receivedMessages, [.deletion])
    }

    func test_save_insertFeedItemsWithTimeStampOnSuccessfulDeletion() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let items = uniqueFeedImages()

        sut.save(items: items.models, completion: { _ in })
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.receivedMessages, [.deletion, .insertion(items.local, fixedCurrentDate)])
    }

    func test_save_deliveryErrorOnDeletionError() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let expectedError = anyError()

        expect(sut: sut, completeWithError: expectedError, when: {
            store.completeDeletion(with: expectedError)
        })
    }

    func test_save_deliveryErrorOnInsertionError() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let expectedError = anyError()

        expect(sut: sut, completeWithError: expectedError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: expectedError)
        })
    }

    func test_save_deliversNoErrorOnSuccessfulInsertion() {
        let fixedCurrentDate = currentDate()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        let exp = expectation(description: "wait for ccompletion")
        sut.save(items: uniqueFeedImages().models) { receivedError in
            XCTAssertNil(receivedError)
            exp.fulfill()
        }
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()
        wait(for: [exp], timeout: 1.0)
    }

    func test_save_doesNotDeliverErrorOnDeletionErrorAfterSUTInstanceDeallocated() {
        let store = FeedStoreSpy()
        let fixedCurrentDate = currentDate()
        var sut: LocalFeedLoader? = LocalFeedLoader(currentDate: { fixedCurrentDate }, store: store)

        var capturedResult = [Error?]()
        sut?.save(items: uniqueFeedImages().models) { receivedError in
            capturedResult.append(receivedError)
        }
        sut = nil
        store.completeDeletion(with: anyError())

        XCTAssertTrue(capturedResult.isEmpty)
    }

    func test_save_doesNotDeliverErrorOnInsertionErrorAfterSUTInstanceDeallocated() {
        let store = FeedStoreSpy()
        let fixedCurrentDate = currentDate()
        var sut: LocalFeedLoader? = LocalFeedLoader(currentDate: { fixedCurrentDate }, store: store)

        var capturedResult = [Error?]()
        sut?.save(items: uniqueFeedImages().models) { receivedError in
            capturedResult.append(receivedError)
        }
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyError())

        XCTAssertTrue(capturedResult.isEmpty)
    }

    //MARK: Helpers

    private func makeSUT(currentDate: @escaping () -> Date, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(currentDate: currentDate, store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    func expect(sut: LocalFeedLoader, completeWithError expectedError: NSError, when action: () -> Void) {
        let exp = expectation(description: "wait for ccompletion")
        sut.save(items: uniqueFeedImages().models) { receivedError in
            XCTAssertEqual((receivedError! as NSError).code, expectedError.code)
            XCTAssertEqual((receivedError! as NSError).domain, expectedError.domain)
            exp.fulfill()
        }
        action()

        wait(for: [exp], timeout: 1.0)
    }

    private func uniqueFeedImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }

    private func uniqueFeedImages() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let models = [uniqueFeedImage(), uniqueFeedImage()]
        let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
        return (models, local)
    }

    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }

    private func anyError() -> NSError {
        NSError(domain: "any Error", code: 0)
    }

    private func currentDate() -> Date {
        Date()
    }
}
