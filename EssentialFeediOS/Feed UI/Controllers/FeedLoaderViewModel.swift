//
//  FeedLoaderViewModel.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 11/08/23.
//

import EssentialFeed

class FeedLoaderViewModel {
    private let feedLoader: FeedLoader
    var onFeedLoaded: (([FeedImage]) -> Void)?

    init(with feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    @objc func load(completion: @escaping () -> Void ) {
        feedLoader.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoaded?(feed)
            }
            completion()
        })
    }
}
