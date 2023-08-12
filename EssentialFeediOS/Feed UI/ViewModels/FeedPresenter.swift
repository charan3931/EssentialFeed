//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 12/08/23.
//

import Foundation
import EssentialFeed

struct FeedLoadViewModel {
    let isLoading: Bool
}

protocol FeedLoadView {
    func display(_ viewModel: FeedLoadViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

class FeedPresenter {
    private let feedLoader: FeedLoader

    var feedLoadView: FeedLoadView?
    var feedView: FeedView?

    init(with feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    @objc func load() {
        feedLoadView?.display(FeedLoadViewModel(isLoading: true))
        feedLoader.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(FeedViewModel(feed: feed))
            }
            self?.feedLoadView?.display(FeedLoadViewModel(isLoading: false))
        })
    }
}
