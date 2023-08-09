//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Sai Charan on 09/08/23.
//

import XCTest
import EssentialFeed

class FeedViewController: UIViewController {
    let loader: FeedLoader

    init(loader: FeedLoader) {
        self.loader = loader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loader.load(completion: { _ in })
    }

}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loaderSpy = LoaderSpy()
        let _ = FeedViewController(loader: loaderSpy)

        XCTAssertEqual(loaderSpy.loadCallCount, 0)
    }

    func test_viewDidLoad_loadsFeed() {
        let loaderSpy = LoaderSpy()
        let sut = FeedViewController(loader: loaderSpy)

        sut.loadViewIfNeeded()

        XCTAssertEqual(loaderSpy.loadCallCount, 1)
    }

    class LoaderSpy: FeedLoader {

        var loadCallCount = 0

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }

    }
}
