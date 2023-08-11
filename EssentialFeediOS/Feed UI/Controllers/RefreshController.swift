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
    private let refreshControl: UIRefreshControl
    private let onRefreshCompletion: ([FeedImage]) -> Void

    init(with feedLoader: FeedLoader, tableView: UITableViewController, onRefreshCompletion: @escaping ([FeedImage]) -> Void) {
        self.feedLoader = feedLoader
        self.refreshControl = UIRefreshControl()
        self.onRefreshCompletion = onRefreshCompletion

        super.init()

        tableView.refreshControl = refreshControl
        tableView.refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    }

    @objc func load() {
        refreshControl.beginRefreshing()
        feedLoader.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefreshCompletion(feed)
            }
            self?.refreshControl.endRefreshing()
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
