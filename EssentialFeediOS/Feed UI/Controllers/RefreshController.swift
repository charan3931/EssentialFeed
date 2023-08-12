//
//  RefreshController.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 11/08/23.
//

import UIKit

protocol RefreshControllerDelegate {
    func didRequestFeedRefresh()
}

class RefreshController: NSObject {

    private(set) lazy var refreshControl = getRefreshControl()

    private var delegate: RefreshControllerDelegate

    init(with delegate: RefreshControllerDelegate) {
        self.delegate = delegate
        super.init()
    }

    @objc func load() {
        delegate.didRequestFeedRefresh()
    }

    private func getRefreshControl() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(load), for: .valueChanged)
        return view
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RefreshController: FeedLoadView {
    func display(_ viewModel: FeedLoadViewModel) {
        viewModel.isLoading ? refreshControl.beginRefreshing() : refreshControl.endRefreshing()
    }
}
