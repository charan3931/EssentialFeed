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

    var feedLoadView: FeedLoadView?
    var feedView: FeedView?

    func didStartLoading() {
        feedLoadView?.display(FeedLoadViewModel(isLoading: true))
    }

    func didLoadFeed(_ feed: [FeedImage]) {
        feedView?.display(FeedViewModel(feed: feed))
        feedLoadView?.display(FeedLoadViewModel(isLoading: false))
    }

    func didFailLoading(_ error: Error) {
        feedLoadView?.display(FeedLoadViewModel(isLoading: false))
    }
}

class FeedLoaderPresentationAdapter {
    private let feedLoader: FeedLoader
    private let presenter: FeedPresenter

    init(with feedLoader: FeedLoader, presenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.presenter = presenter
    }

    func load() {
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
