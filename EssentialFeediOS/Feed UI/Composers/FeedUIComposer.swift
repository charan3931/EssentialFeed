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
        let presenter = FeedPresenter()
        let presentationAdapter = FeedLoaderPresentationAdapter(with: feedLoader, presenter: presenter)
        let refreshVC = RefreshController(with: presentationAdapter)
        presenter.feedLoadView = WeakRefVirtualProxy(ref: refreshVC)

        let feedVC = FeedViewController(refreshVC: refreshVC)

        presenter.feedView = AdapterFeedImageToCellController(feedVC: feedVC, imageLoader: imageLoader)
        return feedVC
    }
}

class WeakRefVirtualProxy<T: AnyObject> {
    weak var reference: T?

    init(ref: T) {
        self.reference = ref
    }
}

extension WeakRefVirtualProxy: FeedLoadView where T: FeedLoadView {
    func display(_ viewModel: FeedLoadViewModel) {
        reference?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ viewModel: FeedImageViewModel<T.Image>) {
        reference?.display(viewModel)
    }
}

class AdapterFeedImageToCellController: FeedView {
    private weak var feedVC: FeedViewController?
    private let imageLoader: FeedImageDataLoader

    init(feedVC: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.feedVC = feedVC
        self.imageLoader = imageLoader
    }

    func display(_ viewModel: FeedViewModel) {
        feedVC?.cellControllers = viewModel.feed.map { feedImage in
            let presenter = FeedImagePresenter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: feedImage, imageLoader: imageLoader, imageTransformer: UIImage.init)
            let cellController = FeedImageCellController(viewModel: presenter)
            presenter.view = WeakRefVirtualProxy(ref: cellController)
            return cellController
        }
    }
}
