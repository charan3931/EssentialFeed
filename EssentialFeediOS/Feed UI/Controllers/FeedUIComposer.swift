//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 11/08/23.
//

import Foundation
import EssentialFeed

public class FeedUIComposer {
    public static func getFeedViewController(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshVC = RefreshController(with: feedLoader)
        let feedVC = FeedViewController(refreshVC: refreshVC)
        refreshVC.onRefreshCompletion = adaptFeedImagesToCellControllers(forwardingTo: feedVC, imageLoader: imageLoader)
        return feedVC
    }

    private static func adaptFeedImagesToCellControllers(forwardingTo feedVC: FeedViewController, imageLoader: FeedImageDataLoader) -> (([FeedImage]) -> Void) {
        return { [weak feedVC] feedImages in
            feedVC?.cellControllers = feedImages.map { FeedImageCellController(imageLoader: imageLoader, cellModel: $0) }
        }
    }
}
