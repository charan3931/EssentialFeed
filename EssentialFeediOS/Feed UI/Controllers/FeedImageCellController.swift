//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 11/08/23.
//

import UIKit

class FeedImageCellController {
    private let viewModel: FeedImagePresenter<FeedImageCellController, UIImage>
    private var cell: FeedImageCell?

    init(viewModel: FeedImagePresenter<FeedImageCellController, UIImage>) {
        self.viewModel = viewModel
    }

    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.onRetry = viewModel.loadImage
        self.cell = cell
        viewModel.loadImage()
        return cell
    }

    func prefetchImage() {
        viewModel.prefetchImage()
    }

    func cancelTask() {
        viewModel.cancelTask()
    }
}

extension FeedImageCellController: FeedImageView {
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell?.locationContainer.isHidden = viewModel.location == nil
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.feedImageView.image = viewModel.image

        cell?.feedImageRetryButton.isHidden = !viewModel.showRetry

        viewModel.isLoading ? cell?.feedImageContainer.startShimmering() : cell?.feedImageContainer.stopShimmering()
    }
}
