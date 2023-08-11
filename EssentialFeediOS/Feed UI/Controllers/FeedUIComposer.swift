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

    fileprivate static func getCellController(feedImage: FeedImage, imageLoader: FeedImageDataLoader) -> FeedImageCellController {
        let viewModel = FeedImageViewModel<UIImage>(model: feedImage, imageLoader: imageLoader, converter: { (data) in
            data.map(UIImage.init) ?? nil
        })
        return FeedImageCellController(viewModel: viewModel)
    }

    private static func adaptFeedImagesToCellControllers(forwardingTo feedVC: FeedViewController, imageLoader: FeedImageDataLoader) -> (([FeedImage]) -> Void) {
        return { [weak feedVC] feedImages in
            feedVC?.cellControllers = feedImages.map{ getCellController(feedImage: $0, imageLoader: imageLoader) }
        }
    }
}
