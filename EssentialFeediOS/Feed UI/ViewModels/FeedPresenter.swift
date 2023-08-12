//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 12/08/23.
//

import Foundation
import EssentialFeed

protocol FeedLoadView: AnyObject {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
}

class FeedPresenter {
    private let feedLoader: FeedLoader

    weak var feedLoadView: FeedLoadView?
    var feedView: FeedView?

    init(with feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    @objc func load() {
        feedLoadView?.display(isLoading: true)
        feedLoader.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feed: feed)
            }
            self?.feedLoadView?.display(isLoading: false)
        })
    }
}
