//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 11/08/23.
//

import UIKit
import EssentialFeed

class FeedImageCellController {
    private let imageLoader: FeedImageDataLoader
    private let cellModel: FeedImage
    private var tasks: FeedImageDataLoaderTask?

    init(imageLoader: FeedImageDataLoader, cellModel: FeedImage) {
        self.imageLoader = imageLoader
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

            self.tasks = self.imageLoader.loadImageData(from: cellModel.imageURL) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
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
        tasks = self.imageLoader.loadImageData(from: cellModel.imageURL) { _ in }
    }

    func cancelTask(at indexPath: IndexPath) {
        tasks?.cancel()
    }
}
