//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 11/08/23.
//

import UIKit

protocol FeedImageCellPresenter {
    func didRequestImage()
    func prefetchImage()
    func didCancelImageRequest()
}

class FeedImageCellController {
    private let delegate: FeedImageCellPresenter
    private lazy var cell: FeedImageCell = FeedImageCell()

    init(delegate: FeedImageCellPresenter) {
        self.delegate = delegate
    }

    func view() -> UITableViewCell {
        delegate.didRequestImage()
        return cell
    }

    func prefetchImage() {
        delegate.prefetchImage()
    }

    func cancelTask() {
        delegate.didCancelImageRequest()
    }
}

extension FeedImageCellController: FeedImageView {
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell.locationContainer.isHidden = viewModel.location == nil
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.feedImageView.image = viewModel.image
        cell.feedImageRetryButton.isHidden = !viewModel.showRetry
        cell.onRetry = delegate.didRequestImage

        viewModel.isLoading ? cell.feedImageContainer.startShimmering() : cell.feedImageContainer.stopShimmering()
    }
}
