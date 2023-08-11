//
//  FeedLoaderViewModel.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 11/08/23.
//

import EssentialFeed

class FeedLoaderViewModel {
    typealias Observer<T> = (T) -> Void

    private let feedLoader: FeedLoader

    var onFeedLoaded: Observer<[FeedImage]>?
    var onLoadingStateChange: Observer<Bool>?

    init(with feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    @objc func load() {
        onLoadingStateChange?(true)
        feedLoader.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoaded?(feed)
            }
            self?.onLoadingStateChange?(false)
        })
    }
}
