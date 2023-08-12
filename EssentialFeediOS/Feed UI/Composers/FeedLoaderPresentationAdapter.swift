//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 12/08/23.
//

import EssentialFeed

class FeedLoaderPresentationAdapter: RefreshControllerDelegate {
    private let feedLoader: FeedLoader
    private let presenter: FeedPresenter

    init(with feedLoader: FeedLoader, presenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.presenter = presenter
    }

    func didRequestFeedRefresh() {
        presenter.didStartLoading()
        feedLoader.load(completion: { [weak self] result in
            switch result {
            case .success(let feed):
                self?.presenter.didLoadFeed(feed)
            case .failure(let error):
                self?.presenter.didFailLoading(error)
            }
        })
    }
}
