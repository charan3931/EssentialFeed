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
        let presenter = FeedPresenter(with: feedLoader)
        let refreshVC = RefreshController(with: presenter)
        presenter.feedLoadView = refreshVC

        let feedVC = FeedViewController(refreshVC: refreshVC)

        presenter.feedView = AdapterFeedImageToCellController(feedVC: feedVC, imageLoader: imageLoader)
        return feedVC
    }
}

class AdapterFeedImageToCellController: FeedView {
    private weak var feedVC: FeedViewController?
    private let imageLoader: FeedImageDataLoader

    init(feedVC: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.feedVC = feedVC
        self.imageLoader = imageLoader
    }

    func display(feed: [FeedImage]) {
        feedVC?.cellControllers = feed.map { feedImage in
            let viewModel = FeedImageViewModel(model: feedImage, imageLoader: imageLoader, imageTransformer: UIImage.init)
            return FeedImageCellController(viewModel: viewModel)
        }
    }
}
