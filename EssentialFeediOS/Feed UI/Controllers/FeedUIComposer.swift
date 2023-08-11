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
        let refreshViewModel = FeedLoaderViewModel(with: feedLoader)
        let refreshVC = RefreshController(with: refreshViewModel)
        let feedVC = FeedViewController(refreshVC: refreshVC)
        refreshViewModel.onFeedLoaded = adaptFeedImagesToCellControllers(forwardingTo: feedVC, imageLoader: imageLoader)
        return feedVC
    }

    private static func adaptFeedImagesToCellControllers(forwardingTo feedVC: FeedViewController, imageLoader: FeedImageDataLoader) -> (([FeedImage]) -> Void) {
        return { [weak feedVC] feedImages in
            feedVC?.cellControllers = feedImages.map {
                let viewModel = ImageLoaderViewModel(imageLoader: imageLoader)
                return FeedImageCellController(viewModel: viewModel, cellModel: $0)
            }
        }
    }
}
