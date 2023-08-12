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
