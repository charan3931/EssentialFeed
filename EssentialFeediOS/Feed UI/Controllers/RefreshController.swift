//
//  RefreshController.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 11/08/23.
//

import UIKit

class RefreshController: NSObject {

    let refreshControl: UIRefreshControl
    let viewModel: FeedLoaderViewModel

    init(with viewModel: FeedLoaderViewModel) {
        self.viewModel = viewModel
        self.refreshControl = UIRefreshControl()

        super.init()

        refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
    }

    @objc func load() {
        refreshControl.beginRefreshing()
        viewModel.load() { [weak refreshControl] in
            refreshControl?.endRefreshing()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
