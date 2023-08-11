//
//  RefreshController.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 11/08/23.
//

import UIKit

class RefreshController: NSObject {

    private(set) lazy var refreshControl: UIRefreshControl = bind(UIRefreshControl())
    let viewModel: FeedLoaderViewModel

    init(with viewModel: FeedLoaderViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    @objc func load() {
        viewModel.load()
    }

    private func bind(_ view: UIRefreshControl) -> UIRefreshControl {
        view.addTarget(self, action: #selector(load), for: .valueChanged)
        viewModel.onLoadingStateChange = { [weak view] isLoading in
            isLoading ? view?.beginRefreshing() : view?.endRefreshing()
        }
        return view
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
