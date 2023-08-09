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
        refreshControl?.beginRefreshing()
        load()
    }

    @objc private func load() {
        loader.load(completion: { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        })
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

    func test_pullToRefresh_loadsFeed() {
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loaderSpy.loadCallCount, 2)

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loaderSpy.loadCallCount, 3)
    }

    func test_viewDidLoad_showsRefreshIndicator() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
    }

    func test_viewDidLoad_hidesRefreshIndicatorOnLoadCompletion() {
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()

        loaderSpy.completeFeedLoading()

        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
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
        var completions = [(FeedLoader.Result) -> Void]()

        var loadCallCount: Int {
            completions.count
        }

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }

        func completeFeedLoading() {
            completions[0](.success([]))
        }
    }
}

extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }

    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
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
