//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 11/08/23.
//

import Foundation
import EssentialFeed
import UIKit

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
            feedVC?.cellControllers = getCellControllers(feedImage: feedImages, imageLoader: imageLoader)
        }
    }

    private static func getCellControllers(feedImage: [FeedImage], imageLoader: FeedImageDataLoader) -> [FeedImageCellController] {
        feedImage.map { feedImage in
            let viewModel = FeedImageViewModel(model: feedImage, imageLoader: imageLoader, converter: { $0.map(UIImage.init) ?? nil })
            return FeedImageCellController(viewModel: viewModel)
        }
    }
}
