//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 09/08/23.
//

import Foundation
import UIKit
import EssentialFeed

class FeedImageCellController {
    init(imageLoader: FeedImageDataLoader, cellModel: FeedImage) {
        self.imageLoader = imageLoader
        self.cellModel = cellModel
    }

    private let imageLoader: FeedImageDataLoader
    private let cellModel: FeedImage
    private var cancellableTask: FeedImageDataLoaderTask?

    fileprivate func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (cellModel.location == nil)
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.text = cellModel.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()

        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }

            self.cancellableTask = self.imageLoader.loadImageData(from: cellModel.imageURL) { [weak cell] result in
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

    deinit {
        cancelTask()
    }

    func prefetchImage() {
        self.cancellableTask = self.imageLoader.loadImageData(from: cellModel.imageURL) { _ in }
    }

    func cancelTask() {
        self.cancellableTask?.cancel()
    }
}

public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var tableModel = [FeedImage]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var refreshVC: RefreshController?
    private let feedLoader: FeedLoader
    private let imageLoader: FeedImageDataLoader
    private var cellControllers = [IndexPath: FeedImageCellController]()

    public init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshVC = RefreshController(with: feedLoader, tableView: self, onRefreshCompletion: { [weak self] feedImages in
            self?.tableModel = feedImages
        })

        tableView.prefetchDataSource = self
        refreshVC?.load()
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellController = FeedImageCellController(imageLoader: imageLoader, cellModel: tableModel[indexPath.row])
        cellControllers[indexPath] = cellController
        return cellController.view()
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellController = FeedImageCellController(imageLoader: imageLoader, cellModel: tableModel[indexPath.row])
            cellControllers[indexPath] = cellController
            cellController.prefetchImage()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }

    private func cancelTask(forRowAt indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
}
