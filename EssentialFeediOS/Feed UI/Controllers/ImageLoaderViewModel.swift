//
//  ImageLoaderViewModel.swift
//  EssentialFeediOS
//
//  Created by Sai Charan on 11/08/23.
//

class ImageLoaderViewModel<Image> {
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    private let converter: (Data?) -> Image?

    init(imageLoader: FeedImageDataLoader, converter: @escaping (Data?) -> Image?) {
        self.imageLoader = imageLoader
        self.converter = converter
    }

    func loadImage(from url: URL, completion: @escaping (Image?) -> Void) {
        task = imageLoader.loadImageData(from: url, completion: { [weak self] result in
            let data = try? result.get()
            let image = self?.converter(data) ?? nil
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
