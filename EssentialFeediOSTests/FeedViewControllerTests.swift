//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Sai Charan on 09/08/23.
//

import XCTest
import EssentialFeed

class FeedViewController: UITableViewController {
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

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }

    @objc private func load() {
        loader.load(completion: { _ in })
    }

}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let (_, loaderSpy) = makeSUT()

        XCTAssertEqual(loaderSpy.loadCallCount, 0)
    }

    func test_viewDidLoad_loadsFeed() {
        let (sut, loaderSpy) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(loaderSpy.loadCallCount, 1)
    }

    func test_pullTORefresh_loadsFeed() {
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()

        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loaderSpy.loadCallCount, 2)

        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loaderSpy.loadCallCount, 3)
    }

    //MARK: Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loaderSpy: LoaderSpy) {
        let loaderSpy = LoaderSpy()
        let sut = FeedViewController(loader: loaderSpy)

        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loaderSpy, file: file, line: line)

        return (sut, loaderSpy)
    }

    class LoaderSpy: FeedLoader {

        var loadCallCount = 0

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }

    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
