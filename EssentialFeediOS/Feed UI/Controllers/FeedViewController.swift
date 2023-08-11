//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 09/08/23.
//

import Foundation
import UIKit
import EssentialFeed

class RefreshController: NSObject {

    private let feedLoader: FeedLoader
    private let refreshControl: UIRefreshControl
    private let onRefreshCompletion: ([FeedImage]) -> Void

    init(with feedLoader: FeedLoader, tableView: UITableViewController, onRefreshCompletion: @escaping ([FeedImage]) -> Void) {
        self.feedLoader = feedLoader
        self.refreshControl = UIRefreshControl()
        self.onRefreshCompletion = onRefreshCompletion

        super.init()

        tableView.refreshControl = refreshControl
        tableView.refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    }

    @objc func load() {
        refreshControl.beginRefreshing()
        feedLoader.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefreshCompletion(feed)
            }
            self?.refreshControl.endRefreshing()
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var imageLoader: FeedImageDataLoader?
    private var tableModel = [FeedImage]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var tasks = [IndexPath: FeedImageDataLoaderTask]()
    private var refreshVC: RefreshController?
    private let feedLoader: FeedLoader

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
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (cellModel.location == nil)
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.text = cellModel.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()

        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }

            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: cellModel.imageURL) { [weak cell] result in
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

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellModel = tableModel[indexPath.row]
            tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.imageURL) { _ in }
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }

    private func cancelTask(forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
