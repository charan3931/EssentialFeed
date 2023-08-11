//
//  RefreshController.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 11/08/23.
//

import UIKit
import EssentialFeed

class RefreshController: NSObject {

    private let feedLoader: FeedLoader
    let refreshControl: UIRefreshControl
    var onRefreshCompletion: (([FeedImage]) -> Void)?

    init(with feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
        self.refreshControl = UIRefreshControl()

        super.init()

        refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
    }

    @objc func load() {
        refreshControl.beginRefreshing()
        feedLoader.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefreshCompletion?(feed)
            }
            self?.refreshControl.endRefreshing()
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
