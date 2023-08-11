//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 11/08/23.
//

import UIKit
import EssentialFeed

class FeedImageCellController {
    private let cellModel: FeedImage
    private let viewModel: ImageLoaderViewModel

    init(viewModel: ImageLoaderViewModel, cellModel: FeedImage) {
        self.viewModel = viewModel
        self.cellModel = cellModel
    }

    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (cellModel.location == nil)
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.text = cellModel.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()

        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }

            self.viewModel.loadImage(from: cellModel.imageURL) { image in
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = (image != nil)
                cell?.feedImageContainer.stopShimmering()
            }
        }
        cell.onRetry = loadImage
        loadImage()
        return cell
    }

    func prefetchImage() {
        viewModel.prefetchImage(url: cellModel.imageURL)
    }

    func cancelTask(at indexPath: IndexPath) {
        viewModel.cancelTask()
    }
}
