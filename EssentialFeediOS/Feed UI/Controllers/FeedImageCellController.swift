//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 11/08/23.
//

import UIKit

class FeedImageCellController {
    private let viewModel: FeedImageViewModel<UIImage>

    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }

    func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImage()
        return cell
    }

    private func binded(_ cell: FeedImageCell) -> FeedImageCell {
        cell.locationContainer.isHidden = viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.feedImageView.image = nil

        viewModel.onImageLoaded = { [weak cell] image in
            cell?.feedImageView.image = image
        }

        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            isLoading ? cell?.feedImageContainer.startShimmering() : cell?.feedImageContainer.stopShimmering()
        }

        viewModel.onShouldRetryStateChange = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }

        cell.onRetry = { [weak self] in
            self?.viewModel.loadImage()
        }
        return cell
    }

    func prefetchImage() {
        viewModel.prefetchImage()
    }

    func cancelTask() {
        viewModel.cancelTask()
    }
}
