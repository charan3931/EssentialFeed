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
        let presentationAdapter = FeedLoaderPresentationAdapter(with: feedLoader)
        let refreshController = RefreshController(with: presentationAdapter)
        let feedController = FeedViewController(refreshVC: refreshController)

        presentationAdapter.presenter = FeedPresenter(
            feedLoadView: WeakRefVirtualProxy(ref: refreshController),
            feedView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader))

        return feedController
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

private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellPresenter where View.Image == Image {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?

    var presenter: FeedImagePresenter<View, Image>?

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func didRequestImage() {
        presenter?.didStartLoadingImage(for: model)

        let model = self.model
        task = imageLoader.loadImageData(from: model.imageURL) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImage(with: data, for: model)

            case let .failure(error):
                self?.presenter?.didFinishLoadingImage(with: error, for: model)
            }
        }
    }

    func prefetchImage() {
        let model = self.model
        task = imageLoader.loadImageData(from: model.imageURL) { _ in }
    }

    func didCancelImageRequest() {
        task?.cancel()
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader

    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(_ viewModel: FeedViewModel) {
        controller?.cellControllers = viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = FeedImageCellController(delegate: adapter)

            adapter.presenter = FeedImagePresenter(
                view: WeakRefVirtualProxy(ref: view),
                imageTransformer: UIImage.init)

            return view
        }
    }
}
