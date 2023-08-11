//
//  ImageLoaderViewModel.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 11/08/23.
//

import UIKit

class ImageLoaderViewModel {
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?

    init(imageLoader: FeedImageDataLoader) {
        self.imageLoader = imageLoader
    }

    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        task = imageLoader.loadImageData(from: url, completion: { result in
            let data = try? result.get()
            let image = data.map(UIImage.init) ?? nil
            completion(image)
        })
    }

    func prefetchImage(url: URL) {
        task = self.imageLoader.loadImageData(from: url) { _ in }
    }

    func cancelTask() {
        task?.cancel()
    }
}
