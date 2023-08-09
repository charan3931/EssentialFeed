//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Sai Charan on 09/08/23.
//

import XCTest

class FeedViewController: UIViewController {

}

final class FeedViewControllerTests: XCTestCase {


    func test_init_doesNotLoadFeed() {
        let loaderSpy = LoaderSpy()
        let _ = FeedViewController()

        XCTAssertEqual(loaderSpy.loadCallCount, 0)
    }

    class LoaderSpy {
        var loadCallCount = 0
    }
}
